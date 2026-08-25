# تنفيذ تتبّع المشي والجري — مواصفة فرونت إند

> **الغرض:** إعادة بناء فيتشر المشي/الجري في تطبيق تاني بنفس المنطق ونفس عقد الباك.
> ده ملف **تنفيذ** — مستخرج من الكود الشغّال. للسجل التاريخي للمشاكل اللي اتحلّت شوف
> [`walking_running_review.md`](walking_running_review.md).
>
> **اقرا قبل أي حاجة:** [§3 جدول الوحدات](#3-جدول-الوحدات--أهم-جدول-في-الملف) و[§4 قاعدة الدلتا](#4-قاعدة-الدلتا-وحماية-التكرار).
> دول أكتر اتنين حاجة بيتغلط فيهم.

---

## 1. نظرة عامة

نشاطين منفصلين بيشتركوا في نفس شاشة الدخول ونفس endpoint القراءة، وكل واحد ليه cubit
و endpoint إرسال مستقلين:

| | المشي | الجري |
|---|---|---|
| **مصدر التقدّم الأساسي** | Health Store (HealthKit / Health Connect) | GPS (Haversine) |
| **مصدر احتياطي** | pedometer + تقدير طول الخطوة | pedometer + تقدير طول الخطوة |
| **وحدة الهدف** | خطوة (steps) | كيلومتر (km) |
| **السعرات** | من الـ Health Store | من رد الباك على الـ sync |
| **إيقاع الإرسال** | كل 15 ثانية (poll) | مع كل تحرّك ≥ 5 متر |
| **إنهاء النشاط** | ملوش علم `isFinal` مؤثّر | `isFinal: true` هو اللي يقفله |
| **فلترة الاهتزاز** | token bucket + GPS veto + OS classifier | ❌ مفيش (شوف §10.3) |

الدورة الكاملة:

```
فتح الشاشة
  → GET تفاصيل النشاط  →  goal / currentProgress / activityItemId
  → بناء الـ cubit بالـ goal
  → المستخدم يدوس Start
      → أذونات → sensors شغّالة → session بتبدأ من صفر
      → كل poll / tick: احسب إجمالي الجلسة → اطرح آخر حاجة اتبعتت → ابعت الدلتا
  → المستخدم يدوس Stop
      → آخر poll (isFinal) → اطوي الجلسة في الـ baseline → GET تاني
```

---

## 2. الباكدچات والأذونات

### pubspec.yaml

```yaml
health: ^12.2.0                      # HealthKit / Health Connect
pedometer: ^4.0.1                    # عدّاد الخطوات الهاردوير
geolocator: ^13.0.2                  # GPS
flutter_activity_recognition: ^2.x   # مصنّف النشاط بتاع الـ OS (مهم للمشي)
permission_handler: ^12.0.1
uuid: ^4.5.1                         # syncId
```

### Android — `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />

<!-- Health Connect -->
<uses-permission android:name="android.permission.health.READ_STEPS" />
<uses-permission android:name="android.permission.health.READ_DISTANCE" />
<uses-permission android:name="android.permission.health.READ_TOTAL_CALORIES_BURNED" />
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED" />
<uses-permission android:name="android.permission.health.READ_HEALTH_DATA_HISTORY" />
```

جوّه `<activity>` بتاعة `MainActivity` — شاشة تبرير الأذونات (Health Connect بيرفض من غيرها):

```xml
<intent-filter>
    <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
</intent-filter>
```

وجوّه `<queries>` على مستوى الـ manifest:

```xml
<package android:name="com.google.android.apps.healthdata" />
```

`minSdk = 26` على الأقل (شرط Health Connect).

### iOS — `Info.plist`

```xml
<key>NSHealthShareUsageDescription</key>                 <string>…</string>
<key>NSHealthUpdateUsageDescription</key>                <string>…</string>
<key>NSMotionUsageDescription</key>                      <string>…</string>
<key>NSLocationWhenInUseUsageDescription</key>           <string>…</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>  <string>…</string>
```

\+ تفعيل HealthKit capability في Xcode.

---

## 3. جدول الوحدات — أهم جدول في الملف

الفرونت والباك **بيتكلموا وحدتين مختلفتين على قصد**. الباك بيخزّن بالمتر ويقسم /1000 وقت الرد.

| السياق | الحقل | الوحدة |
|--------|-------|--------|
| **قراءة** `GET .../activities/:id` | `goal` (جري) | **كيلومتر** |
| | `goal` (مشي) | **خطوة** |
| | `currentProgress` (جري) | **كيلومتر** |
| | `distanceinKm` | **كيلومتر** |
| | `durationMinutes` | **دقيقة كسرية** (`0.9` = 54 ثانية) |
| **إرسال** `POST .../sync` | `deltaDistance` | **متر** |
| | `durationSeconds` | **ثانية** |
| **جوّه الـ Cubit** | `distanceKm` | **كيلومتر** |

**غلطتين قاتلتين:**

1. ضرب `currentProgress` × 1000 عشان يقابل مسافة الجلسة → جرية 130 متر بتتعرض `130.14 / 2`.
2. `durationMinutes` تتقرا `int` → أي جلسة أقل من دقيقة بتتقص لصفر عند الـ parse نفسه.
   خليها `double?` وحوّلها لثواني: `((minutes ?? 0) * 60).round()`.

---

## 4. قاعدة الدلتا وحماية التكرار

### 4.1 كل حاجة بتتبعت **دلتا** مش إجمالي

الباك بيطبّق الحقول بـ `$inc`. لو بعت الإجمالي التراكمي هيتراكم فوق نفسه:

```
poll 1: session = 100 خطوة → ابعت 100  (server = 100) ✅
poll 2: session = 180 خطوة → ابعت 80   (server = 180) ✅
                            ابعت 180  (server = 280) ❌
```

يبقى الـ cubit لازم يمسك "علامات" لآخر حاجة **اتأكّد استلامها**:

```dart
int _lastSentSteps = 0;
double _lastSentDistanceKm = 0;
int _lastSentElapsedSeconds = 0;
```

وده يشمل **الوقت كمان** — `durationSeconds` دلتا مش إجمالي الجلسة.

### 4.2 العلامات session-relative

بتترجّع لصفر مع كل `startTracking()`، لأن قراءات الجلسة نفسها بتبدأ من صفر
(الـ baseline بيتاخد من الـ health store أول poll). مفيش حاجة بتتخزّن على الديسك ولا محتاجة.

### 4.3 المحاولة المعلّقة تتعاد **حرفياً**

لو الطلب فشل، **ماتدمجش** دلتاه في الطلب اللي بعده. امسكه بنفس الـ `syncId` وابعته زي ما هو:

```dart
String? _pendingSyncId;
int _pendingDeltaSteps = 0;
double _pendingDeltaDistanceM = 0;
int _pendingDurationSeconds = 0;
// + الأهداف اللي العلامات هتتقدّم لها لو نجح
int _pendingTargetSteps = 0;
double _pendingTargetDistanceKm = 0;
int _pendingTargetElapsedSeconds = 0;
```

السبب: لو الطلب **وصل** فعلاً وضاع الرد بس، إعادة إرساله بنفس الـ `syncId` بتخلّي
الباك يعرّفه كـ replay ومش بيطبّقه تاني. لو غيّرت المحتوى وانت ماسك نفس الـ `syncId`
الباك هيرفضه صامت والدلتا تضيع.

العلامات **مبتتقدّمش غير على `Success`**.

### 4.4 الـ syncs مسلسلة (serialised)

الـ GPS ticks والـ polls بيطلقوا syncs من غير `await`. لو اتنين اشتغلوا مع بعض،
الاتنين هيلاقوا `_pendingSyncId == null`، الاتنين هيبنوا payload، والتاني هيكتب فوق
الأول — وقبول الأول ساعتها هيقدّم العلامات فوق مسافة مااتبعتتش أصلاً.

```dart
Future<void>? _syncQueue;

Future<void> _syncToBackend({...}) {
  final Future<void> previous = _syncQueue ?? Future<void>.value();
  final Future<void> next = previous.then((_) => _runSync(...));
  _syncQueue = next.catchError((_) {});
  return next;
}
```

### 4.5 `activityItemId` مش `activityId`

`activityId` هو المرجع في الكتالوج و**مشترك بين كل عناصر النوع ده في اليوم**.
`activityItemId` هو `_id` بتاع العنصر جوّه اليوم — وهو اللي الباك بيطابق عليه.
من غيره، يوم فيه نشاطين مشي هيتحسبوا الاتنين مع كل sync.

لو رجع فاضي من الـ API: **ماتبعتش خالص** وسيب التقدّم في علامات الجلسة، فيتبعت
أول ما الـ id يوصل.

```dart
if (activityItemId.isEmpty) return;
```

---

## 5. شجرة الملفات

```
core/
  services/health_service.dart          → FitnessHealthService (غلاف health)
  utils/activity_permissions.dart       → أذونات location + motion

features/user/user_home/
  data/models/walking_sync_model.dart   → Request + Response
  data/models/running_sync_model.dart
  data/datasources/user_activities_remote_datasource.dart
  data/repositories/user_activities_repository_impl.dart
  domain/repositories/user_activities_repository.dart
  domain/usecases/sync_walking_usecase.dart
  domain/usecases/sync_running_usecase.dart
  presentation/manager/walking_cubit.dart + walking_state.dart   (part of)
  presentation/manager/running_cubit.dart + running_state.dart   (part of)
  presentation/screens/steps_details_screen.dart   → BlocProvider فقط
  presentation/screens/activity_type.dart          → enum { walking, running }
  presentation/widgets/activity/
    steps_details_loader.dart   ← بيبني الـ cubits بعد أول GET
    walking_screen.dart
    running_screen.dart
    activity_circle.dart / daily_summary_card.dart / period_tab_bar.dart
    permission_banner.dart / start_stop_button.dart / summary_item.dart
    activity_duration.dart      ← apiDurationSeconds()

features/user/visits/
  data/models/activity_details_model.dart
  presentation/manager/activity_details_cubit.dart
```

---

## 6. عقد الـ API (ناحية الفرونت)

> السلوك المطلوب من السيرفر بالتفصيل في
> [`walking_running_backend_spec.md`](walking_running_backend_spec.md).

### 6.1 قراءة

```
GET /user-activities/assessments/:assessmentId/days/:dayNumber/activities/:activityId?period=daily|weekly
```

الموديل (`ActivityDetailsData`) — لاحظ الـ fallbacks:

```dart
activityItemId:  json['activityItemId'] ?? json['_id'] ?? '',
goal:            (json['goal'] as num?)?.toDouble() ?? 0.0,
currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
isCompleted:     json['isCompleted'] as bool? ?? false,
goalReached:     json['goalReached'] ?? json['isCompleted'] ?? false,
durationMinutes: (json['durationMinutes'] as num?)?.toDouble(),   // double! مش int
caloriesBurned:  (json['caloriesBurned'] as num?)?.toDouble(),
distance:        (json['distanceinKm'] as num?)?.toDouble()
              ?? (json['distance'] as num?)?.toDouble(),          // الاسم الغريب مقصود
```

`goalReached` بيخفي زرار الـ Start (خلص هدف النهاردة).

### 6.2 إرسال — المشي

```
POST /user-activities/walking/sync
{
  "assessmentId": "…", "dayNumber": 3,
  "activityId": "…", "activityItemId": "…",
  "deltaSteps": 42,
  "deltaDistance": 31.5,      // متر
  "durationSeconds": 15,      // دلتا
  "syncId": "uuid-v4"
}
→ { "message": "…", "data": { "caloriesBurned": 12.4 } }
```

### 6.3 إرسال — الجري

نفس الحقول ناقص `deltaSteps` وزائد `isFinal`:

```
POST /user-activities/running/sync
{ …, "deltaDistance": 120.0, "durationSeconds": 30, "isFinal": false, "syncId": "uuid-v4" }
```

`isFinal: true` هو **الوحيد** اللي بيقفل نشاط الجري على السيرفر — يبقى لازم يتبعت
عند الـ stop وعند الـ `close()` حتى لو مفيش دلتا جديدة.

---

## 7. الـ State

### WalkingState

```dart
enum HealthPermStatus { unknown, notDetermined, needsInstall, denied, granted }

class WalkingState extends Equatable {
  final int steps;
  final double distanceKm;
  final double caloriesKcal;
  final int elapsedSeconds;          // ساعة إيقاف حقيقية
  final double goalSteps;
  final double goalDistanceKm;       // = 0 للمشي، مفيش هدف مسافة
  final HealthPermStatus permissionStatus;
  final bool isLoading;
  final bool isTracking;             // بين Start و Stop

  double get progressPercent => goalSteps > 0 ? (steps / goalSteps).clamp(0.0, 1.0) : 0.0;
  String get formattedTime  => …;    // mm:ss أو h:mm:ss
}
```

### RunningState

```dart
class RunningState extends Equatable {
  final bool isRunning, sessionFinished, permissionGranted;
  final double distanceKm, caloriesKcal, goalDistanceKm;
  final int steps, elapsedSeconds;

  double get progressPercent => …;
  String get formattedTime   => …;
  String get pace            => …;   // min/km أو '--:--'
}
```

`needsInstall` قيمة مهمة: على أندرويد لازم Health Connect يكون متثبّت **قبل** ما
الأذونات يبقى ليها معنى. وزرارها لازم يستدعي `promptInstall()` — مش `startTracking()` تاني،
لأن ده بيعيد نفس الفحص ويرجّع نفس الحالة من غير ما يفتح المتجر.

---

## 8. الساعة (الاتنين)

الوقت **بيتحسب من `_sessionStartedAt` مش بتراكم tick**:

```dart
void _tick() {
  final startedAt = _sessionStartedAt;
  if (startedAt == null || isClosed) return;
  emit(state.copyWith(elapsedSeconds: DateTime.now().difference(startedAt).inSeconds));
}
```

كده الوقت اللي التطبيق فيه في الخلفية بيتحسب، وأي tick ضايع مبيعملش drift.

عند الـ stop: نادي `_tick()` **قبل** الـ poll الأخير، عشان آخر ثواني توصل السيرفر
بدل ما تتقص عند آخر tick.

---

## 9. WalkingCubit — الخوارزمية

### 9.1 مصدرين للخطوات

| المصدر | المزية | العيب |
|--------|--------|-------|
| Health Store | مفلتر من المنصة نفسها | بيكتب على دفعات — على MIUI ممكن يقعد دقايق متجمّد |
| Pedometer stream | فوري | خام — بيعدّ الاهتزاز كخطوات |

الاتنين تصاعديين جوّه الجلسة، فالإجمالي = **الأكبر فيهم**:

```dart
int get _sessionSteps => math.max(_healthSessionSteps, _pedometerSessionSteps);
```

الـ Health Store بيتعمله re-baseline كل poll فمستحيل يعمل drift أو عدّ مزدوج.

### 9.2 الثوابت

```dart
static const Duration _kPollInterval          = Duration(seconds: 15);
static const int      _kMaxPendingSteps       = 60;    // سقف طابور الخطوات المؤجّلة
static const double   _kMaxStepsPerSecond     = 2.5;   // سقف الإيقاع
static const double   _kMaxStepBurst          = 10;    // سقف الرصيد المخزون
static const double   _kStrideMetres          = 0.75;  // طول الخطوة (مشي)
static const double   _kUsableAccuracyMeters  = 30;
static const double   _kMinWalkingSpeedMps    = 0.4;
static const double   _kMinDisplacementMeters = 8;
static const Duration _kFixFreshness          = Duration(seconds: 20);
static const Duration _kMovementGrace         = Duration(seconds: 12);
static const Duration _kStillnessSettle       = Duration(seconds: 12);
static const Duration _kStillSettle           = Duration(seconds: 8);
```

### 9.3 فلتر الإيقاع (token bucket)

عدّاد الخطوات بيعدّ الاهتزاز. المشي السريع ~2 خطوة/ثانية، فأي حاجة مستمرة فوق كده مش مشي.
(3.5 كان بيسيب هزّ الإيد يعدّي — اليد المهزوزة بتقع في 2–4 Hz.)

```dart
_stepAllowance = math.min(
  _stepAllowance + elapsedSeconds * _kMaxStepsPerSecond,
  _kMaxStepBurst,                       // السقف يمنع تخزين رصيد وقت الخمول
);

_pendingRawSteps = math.min(_pendingRawSteps + rawDelta, _kMaxPendingSteps);
final int credited = math.min(_pendingRawSteps, _stepAllowance.floor());
_pendingRawSteps       -= credited;
_pedometerSessionSteps += credited;
_stepAllowance         -= credited;
```

الـ queue مهم: أندرويد بيجمّع أحداث الخطوات للبطارية، فحدث واحد ممكن يشيل 20+ خطوة.
رمي الفايض كان بيضيّع خطوات حقيقية مع كل دفعة. ولما البوّابة ترفض، الطابور **بيتصفّر**
مش بيتأجّل — دي اهتزازات، ولو اتأجّلت هتتصرف أول ما المستخدم يخطي خطوة حقيقية.

### 9.4 البوّابة — مين بيقرر إن الخطوة تتحسب؟

**GPS يعلى على المصنّف.** هزّ الموبايل بحركة مشي بينتج بالظبط النمط اللي المصنّف
متدرّب عليه، فبيقول WALKING بثقة عالية ومينفعش يتكذّب بيه. الإزاحة الفيزيائية تقدر تكذّبه.

```dart
bool get _shouldRejectSteps {
  if (_hasFreshFix) return _gpsContradictsMovement;   // GPS ليه كلمة → هو الحكم
  return _activityVerdict ?? false;                   // جوّه المبنى → المصنّف
}
```

- `_hasFreshFix` — آخر fix دقيق أحدث من 20 ثانية.
- `_gpsContradictsMovement` — fix طازة ودقيق **بيقول مفيش إزاحة**:
  - لو مفيش إزاحة خالص من أول الجلسة → veto بس بعد `_kStillnessSettle` (12 ث)،
    مش فوراً، عشان خطوات بداية المشية (قبل ما تخرج من دايرة الخطأ) ماتتاكلش.
  - لو فيه إزاحة قبل كده → veto لو عدّى `_kMovementGrace` (12 ث) من آخر حركة.
- `_activityVerdict` — بيرجّع `null` (يعني "مش عارف") لو الثقة LOW أو UNKNOWN.
  بيرجّع `true` بس لو STILL/IN_VEHICLE ثابتة أكتر من `_kStillSettle` (8 ث).

**GPS هنا للتأكيد بس — مفيش أي مسافة بتتحسب منه في المشي.**

إعدادات الـ stream للمشي:

```dart
LocationSettings(accuracy: LocationAccuracy.medium, distanceFilter: 0)
```

`distanceFilter: 0` مقصود: مع فلتر، الـ stream بيسكت وانت واقف، آخر fix بيقدّم فوق
`_kFixFreshness`، والبوّابة بتفتح — وهي دي بالظبط الحالة اللي هي موجودة عشانها.
الوقوف لازم يفضل ينتج fixes عشان يبقى مُثبَت. و`medium` كفاية للسؤال "هو بيتحرك أصلاً؟"
وبتوفّر بطارية كتير عن أوضاع الملاحة.

الـ anchor **مبيتحركش** غير لما تتأكد الحركة، عشان القفزات الصغيرة تتراكم لحد ما
تتخطى دايرة الخطأ. واختبارين مستقلين لأن ولا واحد بيشتغل في كل مكان:

```dart
final bool movingBySpeed = pos.speed >= _kMinWalkingSpeedMps;   // أندرويد بيرجّع 0.0، iOS بيرجّع -1
final double metres = Geolocator.distanceBetween(anchor.latitude, anchor.longitude,
                                                 pos.latitude, pos.longitude);
final bool movingByDisplacement = metres > math.max(_kMinDisplacementMeters, anchor.accuracy);
```

### 9.5 خطوات الـ Health Store كمان بتتفلتر

الـ Health Store بيقرا نفس السنسور، فالموبايل المهزوز بيوصله برضه — وبما إن الإجمالي
بياخد الأكبر، فلترة الـ pedometer لوحدها كانت هتسيبهم يرجعوا من الباب التاني:

```dart
if (previousHealthSteps != null &&
    totalHealthSteps > previousHealthSteps &&
    _shouldRejectSteps) {
  _ignoredHealthSteps += totalHealthSteps - previousHealthSteps;
}
_healthSessionSteps =
    (totalHealthSteps - _initialHealthSteps! - _ignoredHealthSteps).clamp(0, totalHealthSteps);
```

### 9.6 المسافة

كتير من الأجهزة `DISTANCE_DELTA` بيرجع فاضي عندها → مسافة صفر مهما مشيت.

```dart
double get _sessionDistanceKm =>
    math.max(_healthSessionDistanceKm, _sessionSteps * _kStrideMetres / 1000);
```

الأكبر فيهم → الـ health store بيكسب أول ما يبلّغ فعلاً، والقيمة تفضل تصاعدية.
المسافة كمان بتتحدّث مع الخطوات بين الـ polls (`_emitLiveSteps`) بدل ما تفضل متجمّدة 15 ثانية.

`_emitLiveSteps` **forward-only** — مبتنشرش رقم أقل من اللي على الشاشة:

```dart
if (liveSteps <= state.steps) return;
```

> 0.75 متر متوسط تقريبي بيتغيّر بالطول والسرعة. لو الـ API بيرجّع طول المستخدم
> تقدر تحسبها منه بدل الرقم الثابت.

### 9.7 دورة الحياة

| الحدث | السلوك |
|-------|--------|
| `startTracking()` | تصفير **كل** متغيرات الجلسة + العلامات + `_pendingSyncId` → sensors → clock → poll فوري → timer |
| `pauseTracking()` (backgrounded) | إيقاف الـ timers والـ sensors، الجلسة **تفضل مفتوحة** |
| `resumeTracking()` | `_tick()` (بيسترجع وقت الخلفية) → clock → poll → sensors |
| `stopTracking()` | إيقاف كل حاجة → `_tick()` → `_poll(isFinal: true)` → `isTracking = false` |
| `close()` | نفس الـ stop لو `isTracking` — عشان آخر ≤15 ثانية ماتضيعش |

`_stopSensors()` بيمسح `_lastActivity` و `_stillSince`، وإلا STILL قديمة هتقفل أول
خطوات بعد الـ resume.

`resumeTracking()` بتتأكد إن `isTracking` و`permissionStatus == granted` قبل ما تشغّل
أي timer — عشان ماتلفّش على فاضي.

---

## 10. RunningCubit — الخوارزمية

### 10.1 الثوابت

```dart
static const double _kStrideMetres                = 1.0;    // خطوة الجري
static const double _kSyncThresholdKm             = 0.005;  // ابعت كل 5 متر
static const double _kMaxAcceptableAccuracyMeters = 25;
static const double _kMinMovingSpeedMps           = 0.5;
// GPS stream: accuracy: high, distanceFilter: 5
```

### 10.2 المسافة من الـ GPS

```dart
if (pos.accuracy > _kMaxAcceptableAccuracyMeters) return;   // بلاش anchor من fix مش موثوق
if (_lastPos == null) { _lastPos = pos; return; }

final double delta = _haversineKm(_lastPos!, pos);

final bool movingBySpeed        = pos.speed >= _kMinMovingSpeedMps;
final bool movingByDisplacement = delta * 1000 > pos.accuracy;
if (!movingBySpeed && !movingByDisplacement) return;   // ← الـ anchor يفضل مكانه!

if (delta < 0.15) {                                    // > 150 م في tick = fix بايظ
  _gpsDistanceKm += delta;
  emit(state.copyWith(distanceKm: _distanceFor(state.steps)));
  _maybeSyncToBackend(...);
}
_lastPos = pos;
```

**أهم سطر هنا هو الـ `return` من غير تحديث الـ anchor.** الـ stream شغّال بـ
`distanceFilter: 5` يعني كل fix بيبعد ~5 متر عن اللي قبله، ودقّة الـ fix عادة 10–25 متر —
فاختبار `delta * 1000 > pos.accuracy` مستحيل ينجح في قفزة واحدة. لو حرّكت الـ anchor
مع كل fix، الإزاحة بتبدأ من الصفر للأبد وأي جهاز مش بيبلّغ `speed` (شائع على أندرويد)
مش هيجمّع ولا متر.

Haversine:

```dart
static double _haversineKm(Position a, Position b) {
  const double r = 6371.0;
  final double dLat = _rad(b.latitude - a.latitude);
  final double dLon = _rad(b.longitude - a.longitude);
  final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) *
      math.sin(dLon / 2) * math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
}
```

### 10.3 المسافة الاحتياطية

```dart
double _distanceFor(int steps) =>
    math.max(_gpsDistanceKm, steps * _kStrideMetres / 1000);
```

لو الـ location مقفول أو المستخدم على تريدميل، الـ pedometer بيغطّي.

> ⚠️ **الجري مفيهوش فلتر إيقاع ولا GPS veto** — يعني هزّ الموبايل بيزوّد مسافة تقديرية.
> لو ده مهم في تطبيقك، انقل الـ token bucket بتاع §9.3 هنا.

### 10.4 الـ pedometer

```dart
_stepBaseline ??= total;
if (total < _stepBaseline!) _stepBaseline = total;   // الجهاز اترستَرت وسط الجلسة
final int sessionSteps = (total - _stepBaseline!).clamp(0, total);
```

العدّاد تراكمي من وقت الـ boot، فالقيمة اللي أقل من الـ baseline معناها reboot — أعد
التثبيت بدل ما ترجع بالسالب أو تتجمّد.

### 10.5 الإرسال

- بيتبعت لما `distanceKm - _lastSyncedDistanceKm >= _kSyncThresholdKm`.
- الـ `_runSync` بيفضّي المحاولة المعلّقة **الأول وبنفس محتواها**، وبس بعدها يبني جديدة.
- `isFinal` بيتبعت حتى لو الدلتا صفر.
- السعرات بتيجي من الرد: `data.caloriesBurned` → `emit`.

---

## 11. طبقة الـ UI

### 11.1 `StepsDetailsLoader` — بيبني الـ cubits بعد أول GET

الـ cubit محتاج `goal` و`activityItemId` اللي بيجوا من الـ API، فمينفعش يتبني قبله:

```dart
if (widget.type == ActivityType.running) {
  _runningCubit = RunningCubit(…, goalDistanceKm: data.goal);   // كيلومتر، بدون قسمة
} else {
  _walkingCubit = WalkingCubit(…, goalSteps: data.goal, goalDistanceKm: 0);
}
cubit.refreshPermissionStatus();   // بيقرا الأذونات من غير ما يسأل
```

`goalDistanceKm: 0` للمشي مقصود — هدف المشي عدد خطوات، مش مسافة؛ تمرير هدف الخطوات
كهدف مسافة بيطلع أرقام بلا معنى في كارت الملخص.

`refreshPermissionStatus()` مهمة: `permissionGranted` بيبدأ false على أي cubit جديد،
فمن غيرها البانر بيرجع يظهر كل مرة الشاشة تتفتح رغم إن المستخدم موافق من زمان.

### 11.2 المنع من الـ rebuild وسط الجلسة

```dart
buildWhen: (prev, curr) {
  if (_isSessionActive()) return false;     // rebuild وسط جلسة = تلويث الـ baseline
  if (curr is ActivityDetailsLoading && _initialized) return false;
  return true;
}
```

والـ listener بيحدّث `_cachedData` **من غير `setState`** لو فيه جلسة شغّالة، عشان
الداتا تبقى جاهزة لـ listeners الشاشات الفرعية من غير ما يعيد تمرير props.

### 11.3 قراءة الحالة الحالية في `initState`

الـ `ActivityDetailsSuccess` غالباً بيتبعت **قبل** ما الشاشة الفرعية تشترك في الـ cubit،
فالـ listener مبيضربش أول مرة والقيم بتفضل صفر:

```dart
final actState = widget.activityCubit.state;
if (actState is ActivityDetailsSuccess) _applyApiData(actState.data);
```

### 11.4 الـ frozen baseline

العرض = `baseline من السيرفر` + `تقدّم الجلسة الحيّة`. لازم الـ baseline يتجمّد وسط الجلسة
وإلا الـ refresh (اللي أصلاً شامل ما اتبعت) هيتجمع على الجلسة تاني:

```dart
bool _isFrozenForSession(BuildContext context) =>
    _selectedTab == 0 && context.read<WalkingCubit>().state.isTracking;

final bool showLive = _selectedTab == 0 && state.isTracking;   // ← مش distanceKm > 0
final double progress = _frozenApiProgress + (showLive ? state.steps.toDouble() : 0);
```

**`showLive` لازم تكون مربوطة بـ `isTracking` مش بـ `distanceKm > 0`** — الـ cubit
بيسيب مسافة الجلسة في الـ state بعد الـ stop، فالشرط التاني بيفضل صح والمسافة تتحسب مرتين
(جرية 0.26 كم كانت بتتعرض 0.28).

### 11.5 طيّ الجلسة في الـ baseline عند الـ Stop

```dart
await cubit.stopTracking();               // await عشان isTracking تبقى false قبل رد الـ GET
setState(() => _frozenApiProgress += cubit.state.steps.toDouble());
_refreshDetails();
```

من غير السطر ده الرقم بيقع لقيمة ما-قبل-الجلسة في اللحظة بين الـ stop والـ refresh،
وبيفضل واقع لو الـ refresh فشل. الخطوات دي متزامنة أصلاً فحسابها هنا صح، والـ refresh
بيكتب فوقها بإجمالي السيرفر.

### 11.6 قبل الـ Start: refresh الأول

```dart
await _refreshDetails();
cubit.startTracking();
```

الجلسة الجديدة بتبدأ من صفر، فـ baseline قديم هيعرض إجمالي أقل من السيرفر.

### 11.7 الخروج وسط جلسة — `PopScope`

`dispose()` مبيقدرش يعمل `await`، فالـ POST بيفضل طاير والشاشة اللي تحت بتعمل refetch
وتقرا أرقام ما-قبل-الـ sync:

```dart
PopScope(
  canPop: false,     // دايماً false — الودجت مش بيعمل rebuild وسط جلسة فالقيمة هتتقرا قديمة
  onPopInvokedWithResult: (didPop, _) async {
    if (didPop) return;
    final navigator = Navigator.of(context);
    final activityCubit = context.read<ActivityDetailsCubit>();   // قبل الـ await
    if (_isSessionActive()) await _finishSessionBeforeLeaving(activityCubit);
    if (!mounted) return;
    navigator.pop();
  },
  child: …,
)
```

و`_finishSessionBeforeLeaving` بتعمل `stopTracking()` ثم GET **يومي صراحةً** — المستخدم
ممكن يكون سايب تبويب الأسبوع مفتوح، والكروت اللي ورا الشاشة بتخصّ النهاردة.

### 11.8 دورة حياة التطبيق

```dart
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) cubit.resumeTracking();
  else if (state == AppLifecycleState.paused) cubit.pauseTracking();
}
```

### 11.9 التبويب أسبوعي

قراءة فقط — مفيش تتبّع ولا زرار start (مينفعش تعمل جلسة "للأسبوع")، والـ baseline
المجمّد بيحمي التبويب اليومي بس.

---

## 12. `ActivityDetailsCubit`

### 12.1 حارس التسلسل

كل ضغطة تبويب بتطلق GET. لو الرد القديم وصل بعد الجديد بيكتب فوقه:

```dart
int _requestSeq = 0;

Future<void> getActivityDetails(…, {String period = 'daily'}) async {
  final int seq = ++_requestSeq;
  …
  if (seq != _requestSeq) return;      // رد قديم — ارميه
  …
}
```

### 12.2 النشر على الـ Event Bus

الكروت اللي ورا الشاشة (الهوم / مهام النهاردة) بتتحدّث من غير refetch:

```dart
if (period == 'daily') _publishProgress(data.data);
```

**`daily` بس** — التبويب الأسبوعي بيرجّع تجميعة على الفترة، ونشرها هيحط خطوات أسبوع
على كارت هدفه يوم واحد.

والـ publish بيعمل fallback على الـ ids اللي الـ cubit اتنادى بيها، لأن بعض الردود
بتسيب `assessmentId` فاضي والـ listeners ساعتها مش هيلاقوا تطابق.

---

## 13. التسجيل في `get_it`

```dart
getIt.registerLazySingleton<FitnessHealthService>(() => FitnessHealthService());
getIt.registerLazySingleton<UserActivitiesRemoteDataSource>(
    () => UserActivitiesRemoteDataSourceImpl(getIt<ApiService>()));
getIt.registerLazySingleton<UserActivitiesRepository>(
    () => UserActivitiesRepositoryImpl(getIt<UserActivitiesRemoteDataSource>()));
getIt.registerLazySingleton<SyncWalkingUseCase>(() => SyncWalkingUseCase(getIt()));
getIt.registerLazySingleton<SyncRunningUseCase>(() => SyncRunningUseCase(getIt()));
getIt.registerFactory<ActivityDetailsCubit>(
    () => ActivityDetailsCubit(getActivityDetailsUseCase: getIt()));
```

الـ Walking/Running cubits **مش** مسجّلين — بيتبنوا بالإيد في الـ loader لأنهم محتاجين
بيانات من الـ API (`goal`, `activityItemId`)، والـ loader هو اللي بيقفلهم في `dispose`.

---

## 14. وجهة تانية اختيارية (سجل التحديات)

لو عندك نظام تحديات/إنجازات، نفس الأرقام بتتبعت لجهتين **مستقلتين تماماً** —
ولا واحدة بتتحسب من التانية:

- `POST /user-activities/*/sync` → تقدّم الخطة (محتاج `activityItemId`)
- `ActivitySyncService.push*()` → سجل التحديات (بيشتغل حتى لو المستخدم مالوش خطة)

**العلامات لازم تكون منفصلة** (`_ledgerSentSteps` مقابل `_lastSentSteps`): الأولى
بتتقدّم أول ما الدلتا تتسلّم للخدمة (هي اللي بتملك التوصيل والإعادة)، والتانية على
رد السيرفر بس. مشاركتهم كانت هتوقف تغذية التحديات لنفس المستخدمين اللي الفيتشر
موجود عشانهم (اللي مالهمش خطة، وبالتالي مالهمش `activityItemId`).

كمان: الجري **مبيبعتش خطوات** للسجل — الباك بيقرا الخطوات لـ `walking` بس وبيرميها
تحت `running`. التفاصيل في [`achievements_api_request.md`](achievements_api_request.md).

---

## 15. تشيك ليست قبل ما تقول خلصت

- [ ] `deltaDistance` بالمتر، القراءة بالكيلومتر
- [ ] `durationMinutes` بتتقرا `double?` مش `int?`
- [ ] `durationSeconds` دلتا مش إجمالي
- [ ] `distanceinKm` (بالاسم الغريب ده) قبل `distance`
- [ ] `activityItemId` مش `activityId` في الـ sync
- [ ] الـ `syncId` بيتعاد حرفياً مع المحتوى نفسه لو فشل
- [ ] العلامات مبتتقدّمش غير على `Success`
- [ ] الـ syncs مسلسلة بـ `_syncQueue`
- [ ] `showLive` مربوطة بـ `isTracking` مش بـ `> 0`
- [ ] الجلسة بتتطوى في الـ baseline عند الـ stop
- [ ] `close()` بيعمل sync نهائي لو الجلسة شغّالة
- [ ] `isFinal: true` بيتبعت للجري حتى بدلتا صفر
- [ ] `refreshPermissionStatus()` بتتنادى عند بناء الـ cubit
- [ ] زرار `needsInstall` بيستدعي `promptInstall()`
- [ ] الـ GPS anchor **مبيتحركش** لما الحركة مش مؤكدة
- [ ] `_publishProgress` على `daily` بس
- [ ] `initState` بيقرا حالة الـ activityCubit الحالية

---

## 16. ترتيب التنفيذ المقترح

1. الأذونات + الباكدچات + `FitnessHealthService` — واختبرها على جهاز فيه Play Store.
2. طبقة الداتا: models → datasource → repository → usecases → DI.
3. `ActivityDetailsCubit` + الموديل (حارس التسلسل من الأول، مش بعدين).
4. `RunningCubit` — أبسط، وبيثبت عقد الـ sync كامل.
5. `RunningScreen` بالـ frozen baseline.
6. `WalkingCubit` بالمصدرين + الساعة، **من غير** فلاتر الاهتزاز.
7. `WalkingScreen`.
8. فلاتر الاهتزاز (token bucket → GPS gate → activity classifier) — واحدة واحدة،
   كل واحدة بـ `debugPrint` للبوابة زي اللي في الكود:
   ```
   [Walking] gate: reject=…  gps=…  activity=…/…  pedometer=…  health=…  ignored=…
   ```
9. `PopScope` + دورة حياة التطبيق + سجل التحديات (لو موجود).

---

## 17. ملاحظات اختبار بيئي

- محاكي/جهاز من غير Play Store → Health Connect مش هيتثبّت
  (`GooglePlayServicesUtil: requires the Google Play Store, but it is missing`).
  لازم موبايل حقيقي.
- الـ location مقفول → مسافة الجري صفر، والبوّابة في المشي بتفتح وتسيب المصنّف يحكم.
- الأرقام بتاخد لحظات تظهر على iOS: HealthKit بيكتب على دفعات زيّه زي Health Connect.

# مراجعة تحديات المشي والجري — ملخص

> ملف توثيقي لآخر جلسة مراجعة لشاشة تتبّع المشي/الجري (`StepsDetailsScreen`) والـ cubits المرتبطة بيها.
> بيغطّي: الحلول اللي اتطبّقت فعلاً، والمشاكل المتبقية مقسّمة بين **الباك إند** و**الفرونت إند**.

---

## 1. الملفات المعنية

| الملف | الدور |
|-------|-------|
| [`steps_details_screen.dart`](../lib/features/user/user_home/presentation/screens/steps_details_screen.dart) | شاشة المشي/الجري + الدائرة + كارت الملخص + الأزرار |
| [`walking_cubit.dart`](../lib/features/user/user_home/presentation/manager/walking_cubit.dart) | تتبّع المشي (Health store + pedometer + GPS corroboration) |
| [`running_cubit.dart`](../lib/features/user/user_home/presentation/manager/running_cubit.dart) | تتبّع الجري (GPS Haversine + pedometer + ساعة) |
| [`activity_details_cubit.dart`](../lib/features/user/visits/presentation/manager/activity_details_cubit.dart) | جلب بيانات النشاط من الـ API (يومي/أسبوعي) |
| [`activity_details_model.dart`](../lib/features/user/visits/data/models/activity_details_model.dart) | موديل استجابة الـ API |
| [`health_service.dart`](../lib/core/services/health_service.dart) | غلاف HealthKit / Health Connect |

---

## 2. الحلول اللي اتطبّقت ✅

### 2.1 زر تثبيت Health Connect مش بيعمل حاجة
- **السبب:** لما الحالة `needsInstall`، زر "السماح" كان بيستدعي `startTracking()` تاني — اللي بيعيد نفس الفحص ويرجع `needsInstall` من غير ما يفتح المتجر.
- **الحل:** أضيفت `installHealthConnect()` في `WalkingCubit` بتستدعي `promptInstall()` (بتفتح المتجر فعلاً)، وربطت بيها زر البانر.

### 2.2 الهدف بيظهر 0 والنسبة 0% وإنت خامل
- **السبب:** الـ `ActivityDetailsSuccess` بيتبعت **قبل** ما الشاشة الفرعية تشترك في الـ cubit، فالـ `BlocConsumer` listener مبيضربش أول مرة والقيم بتفضل على صفر (`_frozenApiGoal = 0`).
- **الحل:** في `initState` (للمشي والجري) بقيت أقرأ `widget.activityCubit.state`، ولو `ActivityDetailsSuccess` أطبّق `_applyApiData(...)` فوراً.

### 2.3 الخروج وسط جلسة مشي بيضيّع آخر خطوات
- **السبب:** `WalkingCubit.close()` كان بيلغي التايمرز/السنسورز من غير قراءة/sync نهائية (عكس `RunningCubit`).
- **الحل:** `close()` بقى يعمل `await _poll()` لو `state.isTracking` قبل `super.close()`، فآخر ≤30 ثانية خطوات بتتزامن.

### 2.4 تبديل يومي/أسبوعي السريع ممكن يعرض بيانات غلط (race condition)
- **السبب:** كل ضغطة بتطلق GET؛ لو رد الطلب القديم وصل بعد الجديد، بيكتب فوقه.
- **الحل:** حارس تسلسل `_requestSeq` في `ActivityDetailsCubit` — أي رد قديم (`seq != _requestSeq`) بيتجاهل، فآخر ضغطة هي اللي تكسب دايماً.

---

## 3. المشاكل المتبقية

### 🔴 من عند الباك إند (الأهم)

#### 3.1 النشاط بيتحسب "مكتمل" وهو صفر
مثال من اللوج الفعلي:
```json
{
  "goal": 1000,
  "currentProgress": 0,
  "distance": 0,
  "caloriesBurned": 0,
  "isCompleted": true   // ← مكتمل من غير أي جري
}
```
- الجري متسجّل `isCompleted: true` رغم إن التقدّم والمسافة = 0.
- الباك بيقفل النشاط بمجرد استلام `isFinal: true` بغض النظر عن الهدف.
- **المطلوب:** الاكتمال يتحدّد بالوصول للهدف (`currentProgress >= goal`)، مش بمجرد استلام sync نهائي.

#### 3.2 عدم تطابق وحدة الهدف
- الباك بيبعت `goal: 1000` (بالمتر) بس `unit: "كم"`.
- الفرونت مضطر يخمّن بعتبة هشّة (`_kRunningGoalMetresThreshold = 100`)؛ بتنكسر لو الهدف أقل من 100 متر.
- **المطلوب:** الباك يبعت الهدف بنفس وحدة العرض، أو يضيف حقل `goalUnit` واضح، ويكون التقدّم بنفس الوحدة.

#### 3.3 `durationMinutes` بتتضخّم
- كل `isFinal` sync (حتى بمسافة 0) بيزوّد المدة على الباك (`0.38 → 0.43` في اللوج).
- تكرار play/stop من غير حركة بيرفع الدقايق.
- **المطلوب:** الباك ميزوّدش وقت لو مفيش تقدّم فعلي.

#### 3.4 تأكيد `syncId` (idempotency)
- الفرونت بيبعت `syncId` معتمداً إن الباك بيرفض التكرار (replay protection).
- **المطلوب:** تأكيد إن ده متطبّق فعلاً، وإلا أي إعادة إرسال ممكن تتحسب مرتين.

### 🟡 من عند الفرونت إند

#### 3.5 تبديل يومي↔أسبوعي وسط جلسة شغالة بيلخبط الـ baseline
- سيناريو: بدأت جلسة → دوست "أسبوعي" → رجعت "يومي".
- الـ listener بيطبّق بيانات الأسبوع على `_frozenApiProgress` (لأن `_isFrozenForSession` بترجع false على تبويب الأسبوع)، وبعد الرجوع لليومي القيمة الأسبوعية بتفضل موجودة → العرض اليومي = baseline أسبوعي + خطوات الجلسة.
- **الحل المقترح:** فصل baseline خاص باليومي مايتكتبش فوقه من بيانات الأسبوع. (حالة حافة)

#### 3.6 المشي مبيعرضش كارت الملخص وهو خامل
- كارت الملخص (سعرات/دقايق/مسافة) بيظهر بس أثناء التتبع، بينما الجري بيعرضه دايماً — عدم اتساق.
- **الحل المقترح:** عرض ملخص اليوم للمشي من الـ API حتى قبل بدء الجلسة.

#### 3.7 `comparedToPreviousDay` مش مستخدم
- الباك بيرجّع `{type: less, value: 100}` والفرونت بيتجاهله.
- **الحل المقترح:** لو المفروض يتعرض ("أقل بـ 100 عن أمس")، ده feature ناقص.

#### 3.8 المدد الأقل من دقيقة بتتعرض "0 دقيقة"
- بسبب `.toInt()` على `durationMinutes` الكسرية.
- **الحل المقترح:** عرض بالثواني أو تقريب مناسب.

---

## 4. ملاحظات بيئة (مش مشاكل كود)

من اللوج على الجهاز المستخدم في الاختبار:
- `GooglePlayServicesUtil: requires the Google Play Store, but it is missing` → الجهاز **مفيهوش Play Store**، فتثبيت Health Connect مش هيشتغل عليه — لازم موبايل حقيقي فيه Play Store.
- `RunningCubit GPS error: The location service on the device is disabled` → **الـ location مقفول**، عشان كده المسافة بتفضل 0.
- خطأ `MediaCodecVideoRenderer / ExoPlayer` بتاع فيديو التمرين — codec الجهاز فشل يفك ترميز الفيديو، حاجة منفصلة تماماً عن تحدي المشي/الجري.

---

## 5. الأولويات المقترحة

1. **باك — 3.1** (الاكتمال بصفر) — بتكسر منطق التحدي نفسه.
2. **فرونت — 3.5** (تلوّث baseline عند تبديل التبويب وسط جلسة).
3. **فرونت — 3.6** (اتساق كارت الملخص للمشي).
4. **باك — 3.2 / 3.3 / 3.4** (وحدات الهدف، تضخّم المدة، idempotency).
5. **فرونت — 3.7 / 3.8** (تحسينات عرض).

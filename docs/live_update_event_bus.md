# التحديث الفوري للكروت — AppEventBus

> الملف ده بيشرح المشكلة، الحل، وإزاي تضيف حاجة جديدة عليه لوحدك.
> الكود: [`lib/core/services/app_event_bus.dart`](../lib/core/services/app_event_bus.dart)

---

## 1. المشكلة

نفس العنصر بيتعرض في أكتر من شاشة، بس بيتعدّل في شاشة تالتة فوقيهم.

مثال حقيقي من المشروع — نشاط "المشي":

```
HomePage                      ← كارت المشي (من /user-home)
  └─ UserTodayTasksPage       ← نفس كارت المشي (من /daily-tasks/days/1)
       └─ StepsDetailsScreen  ← هنا اليوزر بيمشي والرقم بيتغيّر
```

لما اليوزر يرجع، الكارت في الشاشتين اللي تحت بقى قديم.

### الحلول اللي كانت موجودة وليه مش كويسة

| الحل | المشكلة |
|---|---|
| `Navigator.pop(result)` | بيوصل للشاشة الأب **بس**. `HomePage` اللي تحت `UserTodayTasksPage` تفضل قديمة |
| refetch كامل بعد الرجوع | ريكوست (أو اتنين) + shimmer + السكرول بيرجع لفوق، كل ده عشان رقم واحد اتغيّر |
| refetch في كل شاشة | كل شاشة لازم تفتكر تعمله، ولو نسيت واحدة تفضل قديمة (ده بالظبط اللي حصل مع الوجبات في `VisitCustomPlanTab`) |
| Singleton Cubit للكل | بيربط شاشات ببعضها معماريًا ومش بيوصل للي بيرندر من موديل مختلف |

### الجذر

الشاشة اللي بتعدّل الداتا **مش شايفة** الشاشات اللي تحتها، والشاشات اللي تحت مش عارفة إن في حاجة اتغيرت. محتاج قناة تربطهم من غير ما يعرفوا بعض.

---

## 2. الحل: Publish / Subscribe

```
       ┌──────────────────────┐
       │   شاشة التفاصيل      │
       │  (عدّلت + السيرفر    │
       │   أكّد القيمة)       │
       └──────────┬───────────┘
                  │ publish(event)
                  ▼
         ┌────────────────┐
         │  AppEventBus   │  ← singleton، broadcast stream
         └───┬────┬────┬──┘
             │    │    │  كل مستمع بياخد نسخة
    ┌────────┘    │    └────────┐
    ▼             ▼             ▼
UserHomeCubit  TodayTasks   DietPlanCubit
   patch         patch          patch
```

**القاعدة الأساسية:** الـ event بيحمل **قيمة السيرفر أكّدها**، مش قيمة محسوبة محليًا.

ليه؟ لأن الـ patch بيعدّل الـ state من غير ما يسأل السيرفر. لو حطيت قيمة متخيلة، الشاشة هتبعد عن الحقيقة (drift) ومحدش هيكتشف غير لما اليوزر يعمل refresh.

**ومع ذلك مش بندفع أي ريكوست زيادة** — لأن كل القيم دي جاية من ردود ريكوستات شاشة التفاصيل كانت هتعملها أصلاً:

| المصدر | الرد بيحمل إيه |
|---|---|
| `PATCH .../meals/:id` (إكمال وجبة) | `isCompleted` |
| `POST .../sets/:n/complete` | `completedSets`, `totalSets`, `isCompleted` |
| `GET .../activities/:id` | `currentProgress`, `goal`, `isCompleted` |
| `GET /articles/:id` | `viewsCount` بعد الزيادة, `isSaved` |
| `POST /articles/:id/save` | `isSaved` |

---

## 3. مكونات الحل

### 3.1 الـ Events

```dart
sealed class AppEvent {}

sealed class TaskProgressEvent extends AppEvent {
  final String assessmentId;   // ← للمطابقة
  final int dayNumber;         // ← للمطابقة
  String get taskId;
  bool get isCompleted;
}

class MealProgressChanged     extends TaskProgressEvent { ... }
class WorkoutProgressChanged  extends TaskProgressEvent { ... }
class ActivityProgressChanged extends TaskProgressEvent { ... }

class ArticleChanged extends AppEvent {
  final String articleId;
  final int? views;      // nullable — كل ناشر يبعت اللي عرفه بس
  final bool? isSaved;
}
```

**`sealed`** عشان الـ `switch` يبقى exhaustive — لو ضفت نوع جديد، الـ compiler هيوقفك عند كل مستمع ناسي يعالجه. ده أهم سطر أمان في التصميم كله.

**`views` و `isSaved` nullable** لأن مين بيبعت إيه بيختلف: ضغطة البوكمارك مابتقولش حاجة عن عدد المشاهدات، ولو بعتّ الرقم القديم معاها هتلغي قراءة أحدث.

**الـ events بتحمل ids و primitives بس — عمرها ما تحمل entity من `features/`.** الملف ده في `core/`، و`core` مالوش يعرف حاجة عن `features`. أول نسخة كتبتها كان فيها `ArticleData? article` عشان `SavedArticlesCubit` يقدر يضيف صف جديد، وده خلّى `core` يـ import من `features` — كسر ترتيب الطبقات، ولخبط الـ analysis server بتاع VS Code لدرجة إنه قال "الملف مش موجود" على ملف موجود فعلاً.

البديل: المستمع اللي محتاج الـ entity كامل يعمل `silent refetch` (نفس القاعدة 3 تحت).

### 3.2 الـ Bus

```dart
class AppEventBus {
  final _controller = StreamController<AppEvent>.broadcast();
  Stream<AppEvent> get stream => _controller.stream;
  void publish(AppEvent e) { if (!_controller.isClosed) _controller.add(e); }
}
```

**`.broadcast()` إجباري** — `StreamController` العادي بيسمح بمستمع واحد بس وبيرمي exception على التاني. وإحنا عندنا 5+ شاشات ممكن تكون مكدّسة فوق بعض وكلها سامعة.

مسجّل `registerLazySingleton` في `injection_container.dart` — الناشر والمستمع عمرهم ما بيتقابلوا، الحاجة الوحيدة المشتركة بينهم هي الـ instance ده.

### 3.3 النشر

```dart
// جوه MealDetailsCubit
case Success(:final data):
  final confirmed = data.data?.isCompleted ?? isCompleted;
  emit(MealDetailsSuccess(updatedData));
  getIt<AppEventBus>().publish(MealProgressChanged(
    assessmentId: assessmentId,
    dayNumber: dayNumber,
    mealId: mealId,
    isCompleted: confirmed,   // ← من رد السيرفر
  ));
```

### 3.4 الاستماع

```dart
class UserHomeCubit extends Cubit<UserHomeState> {
  late final StreamSubscription<AppEvent> _progressSub;

  UserHomeCubit(...) : super(UserHomeLoading()) {
    _progressSub = getIt<AppEventBus>().stream.listen(_applyProgressEvent);
  }

  @override
  Future<void> close() {
    _progressSub.cancel();   // ← نسيانه = memory leak + emit بعد الإغلاق
    return super.close();
  }
```

---

## 4. الـ 6 قواعد اللي لازم تمشي عليها

### القاعدة 1 — تحقق من السياق قبل أي patch

```dart
if (dailyTasks.assessmentId != event.assessmentId ||
    dailyTasks.dayNumber != event.dayNumber) {
  return;
}
```

اليوزر ممكن يكون فاتح يوم 4 في `UserTodayTasksPage` والحدث بتاع يوم 5. من غير الشرط ده هتحط داتا يوم على يوم تاني.

### القاعدة 2 — لو مفيش مطابقة، **ماتعملش emit**

```dart
if (index == -1) return tasks;   // نفس الـ instance
```

لو رجّعت list جديدة بنفس المحتوى، `BlocBuilder` هيعيد بناء الصفحة كلها على الفاضي — وده بيحصل مع **كل** حدث في التطبيق، حتى الأحداث اللي مالهاش علاقة بالشاشة دي.

### القاعدة 3 — لو المطابقة غامضة، refetch صامت بدل ما تخمّن

ده أهم درس اتعلمناه من داتا فعلية. رد `/user-assessments/:id/details?dayNumber=1`:

```json
{ "type": "activity", "activityId": "6a4e...544", "currentProgress": 117 },
{ "type": "activity", "activityId": "6a4e...544", "currentProgress": 0 }
```

**نفس الـ `activityId` مرتين في نفس اليوم.** السيرفر بيفرّق بينهم بـ `activityItemId` (شوف `WalkingSyncRequestModel`) بس الـ payload ده مابيرجّعوش.

يعني مفيش طريقة من الفرونت أعرف الحدث بتاع أنهي كارت. لو عملت patch لأول واحد، هتحط تقدّم عنصر على عنصر تاني:

```dart
if (matches.length > 1) {
  getDayDetails(event.assessmentId, event.dayNumber, silent: true);
  return;
}
```

**الدرس العام:** الـ patch أسرع من الـ refetch، بس الـ refetch أضمن. لما تكون مش متأكد → refetch. الحالة الغامضة نادرة، فالمكسب في الحالة العادية مش بيضيع.

### القاعدة 4 — أي refetch من عندك لازم يكون `silent`

```dart
Future<void> loadTasks({int dayNumber = 1, bool silent = false}) async {
  if (!silent) emit(UserTodayTasksLoading());   // مافيش spinner
  ...
  } catch (e) {
    if (!silent) emit(UserTodayTasksError(...)); // ومافيش شاشة خطأ
  }
}
```

اليوزر ماطلبش الـ refetch ده — هو بيقرأ الصفحة. يبقى ماينفعش تختفي قدامه، ولا تتحول لشاشة خطأ لو النت وقع في اللحظة دي. المحتوى القديم أحسن من لا شيء.

نفس المنطق ينطبق على pull-to-refresh: الـ `RefreshIndicator` بيرسم spinner بتاعه، فالـ shimmer فوقيه بيعمل flash وحش.

### القاعدة 5 — انشر اللي السيرفر أكّده بس

```dart
// ✅
final confirmed = data.data?.isCompleted ?? isCompleted;
publish(MealProgressChanged(isCompleted: confirmed));

// ❌ optimistic — الشاشة هتبعد عن الحقيقة لو الطلب فشل
publish(MealProgressChanged(isCompleted: !currentValue));
```

وانتبه للسياق كمان — في `ActivityDetailsCubit`:

```dart
if (period == 'daily') _publishProgress(data.data);
```

تبويب "أسبوعي" بيرجّع مجموع الأسبوع. لو نشرته، هتحط خطوات أسبوع على كارت هدفه يوم واحد.

### القاعدة 6 — الويدجت اللي ماسك state محلية لازم يتابع الأب

الكروت بتاعة المقالات كانت بتاخد نسخة في `initState`:

```dart
late bool _isSaved;
void initState() { _isSaved = widget.article.isSaved; }
```

`initState` مابيتنداهش تاني لما الأب يعيد البناء بداتا جديدة. فالكيوبت يتعمله patch والكارت يفضل يعرض القديم. الحل:

```dart
@override
void didUpdateWidget(ArticleListCard old) {
  super.didUpdateWidget(old);
  if (!_isLoading && widget.article.isSaved != old.article.isSaved) {
    _isSaved = widget.article.isSaved;
  }
}
```

`!_isLoading` مهم — من غيره، لو حدث وصل وطلب المستخدم لسه شغال، هيرجع الأيقونة لورا قدام عينه.

---

## 5. اللي اتغيّر فعليًا في المشروع

### الملفات الجديدة
| الملف | الدور |
|---|---|
| `lib/core/services/app_event_bus.dart` | الـ bus + كل الـ events |

### الناشرون (5)
| الملف | بينشر |
|---|---|
| `visits/.../activity_details_cubit.dart` | `ActivityProgressChanged` — **بيغطي المياه والمشي والجري** لأنه الـ hub الوحيد للتلاتة |
| `visits/.../meal_details_cubit.dart` | `MealProgressChanged` |
| `workout/.../workout_details_cubit.dart` | `WorkoutProgressChanged` |
| `user_home/.../article_detail_page.dart` | `ArticleChanged` (views + isSaved) |
| `articles/article_list_card.dart`, `related_article_card.dart`, `saved_articles_cubit.dart` | `ArticleChanged` (isSaved) |

### المستمعون (7)
| الكيوبت | بيعمل patch لإيه |
|---|---|
| `UserHomeCubit` | كارت الوجبة/التمرين في `tasks` + كارت النشاط في `homeData.dailyTasks.currentActivity` + شريط المقالات |
| `UserTodayTasksCubit` | التلات قوايم (`foodTasks` / `exerciseTasks` / `activityTasks`) |
| `AssessmentDetailsCubit` | الـ raw map جوه `_dayData['tasks']` |
| `DietPlanCubit` | `MealItem.isCompleted` |
| `WorkoutPlanCubit` | عدّاد الـ sets |
| `ArticlesListCubit` | `views` + `isSaved` |
| `SavedArticlesCubit` | بيضيف/بيشيل صف (مش patch) |

### الـ refetch اللي اتشال
- `home_page_content.dart` — بعد الرجوع من شاشة النشاط
- `user_today_tasks_content.dart` — `_openActivity`
- `visit_custom_plan_tab.dart` — بعد الرجوع من شاشة النشاط
- `diet_plan_page.dart` — بعد الرجوع من تفاصيل الوجبة

### حاجات اتصلحت في الطريق
- `article_detail_page.dart` كان بيجيب المقال من السيرفر (وده اللي بيزوّد الـ views) بس بيعرض الرقم القديم اللي جه من القايمة. دلوقتي بيعرض اللي رجع.
- الخروج من شاشة المشي من غير Stop مكانش بيعمل publish. اتظبط في `steps_details_loader.dart` بـ GET واحد بعد إنهاء الجلسة.

---

## 6. المكسب

| الموقف | قبل | بعد |
|---|---|---|
| رجوع من شاشة نشاط للهوم | `/user-home` + `/articles` + shimmer + السكرول لفوق | صفر ريكوست، كارت واحد |
| تعليم وجبة | الهوم وخطة الوجبات مكانوش بيتحدثوا خالص | صفر ريكوست، فوري |
| إنهاء سِت تمرين | خطة التمارين مكانتش بتتحدث | صفر ريكوست، فوري |
| فتح مقال | عدد الـ views مكانش بيتحدث في أي قايمة (ولا في صفحة التفاصيل نفسها) | صفر ريكوست |
| حفظ مقال | الأيقونة بتتغير في مكان واحد بس | كل الأماكن مع بعض |
| شاشات مكدّسة فوق بعض | اللي عملت push بس | كلهم في نفس اللحظة |

---

## 7. إزاي تضيف حدث جديد — 5 خطوات

مثال: عايز عدّاد السلة يتحدّث في كل مكان لما تضيف منتج.

**1. عرّف الحدث** في `app_event_bus.dart`:
```dart
class CartCountChanged extends AppEvent {
  final int itemCount;
  CartCountChanged({required this.itemCount});
}
```

**2. انشره** من المكان اللي السيرفر أكّد فيه:
```dart
case Success(:final data):
  emit(CartSuccess(data));
  getIt<AppEventBus>().publish(CartCountChanged(itemCount: data.items.length));
```

**3. اشترك** في أي كيوبت محتاج يعرف:
```dart
late final StreamSubscription<AppEvent> _eventSub;

MyCubit(...) : super(...) {
  _eventSub = getIt<AppEventBus>().stream.listen(_applyEvent);
}

@override
Future<void> close() { _eventSub.cancel(); return super.close(); }
```

**4. اعمل الـ patch** — مع كل القواعد:
```dart
void _applyEvent(AppEvent event) {
  if (event is! CartCountChanged) return;          // القاعدة: فلتر النوع
  final current = state;
  if (current is! MyLoaded) return;
  if (current.count == event.itemCount) return;    // القاعدة 2: مفيش تغيير = مفيش emit
  emit(current.copyWith(count: event.itemCount));
}
```

**5. شيل الـ refetch** اللي كان بيغطي المشكلة دي.

### قايمة مراجعة سريعة
- [ ] القيمة جاية من رد السيرفر مش محسوبة محليًا؟
- [ ] الحدث بيحمل ids/primitives بس، مفيش entity من `features/`؟
- [ ] `_eventSub.cancel()` في `close()`؟
- [ ] فيه فلتر نوع في أول الـ handler؟
- [ ] فيه شرط سياق (يوم / assessment / id)؟
- [ ] لو مفيش مطابقة، بترجع من غير `emit`؟
- [ ] لو المطابقة غامضة، بتعمل refetch صامت؟
- [ ] الويدجتس اللي ماسكة state محلية عندها `didUpdateWidget`؟

---

## 8. لو الـ IDE قال لك "الملف مش موجود" وهو موجود

حصل معانا فعلاً. VS Code كان بيقول:

```
Target of URI doesn't exist: '.../article_data.dart'
Undefined class 'ArticleData'
```

والملف موجود عادي. أول حاجة تعملها: شغّل الـ analyzer من التيرمنال

```bash
flutter analyze lib/path/to/file.dart
```

- **لو التيرمنال قال `No issues found`** → الـ analysis server بتاع الـ IDE بايت.
  `Ctrl+Shift+P` → **Dart: Restart Analysis Server**
- **لو التيرمنال طلّع نفس الخطأ** → الخطأ حقيقي، صلّحه.

في حالتنا التيرمنال كان نضيف، بس السبب اللي خلّى الـ server يتلخبط كان حقيقي: import من `core/` لـ `features/`. الـ IDE بيقفل حاجات كتير على بعض لما اتجاه الاعتماديات يتعكس. **خد التحذير بجدية حتى لو الـ CLI ساكت.**

---

## 9. امتى **ماتستخدمش** الباترن ده

- **الداتا اللي أول ما تظهر لازم تكون كاملة** — الـ bus بيحدّث اللي موجود، مش بيجيب حاجة جديدة. أول تحميل يفضل ريكوست عادي.
- **لما الرد مايحملش القيمة الجديدة** — ساعتها الـ patch هيبقى تخمين. استخدم `silent refetch` بدلاً منه.
- **قوايم بتتغير كتير قوي** (تشات مثلاً) — دي عايزة WebSocket مش bus محلي.
- **حاجة الـ Cubit الواحد يقدر يعملها لوحده** — لو الشاشة الوحيدة اللي محتاجة تعرف هي اللي عملت التعديل، عدّل الـ state عندك على طول. الـ bus للتواصل **بين** شاشات مش شايفة بعض.

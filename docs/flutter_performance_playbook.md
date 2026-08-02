# دليل الأداء في Flutter — مطبَّق على FitnessDay

> مش شرح نظري عام. كل قاعدة هنا معاها **مثال حقيقي من الكود بتاعنا**: إيه اللي عاملينه صح فعلاً، وإيه اللي بيكلّفنا، وإيه الـ before/after.

---

## 1. الموديل الذهني: إيه اللي بيحصل في الفريم الواحد

الشاشة بتتحدّث 60 مرة في الثانية (أو 120 على أجهزة أسرع). يعني عندك **16.6ms** لكل فريم. لو الفريم اتأخّر، المستخدم بيشوف "jank" (تهزيز/تقطيع).

الشغل ده مقسوم على **خيطين** بيشتغلوا بالتوازي:

| الخيط | بيعمل إيه | إيه اللي بيبطّئه |
|-------|-----------|------------------|
| **UI (Dart)** | ينفّذ `build()` → `layout` → `paint` (تسجيل أوامر رسم) | rebuild كتير، شجرة عميقة، حسابات تقيلة، JSON parsing |
| **Raster (GPU)** | يحوّل أوامر الرسم لبكسل فعلي | `Opacity`, `ClipPath`, الظلال، الـ blur، الصور الكبيرة، `saveLayer` |

**القاعدة الذهبية:** لازم تعرف الأول الجank ده من أنهي خيط، لأن العلاج مختلف تماماً. تصليح rebuilds مش هيفيد لو المشكلة في الراستر، والعكس صحيح.

كل فريم في خيط الـ UI بيمرّ بـ 3 مراحل:

```
build()   → بيبني الـ Widgets (كائنات وصف رخيصة)
layout()  → بيحدّد المقاسات والمواقع (RenderObjects)
paint()   → بيسجّل أوامر الرسم في طبقات (Layers)
```

الحاجة المهمة: **الـ Widget مش هو اللي غالي.** إنشاء `Text()` رخيص جداً. الغالي هو إن الـ Framework يقارن ويعيد الـ layout والـ paint لشجرة كبيرة من غير داعي.

---

## 2. إزاي تقيس — مش تخمّن

### 2.1 لازم profile mode

```bash
flutter run --profile
```

الـ debug mode **بطيء بشكل مقصود** (assertions + JIT + كل الـ debugging hooks). أي قياس في debug مالوش أي معنى. والـ release مافيهوش أدوات القياس. يبقى `--profile` هو المكان الوحيد.

وكمان: قيس على **أضعف جهاز عند جمهورك**، مش على جهازك. جهاز فلاجشيب بيخفي كل مشاكلك.

### 2.2 أوفرلاي الأداء

```bash
flutter run --profile --dart-define=x=y
```
وبعدين من DevTools فعّل **Performance Overlay**. هتشوف رسمين بيانيين:

- **الرسم الفوقاني = خيط الراستر (GPU)**
- **الرسم التحتاني = خيط الـ UI**

أي شريط أخضر بيعدّي الخط الأحمر = فريم اتأخّر. شوف مين الاتنين اللي بيعدّي — ده بيحدّد اتجاه التصليح كله.

### 2.3 أدوات DevTools اللي هتستخدمها فعلاً

| الأداة | بتجاوب على إيه |
|--------|----------------|
| **Performance → Frame chart** | أنهي فريم اتأخّر وليه (build/layout/raster) |
| **Track Widget Builds** | أنهي widget بيتعاد بناؤه وكام مرة |
| **CPU Profiler (flame chart)** | أنهي دالة بتاكل وقت الـ UI thread |
| **Memory → Dart heap** | تسريبات وذاكرة الصور |
| **Rebuild counts** | الرقم اللي جنب الويدجت في الـ inspector |

**نصيحة عملية:** ابدأ دايماً من الـ Frame chart. لو الفريم أحمر بسبب `Build` → روح على rebuilds. لو بسبب `Raster` → روح على الصور/الـ Opacity/الظلال.

---

## 3. اللي إحنا عاملينه صح فعلاً ✅ (خليها كقدوة)

### 3.1 القوايم الكسولة — `ListView.builder`

[`chat_messages_list.dart:38`](../lib/features/shared/conversations/presentation/widgets/chat/chat_messages_list.dart#L38)

```dart
return ListView.builder(
  controller: controller,
  reverse: true,
  itemCount: messages.length + _headCount + _tailCount,
  itemBuilder: (context, rawIndex) { ... },
);
```

**ليه ده مهم:** محادثة فيها 500 رسالة → `ListView.builder` بيبني الظاهر على الشاشة بس (حوالي 10-15 فقاعة) وبيتخلّص من اللي خرج بره. لو كانت `ListView(children: [...])` كنا هنبني 500 فقاعة + 500 نص + 500 صورة قبل ما الشاشة تظهر أصلاً.

نفس الكلام في الجريد: [`market_products_grid.dart:36`](../lib/features/user/market/presentation/widgets/market_products_grid.dart#L36) بيستخدم `SliverGrid` + `SliverChildBuilderDelegate` — وده أحسن من `GridView` عادي جوه `SingleChildScrollView`.

### 3.2 تحديد نطاق الـ rebuild — `buildWhen`

[`walking_screen.dart:278`](../lib/features/user/user_home/presentation/widgets/activity/walking_screen.dart#L278)

```dart
buildWhen: (prev, curr) {
  if (_isFrozenForSession(context)) return false;
  return curr is ActivityDetailsSuccess || curr is ActivityDetailsFailure;
},
```

**ليه ده مهم جداً هنا تحديداً:** [`walking_cubit.dart:416`](../lib/features/user/user_home/presentation/manager/walking_cubit.dart#L416) بيعمل `emit` **كل ثانية**:

```dart
_clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
```

من غير `buildWhen` كنا هنعيد بناء شاشة المشي بالكامل 60 مرة في الدقيقة — بما فيها الأجزاء اللي مش بتتغيّر أصلاً.

### 3.3 عزل الصور في طبقة رسم لوحدها

[`app_image.dart:181`](../lib/core/widgets/app_image.dart#L181)

```dart
return RepaintBoundary(
  child: _flipIfLtr(_clip(_gradient(_align(image))), context),
);
```

`RepaintBoundary` بيقول للـ engine: "الحتة دي طبقة مستقلة". لما حاجة جنبها تتغيّر، الصورة مش بتترسم من جديد — بتتنسخ من الـ cache بتاع الطبقة.

---

## 4. اللي بيكلّفنا فعلاً ❌

### 4.1 قائمة الإشعارات بتتبني كاملة قبل ما تظهر

[`notifications_page.dart:123`](../lib/features/shared/notifications/presentation/pages/notifications_page.dart#L123)

```dart
// ❌ الحالي
ListView(
  children: [
    if (unread.isNotEmpty) ...[
      Text(...),
      for (final item in unread) ...[ _buildNotificationCard(...), SizedBox(...) ],
    ],
    if (read.isNotEmpty) ...[ ... ],
  ],
)
```

`ListView(children:)` **بيبني كل العناصر فوراً**، حتى اللي تحت بـ 20 شاشة. ولاحظ إن الصفحة دي فيها pagination (`scrollController`) — يعني القائمة بتكبر مع كل صفحة جديدة، والتكلفة بتتراكم: 100 إشعار = 100 كارت + 100 صورة متبنيين في فريم واحد.

```dart
// ✅ المفروض — نسطّح الأقسام في قائمة واحدة ونبنيها كسول
enum _RowKind { header, card }
final rows = <(_RowKind, Object)>[
  if (unread.isNotEmpty) (_RowKind.header, 'notifications.new_notifications'),
  ...unread.map((n) => (_RowKind.card, n)),
  if (read.isNotEmpty) (_RowKind.header, 'notifications.previous'),
  ...read.map((n) => (_RowKind.card, n)),
];

ListView.builder(
  controller: scrollController,
  itemCount: rows.length,
  itemBuilder: (context, i) => switch (rows[i]) {
    (_RowKind.header, final String key) => _SectionHeader(key.tr()),
    (_RowKind.card, final NotificationItem n) => _NotificationCard(item: n),
    _ => const SizedBox.shrink(),
  },
);
```

**المكسب:** وقت فتح الصفحة بيبقى ثابت مهما كان عدد الإشعارات، بدل ما يكبر خطياً معاها.

### 4.2 صور الشبكة بتتفك بحجمها الأصلي — أكبر مكسب متاح عندنا ✅ (اتطبّق)

> **الوضع الأصلي:** مسار الأصول المحلية في [`app_image.dart:245`](../lib/core/widgets/app_image.dart#L245) كان بيعمل downsampling صح من الأول (`cacheWidth` + حماية `isFinite`). اللي كان ناقص هو **مسار الشبكة** — وهو بالظبط اللي بيحمّل صور المنتجات الكبيرة.

```dart
// ❌ اللي كان — مفيش downsampling في مسار الشبكة
Widget image = OmniImage(
  image: p,
  fit: fit,
  height: height,
  width: width,
);
```

**الحسبة:** الصورة في الذاكرة = `العرض × الطول × 4 bytes` (RGBA)، **مستقلة تماماً عن الحجم اللي بتعرضها بيه**.

| الصورة | حجمها في الذاكرة | بتتعرض في |
|--------|------------------|-----------|
| صورة منتج 1200×1200 | ‎**5.5 MB** | كارت عرضه ~170px |
| نفس الصورة | 5.5 MB | thumbnail 48px في [`order_details_dialog`](../lib/features/user/market/presentation/widgets/order_details_dialog.dart) |

جريد المتجر بيعرض 12 منتج → **66 MB** من الـ bitmaps علشان يرسم مربعات 170px. ده بيضغط الذاكرة، بيزوّد شغل الـ GC، وبيحمّل خيط الراستر ترقيم (downscaling) في كل فريم.

`OmniImage` أصلاً بيدعم `memCacheWidth` — إحنا مكناش بنبعتها.

**⚠️ الصيغة المباشرة `(width! * devicePixelRatio).round()` غلط — بتنفجر في حالتين حقيقيتين عندنا:**

1. **`width` = `double.infinity`** — `AppImage` كتير بتتحط جوه `Expanded` أو `SizedBox.expand` وتاخد عرض الأب. و`double.infinity.round()` بيرمي `UnsupportedError` مش بيرجّع null.
2. **`width` = `null`** — ده الشائع فعلاً في كودنا (`AppImage(SvgIcons.market_icon, color: ...)` من غير أي مقاس). الصيغة دي هترجّع `null` يعني **الصورة تفضل بحجمها الكامل** — الإصلاح مش هيلمسها أصلاً.

```dart
// ✅ اللي اتطبّق — [app_image.dart:159-190]
static const int _maxDecodeWidth = 1080;

int? _decodePixels(BuildContext context, double? logical) {
  // infinity / null / صفر → نرجع للسقف بدل ما نرمي أو نسيبها بحجمها الكامل
  if (logical == null || !logical.isFinite || logical <= 0) {
    return _maxDecodeWidth;
  }
  final devicePixels = logical * MediaQuery.devicePixelRatioOf(context);
  if (!devicePixels.isFinite || devicePixels <= 0) return _maxDecodeWidth;
  return devicePixels.round().clamp(1, _maxDecodeWidth);
}
```

**تلات قرارات في الكود ده تستاهل الشرح:**

- **السقف 1080** — لو الحجم مش معروف، السقف أحسن من `null`. وهو آمن: لما الهدف يبقى **أكبر** من الصورة الأصلية، Flutter بيتجاهله ومبيكبّرهاش (`allowUpscaling` = false افتراضياً)، يعني مفيش خسارة جودة لو الصورة أصلاً أصغر.
- **`clamp` مش `round` بس** — بيمنع إن شاشة 4x مع عنصر عريض يطلّع رقم أكبر من السقف.
- **العرض أو الطول، مش الاتنين** — لو بعتنا الاتنين مع بعض بنحارب نسبة أبعاد الصورة نفسها. فبنبعت الطول بس لما مفيش عرض.

نفس الصورة تبقى ‎**0.5 MB** بدل 5.5 — أي ~‎90% أقل ذاكرة، من غير أي فرق شكلي.

### 4.3 مؤقّت كل ثانية بيعيد بناء الشاشة كلها

[`workout_rest_screen.dart:39`](../lib/features/user/workout/presentation/screens/workout_rest_screen.dart#L39)

```dart
// ❌ الحالي — setState على الـ State بتاع الشاشة كلها
_timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  if (_countdown > 0) {
    setState(() { _countdown--; });
  }
});
```

`setState` بيعلّم **الويدجت اللي هو جواها كلها** إنها محتاجة إعادة بناء — يعني الخلفية والأزرار والنصوص الثابتة كلها بتتبني من تاني علشان رقم واحد اتغيّر.

```dart
// ✅ الحل — نحصر التغيير في أصغر ويدجت ممكنة
final ValueNotifier<int> _countdown = ValueNotifier(0);

_timer = Timer.periodic(const Duration(seconds: 1), (t) {
  if (_countdown.value > 0) {
    _countdown.value--;      // مفيش setState خالص
  } else { ... }
});

// وفي الـ build، الجزء المتغيّر بس هو اللي بيتعاد:
ValueListenableBuilder<int>(
  valueListenable: _countdown,
  builder: (_, value, __) => Text('$value', style: ...),
)
```

نفس المبدأ ينفع مع [`running_cubit.dart:303`](../lib/features/user/user_home/presentation/manager/running_cubit.dart#L303) — لو أي شاشة بتستهلكه من غير `buildWhen`، هي بتتعاد كل ثانية.

**القاعدة العامة:** `setState` مش وحش — **نطاقه** هو الوحش. لو عندك عدّاد/أنيميشن، حطّه في ويدجت صغيرة لوحدها بدل ما يعيش في `State` بتاع الصفحة.

### 4.4 `shrinkWrap: true` — 8 مواضع

```
selection_bottom_sheet.dart:131     conversations_shimmer_loading.dart:80
selection_dialog.dart:87            branch_pickup_screen.dart:252
chat_media_grid.dart:47             achievements_page.dart:286
subscription_packages_grid.dart:31  visit_log_page.dart:163
```

`shrinkWrap: true` **بيلغي الكسل**: القائمة بتقيس كل عناصرها علشان تعرف ارتفاعها. لقائمة صغيرة معروفة (زي خيارات في bottom sheet) ده مقبول تماماً. بس في [`visit_log_page.dart:163`](../lib/features/user/visits/presentation/pages/visit_log_page.dart#L163) و[`achievements_page.dart:286`](../lib/features/user/profile/presentation/pages/achievements_page.dart#L286) — دول قوايم جاية من API وممكن تكبر.

**البديل الصح** لما تكون محتاج قائمة جوه صفحة بتتمرّر: `CustomScrollView` + slivers (زي ما عملنا في [`market_products_grid`](../lib/features/user/market/presentation/widgets/market_products_grid.dart))، مش `shrinkWrap` جوه `SingleChildScrollView`.

### 4.5 `Opacity` — 3 مواضع

```
full_screen_image_view.dart:256    typing_dots_indicator.dart:63    cart_item_tile.dart:26
```

ويدجت `Opacity` بتجبر الـ engine على `saveLayer()` — يعني يرسم الابن في buffer منفصل ثم يدمجه. ده من أغلى العمليات على خيط الراستر.

```dart
// ❌ [cart_item_tile.dart:26] بيلفّ الكارت كلها
return Opacity(opacity: isBusy ? 0.5 : 1, child: ...);

// ✅ أرخص: اللون نفسه شفاف — مفيش طبقة جديدة
color: AppColors.white.withValues(alpha: isBusy ? 0.5 : 1)

// ✅ أو للأنيميشن: AnimatedOpacity/FadeTransition أذكى في إدارة الطبقة
```

### 4.6 `const` مش مفعّل في الـ lints

[`analysis_options.yaml`](../analysis_options.yaml) بيستورد `flutter_lints` بس، واللي فيه `prefer_const_constructors_in_immutables` **مش** `prefer_const_constructors`. يعني مفيش حاجة بتنبّهك لما تنسى `const`.

```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
```

وبعد تفعيلهم، الإصلاح آلي بالكامل:

```bash
dart fix --dry-run   # شوف هيتغيّر إيه الأول
dart fix --apply     # بيصلّح مئات الويدجت في ثواني
```

> خد بالك إن `dart fix --apply` بيلمس عدد ضخم من الملفات مرة واحدة. اعمله على فرع لوحده وشغّل `flutter analyze` + التطبيق بعده قبل ما تدمجه.

**ليه `const` مهم:** الويدجت الـ `const` بتتبني **مرة واحدة** طول عمر التطبيق. ولما الـ Framework يقارن الشجرة القديمة بالجديدة ويلاقي نفس الـ instance بالظبط (`identical`)، بيتخطّى الفرع ده بالكامل — مش بس الويدجت، ده كل أولادها كمان.

---

## 5. جدول تشخيص سريع

| العرَض | الخيط | الشك الأول | فين تدوّر |
|--------|-------|------------|-----------|
| تقطيع أثناء السكرول | UI | قائمة مش كسولة / كارت تقيل | `ListView(` أو `shrinkWrap: true` |
| تقطيع أثناء السكرول | Raster | صور كبيرة / ظلال | `memCacheWidth` مفقودة |
| الشاشة بتهنج ثانية | UI | شغل تقيل في `build` أو JSON parsing | CPU Profiler → flame chart |
| بطء أول فتحة للشاشة | UI | كل العناصر بتتبني مرة واحدة | `ListView(children:)` |
| الذاكرة بتزيد وما بترجعش | — | صور بحجمها الكامل / تسريب | Memory view |
| أنيميشن بيهزّ | Raster | `Opacity` / `Clip` / مفيش `RepaintBoundary` | Performance overlay |

---

## 6. ترتيب الأولويات المقترح للمشروع ده

| # | الشغلانة | المكسب | التكلفة |
|---|----------|--------|---------|
| 1 | `memCacheWidth` في [`AppImage`](../lib/core/widgets/app_image.dart) | ~90% من ذاكرة الصور، في كل الشاشات مرة واحدة | تعديل واحد |
| 2 | [`notifications_page`](../lib/features/shared/notifications/presentation/pages/notifications_page.dart) → `ListView.builder` | فتح فوري مهما كان عدد الإشعارات | متوسطة |
| 3 | تفعيل const lints + جولة `dart fix --apply` | rebuilds أقل في كل مكان | سهلة |
| 4 | [`workout_rest_screen`](../lib/features/user/workout/presentation/screens/workout_rest_screen.dart) → `ValueListenableBuilder` | إعادة بناء واحدة صغيرة بدل الشاشة | سهلة |
| 5 | استبدال `Opacity` بألوان شفافة | حمل أقل على الراستر | سهلة |

---

## 7. أفكار متقدمة — حاجات مش موجودة عندنا خالص

القسم اللي فات كان "صلّح اللي موجود". القسم ده "إيه اللي بتعمله لما تبقى بتطوّر وإنت حاطط الأداء في دماغك من الأول".

### 7.1 الشغل التقيل يخرج من خيط الـ UI — Isolates

مفيش `compute` ولا `Isolate` في المشروع كله. ده بيبقى مهم لما JSON يكبر.

**إمتى تحتاجه:** أي شغل CPU بياخد أكتر من ~8ms. مثال عندنا محتمل: رد `/orders` فيه 10 طلبات × كل طلب فيه items، أو `/store/home` بأقسامه الأربعة. طول ما الردود صغيرة `jsonDecode` على خيط الـ UI مقبول — بس أول ما تشوف فريم بيتأخّر وقت الـ parsing، ده الحل:

```dart
// ❌ كل ده على خيط الـ UI — الشاشة واقفة طول مدة الـ parsing
final data = jsonDecode(response.body);
final orders = (data['data'] as List).map(OrderModel.fromJson).toList();

// ✅ Isolate.run — يشتغل على core تاني بذاكرة منفصلة (Dart 2.19+)
final orders = await Isolate.run(() {
  final data = jsonDecode(responseBody) as Map<String, dynamic>;
  return (data['data']['data'] as List)
      .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
      .toList();
});
```

**تحذيرين مهمين:**
1. إنشاء الـ isolate نفسه بيكلّف ~1-2ms + نسخ البيانات جاياً ورايحاً. لـ JSON صغير (أقل من ~10KB) الـ isolate **أبطأ** من إنك تعمل parsing عادي. قيس الأول.
2. الـ isolate مالوش وصول للـ `BuildContext` ولا لأي حاجة من `WidgetsBinding`. اللي بيتبعت لازم يكون بدائي (`String`, `Map`, `List`) أو transferable.

**النقطة الأهم:** Dart مش multithreaded بالمعنى التقليدي. `async/await` **مش** بيشغّل الشغل على خيط تاني — هو بس بيسمح للخيط يعمل حاجة تانية وقت الانتظار (I/O). حلقة `for` تقيلة جوه `async` function هتوقّف الشاشة بالظبط زي الـ sync.

### 7.2 وقت الإقلاع (startup time)

[`main.dart:14-49`](../lib/main.dart#L14-L49) عندنا **6 عمليات `await` متتالية قبل `runApp`**:

```dart
await dotenv.load(...);                      // I/O على الملف
await FcmHelper.initialize();                // Firebase
await LocalNotification(...).initialize();   // plugin channel
await EasyLocalization.ensureInitialized();  // I/O
final prefs = await SharedPreferences.getInstance();
await di.init();
runApp(...);                                 // ← أول فريم مبيبدأش قبل كل ده
```

كل ثانية هنا = شاشة بيضا/سبلاش ثابتة قدام المستخدم.

**تلات تكتيكات:**

**(أ) اللي مالوش لازمة قبل أول فريم يتأجّل:**
```dart
// FCM والسوكيت مش شرط يخلصوا علشان الشاشة الأولى ترسم
runApp(const FitnessDay());

WidgetsBinding.instance.addPostFrameCallback((_) async {
  await FcmHelper.initialize();
  await di.getIt<SocketService>().connectWithStoredToken();
});
```

**(ب) اللي مستقل يتوازى:**
```dart
// ❌ متتالي: مجموع الأوقات
await dotenv.load(...);
await EasyLocalization.ensureInitialized();
final prefs = await SharedPreferences.getInstance();

// ✅ متوازي: أطول واحد فيهم بس
final results = await Future.wait([
  dotenv.load(fileName: '.env'),
  EasyLocalization.ensureInitialized(),
  SharedPreferences.getInstance(),
]);
```
> ⚠️ خد بالك من الفخ المعروف عندنا: `Future.wait` بيرجّع `List<dynamic>`. لو محتاج النتائج مكتوبة بأنواعها استخدم `Future.wait<T>` أو `(await a, await b)` بعد ما تبدأهم من غير `await`. ده نفس الكراش اللي حصل قبل كده في `UserHomeCubit`.

**(ج) قيس فعلاً بدل ما تخمّن:**
```bash
flutter run --profile --trace-startup
```
بيطلّع `start_up_info.json` فيه `timeToFirstFrameMicros` و`timeToFrameworkInitMicros`. ده الرقم اللي تحسّنه وتتابعه.

### 7.3 الصور — الطبقة اللي بعد `memCacheWidth`

**(أ) الكاش نفسه ليه سقف:**
```dart
// في main() — الافتراضي 100MB / 1000 صورة
PaintingBinding.instance.imageCache
  ..maximumSizeBytes = 50 << 20   // 50MB لأجهزة ضعيفة
  ..maximumSize = 200;
```

**(ب) التحميل المسبق للشاشة الجاية:**
```dart
// قبل ما تفتح تفاصيل المنتج — الصورة تبقى جاهزة قبل الانتقال
await precacheImage(NetworkImage(product.mainPhoto), context);
```

**(ج) أكبر مكسب مش في الكود أصلاً — هو في الباك:**
> الباك عندنا بيرجّع `mainPhoto` نسخة واحدة كبيرة. لو رجّع نسخ جاهزة (`?w=200`, `?w=600`) أو حقل `thumbnailUrl`، بنوفّر **باندويث + وقت تحميل + وقت decode** كلهم مع بعض. `memCacheWidth` بيوفّر الذاكرة بس — الصورة الكبيرة لسه بتتحمّل من النت بحجمها. ده طلب يستاهل يتفتح مع فريق الباك.

**(د) الصيغة نفسها:** WebP أصغر من PNG بحوالي 25-35% بنفس الجودة. لو الباك يقدر يقدّم WebP، ده توفير مباشر في وقت التحميل.

### 7.4 القوايم — تفاصيل بتفرق فعلاً

```dart
ListView.builder(
  // ✅ لما كل العناصر بنفس الارتفاع: بيوفّر على Flutter إنه يقيس كل عنصر
  itemExtent: 72,
  // أو لو الارتفاع ثابت بس مش عارف رقمه:
  prototypeItem: const NotificationCard.prototype(),

  // ✅ افتراضياً 250px قدام وورا. زوّده لسكرول أنعم، قلّله لذاكرة أقل
  cacheExtent: 500,

  // ✅ لو العناصر مش محتاجة تحافظ على حالتها لما تخرج بره الشاشة
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: true,   // افتراضياً true — سيبها
);
```

`itemExtent` تحديداً بيحوّل حساب الـ scroll من "قيس العناصر واحد واحد" لـ "ضرب بسيط" — الفرق بيبان جداً في القوايم الطويلة.

**قاعدة مهمة:** مفيش `ListView` جوه `ListView`. لو محتاج صفحة فيها أقسام مختلفة وكل قسم قائمة، الحل الصح `CustomScrollView` بـ slivers متعددة (`SliverList` + `SliverToBoxAdapter` + `SliverGrid`) — scrollable واحد بيتحكّم في الكل ويفضل كسول.

### 7.5 الأنيميشن — الغلطة الأشهر

```dart
// ❌ الـ builder بيتنادى كل فريم (60 مرة/ث) وبيعيد بناء الشعار كل مرة
AnimatedBuilder(
  animation: _controller,
  builder: (context, _) => Transform.rotate(
    angle: _controller.value * 6.28,
    child: ExpensiveLogo(),   // ← بيتبني 60 مرة في الثانية بلا داعي
  ),
);

// ✅ الـ child بيتبني مرة واحدة وبيتمرّر جاهز للـ builder
AnimatedBuilder(
  animation: _controller,
  child: const ExpensiveLogo(),      // ← مرة واحدة بس
  builder: (context, child) => Transform.rotate(
    angle: _controller.value * 6.28,
    child: child,
  ),
);
```

وكمان: أي حاجة بتتحرّك، لفّها بـ `RepaintBoundary` علشان حركتها ما تجبرش اللي حواليها يترسم من تاني.

**وفرق مهم:** حرّك بـ `Transform` (بيأثر على مرحلة الـ paint بس) مش بتغيير `width`/`height`/`padding` (ده بيشغّل مرحلة الـ layout من أول وجديد لكل الشجرة).

### 7.6 الـ Layout — مصادر تكلفة خفية

**(أ) `IntrinsicHeight` / `IntrinsicWidth`:** دول بيخلّوا Flutter يعمل **passes زيادة على الـ layout** — التكلفة ممكن توصل O(n²) في الشجر العميقة. الـ Flutter docs بتحذّر منهم بالاسم. البديل: حدّد المقاسات صراحة، أو استخدم `Table`، أو `IntrinsicHeight` على أصغر نطاق ممكن.

**(ب) `RelayoutBoundary`:** لما ويدجت تاخد **constraints مضبوطة (tight)**، أي تغيير في مقاسها مش بيطلع لفوق للأب. `SizedBox(width: 100, height: 100, child: ...)` بيعمل حاجز طبيعي كده. `ConstrainedBox` بـ constraints مرنة مش بيعمل ده.

**(ج) الشجرة العميقة:** كل `Container` زيادة = RenderObject زيادة في كل pass. `Container(padding: ...)` لوحده = `Padding` كافية. `Container(color: ...)` لوحده = `ColoredBox` أرخص. الـ lint `avoid_unnecessary_containers` بيمسك ده.

### 7.7 مصادر `saveLayer` — الحاجات اللي بتتعب الراستر

`saveLayer()` معناها: ارسم في buffer منفصل، وبعدين ادمجه. دي من أغلى العمليات على الـ GPU. مصادرها:

| المصدر | البديل الأرخص |
|--------|----------------|
| `Opacity` | لون بـ `withValues(alpha:)` |
| `ShaderMask` | صورة/أيقونة ملوّنة جاهزة |
| `ColorFiltered` | `colorFilter` جوه الـ `Image` نفسها |
| `BackdropFilter` | صورة مموّهة مجهّزة مسبقاً |
| `Clip.antiAliasWithSaveLayer` | `Clip.antiAlias` (الافتراضي) |

عندنا مثالين شغالين في [`app_image.dart`](../lib/core/widgets/app_image.dart): `ShaderMask` للتدرّج ([:82](../lib/core/widgets/app_image.dart#L82)) و`BackdropFilter` للـ blur ([:176](../lib/core/widgets/app_image.dart#L176)). الاتنين مقبولين لأنهم بيتستخدموا في أماكن محدودة — بس **متحطّهمش في عنصر بيتكرّر في قائمة**، لأن ساعتها بتدفع `saveLayer` لكل صف.

### 7.8 تسريبات الذاكرة — العدو الصامت

الأداء بيتدهور مع الوقت لما حاجات ما بتتقفلش. الـ checklist:

```dart
@override
void dispose() {
  _controller.dispose();        // TextEditingController / ScrollController
  _animationController.dispose();
  _timer?.cancel();             // ← Timer.periodic بيفضل شغال للأبد من غير كده
  _subscription.cancel();       // StreamSubscription
  super.dispose();
}
```

عندنا **6 مواضع `Timer.periodic`** — راجعهم كلهم يتأكد إن كل واحد فيه `cancel`. [`walking_cubit`](../lib/features/user/user_home/presentation/manager/walking_cubit.dart) بيعملها صح في `close()`؛ الـ timer اللي بيفضل شغال بعد ما الشاشة تقفل بيعمل `emit` على cubit مقفول ويستهلك بطارية في الخلفية.

للكشف الآلي: package `leak_tracker` (مدمج مع `flutter test`) بيمسك الويدجت اللي اتعملها dispose ولسه في الذاكرة.

### 7.9 طبقة الشبكة — أسرع request هو اللي مااتبعتش

- **الرد المكرر:** لاحظ إننا بننده `loadCart()` و`loadCounters()` مع بعض في أكتر من مكان. كل واحدة request. لو الباك يقدر يرجّع الاتنين في رد واحد، ده فريم أسرع وباندويث أقل.
- **debounce للبحث:** أي `TextField` بيبعت request مع كل حرف = 10 requests للكلمة الواحدة. الصح: `Timer` 300ms بيتلغي مع كل حرف جديد.
- **CancelToken:** لو المستخدم خرج من الشاشة، الـ request المعلّق يتلغي (`dio` بيدعم `CancelToken`) بدل ما يكمّل ويعمل `emit` على cubit مقفول.
- **gzip:** اتأكد إن السيرفر بيبعت `Content-Encoding: gzip` — بيقلّل حجم JSON بـ 70-80% مجاناً.

### 7.10 حجم التطبيق — بيأثر على التثبيت والإقلاع

```bash
# شوف إيه اللي واخد مساحة بالظبط
flutter build apk --analyze-size

# APK لكل معمارية بدل واحد شامل (بيقلّل ~40%)
flutter build apk --split-per-abi

# للنشر على جوجل بلاي — بيقسّم أوتوماتيك
flutter build appbundle --obfuscate --split-debug-info=build/symbols
```

`--tree-shake-icons` شغال افتراضياً (بيشيل الأيقونات اللي مش مستخدمة من الخط). خد بالك إنه بيتعطّل لو استخدمت `IconData` بقيمة متغيّرة وقت التشغيل.

### 7.11 الأداء المحسوس — أرخص مكسب على الإطلاق

ساعات المستخدم مش محتاج التطبيق يبقى أسرع، محتاج **يحس** إنه أسرع:

- **Skeletons بدل spinner:** إحنا عندنا `shimmer` مستخدم فعلاً في [`product_card_shimmer`](../lib/features/user/market/presentation/widgets/product_card_shimmer.dart) — ده بالظبط المطلوب. الشكل بيبان فوراً والبيانات بتملاه.
- **Optimistic UI:** إحنا بنعملها في السلة — الزرار بيتغيّر قبل ما الرد يوصل.
- **متخليش الـ spinner يرفرف:** لو الرد جه في 80ms، ظهور واختفاء الـ spinner بيبان كوميض مزعج. إمّا متعرضهوش قبل 200ms، أو خليه ظاهر 400ms على الأقل.
- **احجز المكان قبل التحميل:** الصورة لازم يكون ليها `width/height` من الأول، عشان لما تحمّل ما تزقّش المحتوى تحتها (layout shift).
- **حمّل بيانات الشاشة الجاية بدري:** المستخدم بيبص على تفاصيل المنتج؟ جهّز المنتجات المشابهة في الخلفية.

### 7.12 اختبار أداء مستمر — تمسك الـ regression قبل المستخدم

عندنا `test/` فيها widget tests بس. الأداء ممكن يتقاس آلياً:

```dart
// integration_test/scroll_perf_test.dart
testWidgets('store scroll stays under budget', (tester) async {
  await binding.traceAction(() async {
    await tester.fling(find.byType(CustomScrollView), const Offset(0, -500), 3000);
    await tester.pumpAndSettle();
  }, reportKey: 'scrolling_timeline');
});
```

```bash
flutter drive --profile --driver=test_driver/perf_driver.dart \
  --target=integration_test/scroll_perf_test.dart
```

بيطلّع `TimelineSummary` فيه `average_frame_build_time_millis` و`missed_frame_build_budget_count`. تحطهم في CI مع حد أقصى → أي PR بيبطّئ السكرول بيفشل قبل ما يوصل للمستخدم.

### 7.13 حاجات تعرفها عن المحرّك

- **Impeller** بقى المحرّك الافتراضي (iOS + Android). حلّ مشكلة "shader compilation jank" القديمة — الشيدرز بتتجمّع وقت البناء مش أول مرة تشوف الأنيميشن. يعني نصايح `--purge-persistent-cache` و SkSL warmup القديمة **بقت متقادمة**، متضيعش وقتك فيها.
- **أرقام النسخ مهمة:** `flutter --version --machine` بيدّيك engine + Dart revision. لما تقارن قياسين، لازم يكونوا على نفس النسخة ونفس الجهاز — غير كده المقارنة مالهاش معنى.
- **الـ governor:** نظام التشغيل بيغيّر سرعة المعالج حسب الحرارة والبطارية. نفس الكود ممكن يدّي أرقام مختلفة 30% بين قياس وقياس. علشان كده بنقيس **عدة مرات** وناخد الوسيط، مش قياس واحد.

---

## 8. ثمانية فخاخ متقدمة — وحالة كل واحد فينا

دي الحاجات اللي حتى المطور صاحب الخبرة بيقع فيها، ومعظمها **DevTools مش بتطلّعها كتحذير مباشر**. جنب كل واحدة كتبت نتيجة الفحص على المشروع.

### 8.1 `BuildContext` بعد `await` — تسريب وكراش مع بعض

استخدام `context` بعد أي `await` من غير تحقّق. لو المستخدم خرج من الشاشة والـ API لسه شغال، الـ Framework بيفضل ماسك الشاشة القديمة في الذاكرة، أو بيرمي `setState() called after dispose()`.

```dart
// ❌
Future<void> _load() async {
  final data = await api.getData();
  Navigator.of(context).push(...);   // ⚠️ الـ context ممكن يكون مات
}

// ✅
Future<void> _load() async {
  final data = await api.getData();
  if (!context.mounted) return;
  Navigator.of(context).push(...);
}
```

**حالتنا:** 48 موضع فيه `context.mounted` / `if (!mounted)` — يعني العادة موجودة والحمد لله. بس فيه **صيغة أنضف** لسه ما بنستخدمهاش: بدل ما تتحقق بعد الـ await، **اسحب اللي محتاجه من الـ context قبله**:

```dart
// ✅✅ أأمن — الاعتماد اتاخد وهو لسه عايش، مفيش lookup بعد الـ await أصلاً
final navigator = Navigator.of(context);
final messenger = ScaffoldMessenger.of(context);

final data = await api.getData();
navigator.push(...);        // مش محتاج context تاني
```
ده بيحمي من حالة أصعب: `context.mounted` بترجع `true` بس الـ `InheritedWidget` اللي بتدوّر عليه اتغيّر بالفعل.

### 8.2 `MediaQuery.of(context)` بيسمّع على كل حاجة

`MediaQuery.of(context)` بيشترك في **الكائن كله**. يعني الويدجت بتتعاد لما الكيبورد يفتح، والاتجاه يتغيّر، والـ `textScaleFactor` يتغيّر — حتى لو إنت قارئ العرض بس.

```dart
// ❌ بيتعاد بناؤها لما الكيبورد يفتح رغم إن العرض ما اتغيرش
final w = MediaQuery.of(context).size.width;

// ✅ من Flutter 3.10 — اشتراك على الجزء المطلوب بس
final w = MediaQuery.sizeOf(context).width;
final pad = MediaQuery.paddingOf(context);
final insets = MediaQuery.viewInsetsOf(context);
final dpr = MediaQuery.devicePixelRatioOf(context);
```

**حالتنا:** 8 مواضع بالطريقة القديمة مقابل 2 بالجديدة:

| الملف | السطر | المفروض |
|-------|-------|---------|
| [`app_bottom_sheet.dart`](../lib/core/widgets/app_bottom_sheet.dart#L46) | 46 | `paddingOf` |
| [`exercise_details_dialog.dart`](../lib/core/widgets/exercise_details_dialog.dart#L76) | 76 | `sizeOf` |
| [`full_screen_image_view.dart`](../lib/core/widgets/full_screen_image_view.dart#L190) | 190 | `sizeOf` |
| [`offline_banner.dart`](../lib/core/widgets/offline_banner.dart#L115) | 115 | `paddingOf` |
| [`selection_bottom_sheet.dart`](../lib/core/widgets/selection_bottom_sheet.dart#L228) | 228 | `viewInsetsOf` |
| [`ai_chat_header.dart`](../lib/features/user/ai_chat/presentation/widgets/ai_chat_header.dart#L18) | 18 | `paddingOf` |
| [`branch_pickup_screen.dart`](../lib/features/user/market/presentation/screens/checkout/branch_pickup_screen.dart#L269) | 269 | `sizeOf` |
| [`manual_add_sheet.dart`](../lib/features/user/user_home/presentation/widgets/hydration/manual_add_sheet.dart#L146) | 146 | `sizeOf` |

لاحظ إن أربعة منهم **bottom sheets وهيدرز شات** — يعني بالظبط الشاشات اللي الكيبورد بيفتح ويقفل فيها كتير. دي مش نظرية هنا.

### 8.3 `GlobalKey` — أغلى مما تتخيّل

`GlobalKey` بيخلي Flutter يفتّش شجرة العناصر كلها لما العنصر يتنقل، وبيمنع تحسينات الـ tree diffing، وبيمسك الـ `State` في الذاكرة لفترة أطول.

**حالتنا:** 33 استخدام — راجعتهم، وأغلبهم **مشروع تماماً**: `GlobalKey<FormState>` للفاليديشن و`GlobalKey<NavigatorState>` للراوتر (دول الاستخدامات الرسمية). القاعدة اللي نلتزم بيها: **متستخدمش `GlobalKey` علشان توصل لحالة ويدجت تانية** — ده شغل Cubit أو `ValueNotifier` أو callback.

### 8.4 القوايم الديناميكية من غير `Key` — ⚠️ ده موجود عندنا فعلاً

لما تحذف أو ترتّب عناصر في قائمة، Flutter بيطابق العناصر **بالموضع (index)** افتراضياً. لو العنصر فيه حالة داخلية (`StatefulWidget`، أنيميشن، سكرول، فيديو شغال)، الحالة بتفضل مكانها والبيانات بتتبدّل تحتها → صورة غلط جنب اسم غلط.

**حالتنا:** **32 `itemBuilder` في المشروع، مفيش ولا واحد فيهم بيمرّر `key`.**

وأخطر واحد فيهم [`chat_messages_list.dart:51`](../lib/features/shared/conversations/presentation/widgets/chat/chat_messages_list.dart#L51):

```dart
// ❌ الحالي
child: ChatMessageBubble(
  message: messages[messages.length - 1 - index],
),
```

ليه ده خطر **هنا تحديداً**: القائمة `reverse: true`، ولما تحمّل صفحة أقدم إحنا بنحطّها في **أول** المصفوفة ([`copyWithOlderMessages`](../lib/features/shared/conversations/presentation/manager/chat_state.dart)) — يعني كل الفهارس بتزحلق دفعة واحدة. وكمان بنضيف فقاعة "بيكتب دلوقتي" في أول القائمة وبنشيلها (`_headCount`)، فالفهارس بتزحلق تاني.

```dart
// ✅
child: ChatMessageBubble(
  key: ValueKey(msg.id),      // مربوط بالبيانات مش بالموضع
  message: msg,
),
```

**قاعدة:** `ValueKey(item.id)` — **أبداً** `ValueKey(index)`، لأن الـ index هو بالظبط الحاجة اللي بتتغيّر.

### 8.5 التنظيف في `dispose` — التسريب الصامت

```dart
@override
void dispose() {
  _textController.dispose();
  _focusNode.dispose();
  _animationController.dispose();
  _scrollController.dispose();
  _timer?.cancel();
  _subscription.cancel();     // ← أكتر واحدة بتتنسي
  super.dispose();
}
```

**حالتنا:** 8 `StreamSubscription` و6 `Timer.periodic` و3 `AnimationController`. الخطر مش في العدد، الخطر في إن **واحد يفلت**: `StreamSubscription` مش متلغية معناها إن الكولباك هيفضل بيتنادى على شاشة مقفولة، والـ state بتاعها كله محجوز في الذاكرة معاها.

### 8.6 `IntrinsicHeight` / `IntrinsicWidth` — ⚠️ عندنا واحدة في مكان حسّاس

الويدجت دي بتجبر الـ engine على **دورة layout زيادة**: يقيس كل الأولاد الأول علشان يعرف الأكبر، وبعدين يعمل layout حقيقي. جوه شجرة عميقة أو قائمة، التكلفة بتقرب من O(n²).

**حالتنا:** موضعين:
- [`report_text_field.dart:83`](../lib/features/specialist/visits/presentation/widgets/report_text_field.dart#L83) — مقبول، عنصر واحد في فورم.
- [`vertical_day_tab_bar.dart:39`](../lib/core/widgets/vertical_day_tab_bar.dart#L39) — **ده اللي يستاهل مراجعة**، لأنه حسب `CLAUDE.md` مستخدم في كل شاشات الخطط (الوجبات، التمارين، الأنشطة).

```dart
// الحالي — بيقيس كل الأيام مرتين علشان يوحّد الارتفاع
IntrinsicHeight(
  child: Container(
    width: 60.w,
    child: Column(mainAxisSize: MainAxisSize.min, children: [...]),
  ),
)
```

بما إن كل يوم في التاب بار ارتفاعه معروف/ثابت، **الأنضف** إن الأب يديه ارتفاع صريح أو نستخدم `CrossAxisAlignment.stretch` جوه `Row` — وساعتها الدورة الزيادة بتختفي خالص.

### 8.7 `Isolate` مش دايماً أسرع — تكلفة النقل

تكملة لـ [قسم 7.1](#71-الشغل-التقيل-يخرج-من-خيط-الـ-ui--isolates): نقل البيانات للـ isolate بيتم بالنسخ (serialization). لو الكائن معقّد، **وقت النسخ نفسه ممكن يعدّي وقت الـ parsing الأصلي** — يعني تكون خسّرت مرتين.

| الحالة | القرار |
|--------|--------|
| JSON < ~50KB | خليه على خيط الـ UI |
| JSON > ~100KB، أو معالجة صور، أو تشفير | isolate |
| اللي بيتبعت | `String` / `Uint8List` — بدائيات، مش كائنات مبنية |

الترتيب الصح: **ابعت الـ String الخام للـ isolate، وخلي الـ parsing يحصل جوه** — مش تعمل parse برّه وتبعت الكائنات.

### 8.8 القص (Clipping) — ضريبة على الـ GPU

القص بيغيّر طريقة رسم البكسل في كارت الشاشة، وده من أغلى الحاجات على خيط الراستر.

```dart
// ❌ طبقة قص كاملة علشان حواف مدوّرة
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Container(color: Colors.white),
)

// ✅ الحواف بتترسم مع الخلفية نفسها — مفيش قص
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
)

// ✅ للصور الدائرية
CircleAvatar(backgroundImage: ...)   // بدل ClipOval
```

**حالتنا:** 34 موضع قص. أغلبهم على **صور**، وده الاستخدام اللي مالوش بديل حقيقي (الصورة لازم تتقص فعلاً). بس القاعدة للجديد: **لو اللي بتقصّه لون أو تدرّج → `BoxDecoration`. لو صورة → `ClipRRect` مقبول.**

وكمان: `Clip.antiAlias` (الافتراضي) أرخص بكتير من `Clip.antiAliasWithSaveLayer` — متغيّرش الافتراضي من غير سبب.

---

## 9. صيد تسريبات الذاكرة بالـ DevTools — خطوة بخطوة

التسريب معناه: كائن المفروض مات، وفضل محجوز لأن حد لسه ماسكه. النتيجة مش كراش فوري — التطبيق بيتقل بالتدريج كل ما المستخدم يتنقل بين الشاشات.

### 9.1 الطريقة العملية (تنفع مع أي شاشة)

```
1. flutter run --profile   ← لازم profile
2. DevTools → Memory
3. افتح الشاشة اللي بتشك فيها (مثلاً ChatDetailsPage)
4. اقفلها بالرجوع
5. اضغط زرار الـ GC (🗑) — إجباري، عشان تستبعد "لسه ما اتجمعتش"
6. Take Snapshot
7. في خانة الفلتر اكتب اسم الكلاس: _ChatDetailsPageState
```

**القراءة:** لو العدد ‎**0** → نضيف. لو ‎**1 أو أكتر بعد ما قفلت الشاشة** → عندك تسريب.

**كرّرها 3 مرات** (افتح واقفل 3 مرات): لو العدد بيبقى 1 ثابت ممكن يكون كائن محتفظ بيه عمداً؛ لو بيطلع 1 ← 2 ← 3، ده تسريب مؤكّد ومتراكم.

### 9.2 الجزء المهم: مين ماسكه؟

اضغط على الكائن في الـ snapshot وشوف **"Retaining path"** (مسار الاحتفاظ). ده بيوريك السلسلة من جذر الذاكرة لحد الكائن بتاعك:

```
RootIsolate
 └── _Timer                      ← الجاني
      └── closure                ← الـ callback
           └── _ChatDetailsPageState
```

الحلقة اللي **قبل** كائنك على طول هي اللي ماسكاه. القراءة دي بتحوّل التخمين لتشخيص.

### 9.3 المشتبه بهم — مرتّبين حسب شيوعهم عندنا

| المُمسِك في الـ retaining path | المعنى | عندنا |
|-------------------------------|--------|-------|
| `_Timer` | `Timer.periodic` من غير `cancel` | 6 مواضع |
| `_BroadcastSubscription` | `StreamSubscription` من غير `cancel` | 8 مواضع |
| `Ticker` / `AnimationController` | كنترولر من غير `dispose` | 3 مواضع |
| closure ماسكة `this` | callback اتسجّلت في singleton | السوكيت والـ FCM |
| `GlobalKey` | مفتاح حي بيمسك الحالة | 33 مفتاح (أغلبهم فورم) |

**أخطر واحدة في تطبيقنا تحديداً:** الـ cubits المسجّلة `registerLazySingleton` (زي `CartCubit`) **بتعيش طول عمر التطبيق بالتصميم** — دي مش تسريب. التسريب بيبقى لما **شاشة** تسجّل listener على singleton وما تشيلوش وهي بتقفل.

### 9.4 الصور مش بتظهر في Dart heap

نقطة بتضيّع وقت كتير: **ذاكرة الصور مش محسوبة كلها في الـ Dart heap.** الـ bitmap عايش في الـ native memory. يعني الـ heap ممكن يبان 40MB والتطبيق واخد 300MB فعلياً.

- في DevTools بُصّ على **RSS** (الذاكرة الكلية) مش على الـ Dart heap بس.
- ولمراقبة كاش الصور تحديداً:

```dart
final cache = PaintingBinding.instance.imageCache;
debugPrint('images: ${cache.currentSize}/${cache.maximumSize}  '
           'bytes: ${(cache.currentSizeBytes / 1048576).toStringAsFixed(1)} MB');
```

حطّها في زرار debug وافتح المتجر واسكرول — الرقم ده هو اللي بيثبت إن `memCacheWidth` اشتغلت فعلاً (المفروض ينزل بشكل واضح بعد [قسم 4.2](#42-صور-الشبكة-بتتفك-بحجمها-الأصلي--أكبر-مكسب-متاح-عندنا--اتطبق)).

### 9.5 كشف التسريبات آلياً في الاختبارات

`leak_tracker` مدمج مع `flutter test` من Flutter 3.16:

```dart
// في flutter_test_config.dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withTrackedAll();
  await testMain();
}
```

بيفشّل الاختبار لو ويدجت اتعملها dispose وفضلت في الذاكرة. أرخص بكتير من إنك تكتشفها من شكوى مستخدم إن التطبيق بيتقل بعد نص ساعة.

### 9.6 الفرق بين "تسريب" و"تضخّم"

مش كل استهلاك عالي تسريب:

- **تسريب (Leak):** الذاكرة بتزيد وما بترجعش أبداً حتى بعد GC. الحل: التنظيف في `dispose`.
- **تضخّم (Bloat):** الذاكرة عالية بس مستقرة وبترجع. الحل: بيانات أقل في الذاكرة (صور أصغر، صفحات أقصر، متخزّنش القوايم القديمة).
- **ضغط الـ GC (Churn):** كائنات كتير بتتولد وتموت بسرعة (مثلاً `map().toList()` جوه `build`). الأعراض: تقطيع دوري كل شوية بدل تباطؤ تدريجي. الأداة: **Allocation Tracing** في DevTools.

الأعراض التلاتة مختلفة والعلاج مختلف — حدّد النوع الأول قبل ما تصلّح.

---

## 10. الخلاصة في 6 سطور

1. **مش هتصلّح حاجة قبل ما تقيس** — `--profile` + DevTools، وعلى جهاز ضعيف.
2. **اعرف الخيط الأول** — UI ولا Raster؟ العلاج مختلف تماماً.
3. **كل قائمة ديناميكية = `.builder`** — استثناء واحد: قائمة قصيرة وثابتة.
4. **الصورة بتاكل ذاكرة بأبعادها الأصلية** مش بحجم عرضها — نزّلها بـ `memCacheWidth`.
5. **`setState` مش المشكلة، نطاقه هو المشكلة** — نزّل الحالة لأصغر ويدجت.
6. **`const` مجاني** — فعّل الـ lint وخلّي المحلّل يفكّرك.

> وسطر سابع: أسرع كود هو اللي مااتنفّذش. قبل ما تحسّن حاجة، اسأل الأول: هي محتاجة تحصل أصلاً؟ (request مكرر، rebuild لحاجة ما اتغيرتش، صورة بتتحمّل وهي بره الشاشة).

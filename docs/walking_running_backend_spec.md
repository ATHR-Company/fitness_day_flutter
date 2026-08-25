# تتبّع المشي والجري — مواصفة الباك إند

> **الغرض:** العقد اللي لازم السيرفر يلتزم بيه عشان عميل المشي/الجري يشتغل صح.
> مكتوب من واقع سلوك السيرفر الحالي + التصحيحات المطلوبة اللي لسه مفتوحة.
> نظير الفرونت: [`walking_running_implementation.md`](walking_running_implementation.md).

**العميل بيفترض الحاجات دي وبيعتمد عليها في تصميمه — مش تحسينات اختيارية:**

| # | الافتراض | الحالة |
|---|---------|--------|
| 1 | كل حقول التقدّم **دلتا** بتتطبّق بـ `$inc` | ✅ متطبّق |
| 2 | `syncId` بيمنع تطبيق نفس الطلب مرتين | ⚠️ **محتاج تأكيد** — §6 |
| 3 | المطابقة على `activityItemId` مش `activityId` | ✅ متطبّق |
| 4 | الاكتمال بالوصول للهدف مش باستلام `isFinal` | ❌ **مكسور** — §7.1 |
| 5 | المدة مبتزيدش من غير تقدّم فعلي | ❌ **مكسور** — §7.2 |
| 6 | التخزين بالمتر والرد بالكيلومتر | ✅ متطبّق |

---

## 1. نموذج البيانات

النشاط بيعيش جوّه يوم من أيام خطة الـ assessment:

```
assessment
  └── days[ dayNumber ]
        └── activities[ ]
              ├── _id            ← activityItemId (فريد لكل عنصر في اليوم)
              ├── activityId     ← مرجع الكتالوج (مشترك بين كل عناصر النوع)
              ├── activityType   ← "walking" | "running" | "hydration" | …
              ├── goal
              ├── currentProgress
              ├── distance       ← مخزّن بالمتر
              ├── durationMinutes
              ├── caloriesBurned
              ├── isCompleted
              ├── goalReached
              └── syncIds[ ]     ← مفاتيح الـ idempotency المستهلكة
```

### 1.1 `activityItemId` مقابل `activityId` — حرج

`activityId` هو مرجع الكتالوج و**مشترك**. يوم فيه نشاطين مشي هيكون فيه نفس الـ `activityId`
مرتين. المطابقة عليه معناها إن كل sync بيعدّل النشاطين مع بعض.

**كل عمليات المطابقة تتم على `activityItemId`.** الطلب اللي مالوش `activityItemId`
لازم يترفض بـ `400` — مش يتعامل معاه كـ "طابق على activityId".

### 1.2 الوحدات المخزّنة

| الحقل | الوحدة المخزّنة | الوحدة في الرد |
|-------|----------------|----------------|
| `distance` | **متر** | كيلومتر، باسم `distanceinKm` |
| `durationMinutes` | **دقيقة كسرية** (`double`) | نفسها |
| `goal` / `currentProgress` (جري) | **كيلومتر** | كيلومتر |
| `goal` / `currentProgress` (مشي) | **خطوة** | خطوة |
| `caloriesBurned` | kcal | kcal |

> عدم التماثل مقصود وموثّق: الإرسال بالمتر والقراءة بالكيلومتر.
> **ماتغيّرش واحد فيهم من غير ما تغيّر العميل** — التحويل مبني على كده من الطرفين.

---

## 2. `POST /user-activities/walking/sync`

### 2.1 الطلب

```jsonc
{
  "assessmentId":   "665f…",   // ObjectId — مطلوب
  "dayNumber":      3,          // int ≥ 1 — مطلوب
  "activityId":     "665a…",   // ObjectId — مطلوب (مرجع الكتالوج)
  "activityItemId": "665b…",   // ObjectId — مطلوب (مفتاح المطابقة)
  "deltaSteps":     42,         // int ≥ 0 — دلتا
  "deltaDistance":  31.5,       // double ≥ 0 — دلتا بالمتر
  "durationSeconds": 15,        // int ≥ 0 — دلتا
  "syncId":         "uuid-v4"   // مطلوب — مفتاح idempotency
}
```

### 2.2 المعالجة

```
1. تحقّق من الـ auth، وإن الـ assessment بتاعة المستخدم ده.
2. لو syncId مستهلك قبل كده → ارجع 200 بالحالة الحالية، من غير ما تطبّق حاجة.  (§6)
3. لاقي النشاط بـ (assessmentId, dayNumber, activityItemId, activityType: "walking").
   مش موجود → 404.
4. طبّق الدلتا:
      currentProgress  += deltaSteps
      distance         += deltaDistance            // متر
      durationMinutes  += durationSeconds / 60     // بس بشرط §7.2
      caloriesBurned    = احسبها (§5)
5. أعد تقييم goalReached / isCompleted (§7.1).
6. سجّل الـ syncId.
7. ارجع الحالة الجديدة.
```

### 2.3 الرد

```jsonc
{
  "success": true,
  "statusCode": 200,
  "message": "Walking synced",
  "data": {
    "caloriesBurned": 12.4,      // العميل بيقراه ويعرضه
    "currentProgress": 4212,
    "goalReached": false
  }
}
```

العميل بيقرا `data.caloriesBurned` بس، لكن رجوع الباقي بيسهّل الديباج.

---

## 3. `POST /user-activities/running/sync`

نفس المشي، ناقص `deltaSteps` وزائد `isFinal`:

```jsonc
{
  "assessmentId":   "665f…",
  "dayNumber":      3,
  "activityId":     "665a…",
  "activityItemId": "665b…",
  "deltaDistance":  120.0,      // متر
  "durationSeconds": 30,
  "isFinal":        false,      // bool — مطلوب
  "syncId":         "uuid-v4"
}
```

### 3.1 التقدّم بالكيلومتر

الجري هدفه بالكيلومتر، فالتقدّم بيتحوّل عند التطبيق:

```
currentProgress += deltaDistance / 1000     // متر → كم
distance        += deltaDistance            // متر كما هي
```

### 3.2 `isFinal`

- بيقفل الجلسة — بعده أي sync بنفس الجلسة مالوش معنى.
- **لكنه مش دليل اكتمال** — شوف §7.1.
- العميل بيبعته عند الـ stop **وعند الخروج من الشاشة وسط جلسة**، حتى لو الدلتا صفر.
  فالسيرفر لازم يقبل `isFinal: true` مع `deltaDistance: 0, durationSeconds: 0`
  ويرجّع `200` من غير ما يزوّد أي رقم.

### 3.3 الخطوات

الجري **مبيبعتش** `deltaSteps` والسيرفر مبيقراهاش لو اتبعتت.

---

## 4. `GET /user-activities/assessments/:assessmentId/days/:dayNumber/activities/:activityId`

### 4.1 الـ query

| البارامتر | القيم | الافتراضي |
|-----------|-------|-----------|
| `period` | `daily` \| `weekly` | `daily` |

`weekly` بيرجّع تجميعة على الأسبوع بنفس شكل الـ payload (تقدّم مجمّع، وهدف مجمّع).

### 4.2 الرد

```jsonc
{
  "success": true,
  "statusCode": 200,
  "message": "…",
  "data": {
    "assessmentId":   "665f…",
    "dayNumber":      3,
    "activityId":     "665a…",
    "activityItemId": "665b…",   // ← لازم يكون موجود، العميل بيبعت بيه
    "activityType":   "running",
    "name":           "الجري",
    "description":    "…",
    "unit":           "km",       // "km" للجري، "خطوة" للمشي
    "goal":           2,          // كم للجري، خطوة للمشي
    "currentProgress": 0.14,      // نفس وحدة goal
    "progressPercentage": 7,
    "isCompleted":    false,
    "goalReached":    false,
    "distanceinKm":   0.1422,     // ← الاسم ده بالظبط (العميل عنده fallback لـ "distance")
    "durationMinutes": 0.9,       // ← كسري! مش int
    "caloriesBurned":  8.2,
    "time":            "07:30",
    "completedAt":     null,
    "addedAt":         "2026-08-25T07:30:00.000Z",
    "comparedToPreviousDay": { "type": "less", "value": 100 }
  }
}
```

### 4.3 قواعد الحقول

- **`activityItemId` مطلوب.** من غيره العميل مش بيقدر يبعت أي تقدّم — بيقعد
  يجمّع محلياً ومش بيوصل السيرفر ولا حاجة.
- **`durationMinutes` لازم يكون `double`.** مشية 54 ثانية = `0.9`. تقريبه لـ `int`
  على السيرفر بيخلّي كل الجلسات القصيرة تختفي.
- **`distanceinKm`** — الاسم ده (بالحرف الصغير في `in`) هو اللي العميل بيقراه أول،
  و`distance` fallback للردود القديمة. تغيير الاسم يكسر العرض.
- **`goalReached`** — العميل بيخفي بيه زرار الـ Start. لازم يبقى منفصل عن `isCompleted`
  (شوف §7.1). لو مش موجود العميل بيرجع لـ `isCompleted`.
- **`unit`** لازم يطابق وحدة `goal` فعلياً. (كان بيرجّع `"كم"` مع `goal` بالمتر — اتصلّح.)

---

## 5. حساب السعرات

السيرفر هو اللي بيحسب — العميل مبيبعتش سعرات في الجري خالص، وبيعرض اللي راجع.

المدخلات المتاحة: `deltaDistance` (متر)، `deltaSteps`، `durationSeconds`، ووزن المستخدم.

المطلوب: تكون **تراكمية ومتّسقة** — نفس المسافة تدّي نفس السعرات، والقيمة المرجّعة
هي إجمالي النشاط مش دلتا الطلب.

---

## 6. الـ Idempotency — `syncId` ⚠️ محتاج تأكيد

**العميل بيعتمد على ده اعتماد كامل.** لما طلب يفشل بـ timeout، العميل **بيعيد إرساله
بنفس الـ `syncId` وبنفس المحتوى بالحرف** — لأنه مش عارف لو الطلب وصل وضاع الرد بس.

### 6.1 المطلوب

```
1. syncId فريد لكل نشاط.
2. أول ما الدلتا تتطبّق، خزّن الـ syncId مع النشاط.
3. طلب جاي بـ syncId مستهلك → 200 بالحالة الحالية، من غير أي تطبيق.
4. مدة الاحتفاظ ≥ 24 ساعة (النشاط يومي أصلاً، فالاحتفاظ لعمر النشاط أنضف).
```

### 6.2 لو مش متطبّق

أي إعادة إرسال (وهي بتحصل عادي على شبكة موبايل) بتتحسب مرتين. مفيش أي حماية تانية
في العميل — الـ `syncId` هو الآلية الوحيدة.

**التخزين:** الأنضف `syncIds: [String]` جوّه وثيقة النشاط نفسها، عشان الفحص
والتطبيق يبقوا في عملية ذرّية واحدة:

```js
db.assessments.updateOne(
  { _id, "days.dayNumber": day, "days.activities._id": itemId,
    "days.activities.syncIds": { $ne: syncId } },      // ← الحارس
  { $inc:  { "days.$[d].activities.$[a].currentProgress": deltaSteps, … },
    $push: { "days.$[d].activities.$[a].syncIds": syncId } },
  { arrayFilters: [{ "d.dayNumber": day }, { "a._id": itemId }] }
);
// matchedCount == 0 → إما مش موجود، وإما replay. فرّق بينهم بقراية تانية.
```

الفحص-ثم-الكتابة على مرحلتين فيه سباق: طلبين متزامنين بنفس الـ `syncId` (وهو
بالظبط اللي بيحصل مع الإعادة) ممكن يعدّوا الفحص الاتنين.

---

## 7. المشاكل المفتوحة

### 7.1 ❌ النشاط بيتحسب "مكتمل" وهو صفر

من لوج حقيقي:

```json
{
  "goal": 1000,
  "currentProgress": 0,
  "distance": 0,
  "caloriesBurned": 0,
  "isCompleted": true
}
```

**السبب:** السيرفر بيقفل النشاط بمجرد استلام `isFinal: true`، بغض النظر عن الهدف.
والعميل بيبعت `isFinal: true` عند أي stop — حتى لو المستخدم دخل وخرج من غير ما يجري.

**المطلوب — فصل المفهومين:**

| العَلَم | معناه | شرطه |
|--------|-------|------|
| `sessionClosed` (داخلي) | الجلسة خلصت | `isFinal: true` وصل |
| `goalReached` | التقدّم وصل الهدف | `currentProgress >= goal` |
| `isCompleted` | النشاط مكتمل لليوم | **`currentProgress >= goal`** |

`isCompleted` **مايترفعش** لمجرد استلام `isFinal`. ولازم يبقى قابل للتراجع لو
`goal` اتعدّل لأعلى.

**التأثير:** ده بيكسر منطق التحدي نفسه — نشاط بصفر تقدّم بيتعرض مكتمل، والتحديات
والإحصائيات كلها بتتلوّث. **دي أعلى أولوية في الملف.**

### 7.2 ❌ `durationMinutes` بتتضخّم

من اللوج: كل `isFinal` sync — حتى بمسافة صفر — بيزوّد المدة (`0.38 → 0.43`).
تكرار play/stop من غير حركة بيرفع الدقايق بلا حد.

**المطلوب:**

```
لو deltaDistance == 0 و deltaSteps == 0:
    ماتزوّدش durationMinutes
```

العميل بقى بيبعت الوقت مع الحركة الحقيقية بس، بس ده مش كافي: `isFinal` لازم يعدّي
حتى بدلتا صفر (§3.2)، فالحارس لازم يكون على السيرفر كمان.

### 7.3 🟡 `comparedToPreviousDay`

السيرفر بيرجّع `{ "type": "less", "value": 100 }` والعميل بيتجاهله حالياً.
لو المفروض يتعرض ("أقل بـ 100 عن أمس") فده فيتشر ناقص في الفرونت — والسيرفر مطلوب
منه بس يثبّت شكل الحقل:

- `type`: `"more"` \| `"less"` \| `"same"`
- `value`: عدد موجب بنفس وحدة `goal`

---

## 8. التحقق من المدخلات

| الحقل | القاعدة | لو اتكسرت |
|-------|---------|-----------|
| `assessmentId` | ObjectId + مملوكة للمستخدم | `403` |
| `dayNumber` | int ≥ 1 وموجود في الخطة | `404` |
| `activityItemId` | مطلوب، ObjectId، موجود في اليوم | `400` / `404` |
| `activityType` | يطابق الـ endpoint (walking/running) | `400` |
| `deltaSteps` | int، `0 ≤ x ≤ 5000` | `400` |
| `deltaDistance` | double، `0 ≤ x ≤ 5000` (متر) | `400` |
| `durationSeconds` | int، `0 ≤ x ≤ 3600` | `400` |
| `syncId` | مطلوب، UUID | `400` |
| `isFinal` | bool (الجري فقط) | `400` |

الحدود العليا حراسة ضد العميل المكسور مش ضد الغش — العميل بيبعت كل 15 ثانية (مشي)
أو كل 5 متر (جري)، فأي دلتا أكبر من كده معناها بق فعلاً.

### 8.1 الأرقام السالبة

كل الدلتات في المشي/الجري **موجبة أو صفر**. (الترطيب هو الوحيد اللي بيقبل سالب —
لما المستخدم يشيل كباية غلط — وإجماليه بيتحدّ عند الصفر.)

---

## 9. تسلسل نموذجي — جلسة مشي 3 دقايق

```
T+0s     GET  activities/:id            → goal:6000, currentProgress:4200, activityItemId:"66b…"
T+0s     POST walking/sync              (أول poll، مفيش دلتا) — بيتخطّى، مفيش حاجة جديدة
T+15s    POST walking/sync  Δsteps:23  Δdist:17.2  Δdur:15   syncId:a1  → 200
T+30s    POST walking/sync  Δsteps:28  Δdist:21.0  Δdur:15   syncId:a2  → timeout ✗
T+45s    POST walking/sync  Δsteps:28  Δdist:21.0  Δdur:15   syncId:a2  → 200 (إعادة حرفية)
                                        ↑ نفس المحتوى ونفس الـ syncId بالظبط
T+60s    POST walking/sync  Δsteps:51  Δdist:38.3  Δdur:30   syncId:a3  → 200
                                        ↑ دلتا مجمّعة عن الـ 30 ثانية اللي فاتوا
T+180s   POST walking/sync  Δsteps:19  Δdist:14.2  Δdur:15   syncId:a4  → 200  (isFinal للمشي بلا أثر)
T+181s   GET  activities/:id            → currentProgress:4349

الإجمالي: 4200 + 23+28+51+19 = 4321  … + خطوات الـ poll الأولاني
```

**لاحظ T+45s:** لو الـ `a2` كان وصل فعلاً عند T+30 وضاع الرد بس، لازم الإعادة
**ماتتطبّقش تاني**. من غير ده الـ 28 خطوة دي بتتحسب مرتين.

---

## 10. تشيك ليست للباك إند

- [ ] كل الدلتات بتتطبّق بـ `$inc` مش بـ set
- [ ] المطابقة على `activityItemId`، والطلب من غيره بيترفض
- [ ] `syncId` بيتخزّن، والمكرر بيرجّع 200 من غير تطبيق
- [ ] الفحص والتطبيق في عملية ذرّية واحدة (مش check-then-write)
- [ ] `isCompleted` مبني على `currentProgress >= goal` **مش** على `isFinal`
- [ ] `goalReached` موجود في رد الـ GET
- [ ] `durationMinutes` مبيزيدش لما الدلتا صفر
- [ ] `durationMinutes` بيترجع `double` مش `int`
- [ ] الحقل اسمه `distanceinKm` في الرد
- [ ] `unit` يطابق وحدة `goal` الفعلية
- [ ] `isFinal: true` بدلتا صفر بيرجّع 200
- [ ] المسافة مخزّنة بالمتر ومرجّعة بالكيلومتر
- [ ] `period=weekly` بيرجّع نفس شكل الـ payload بتجميعة
- [ ] حدود التحقق مطبّقة (§8)

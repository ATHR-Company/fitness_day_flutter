# توحيد عرض الأخطاء — AppError

> الكود: [`lib/core/errors/app_error.dart`](../lib/core/errors/app_error.dart) و [`lib/core/widgets/errors/`](../lib/core/widgets/errors/)

---

## 1. المشكلة

الـ `ErrorHandler` عارف كويس نوع الخطأ:

```dart
case DioExceptionType.connectionError:
  return const NetworkFailure('لا يوجد اتصال بالإنترنت...');
case DioExceptionType.badResponse:
  return ServerFailure(response.data['message']);
```

بس كل state في التطبيق كانت بتخزّن `failure.message` **بس**:

```dart
class UserHomeError extends UserHomeState {
  final String message;   // ← النوع ضاع هنا
}
```

فالشاشة مش قادرة تفرّق بين "مفيش نت" و "الباقة دي مش متاحة"، والنتيجة كانت:

- **10 شاشات** بتعرض `NetworkErrorView` fullscreen — حتى لو الخطأ من الباك ومحتاج قراية
- **3 شاشات خطأ يدوية** كل واحدة بشكل مختلف (`ChatErrorView`, `MealDetailsErrorView`, `_ErrorView` في المحادثات)
- **14 موضع** بيعرض snackbar بالرسالة الخام — يعني "لا يوجد اتصال بالإنترنت" بيظهر كـ toast صغير بدل شاشة الـ Retry

---

## 2. الحل

**خطوة واحدة:** خلّي النوع يوصل للـ state، وبعدين وحّد العرض.

```dart
enum AppErrorType { network, server, validation, cache }

class AppError {
  final AppErrorType type;
  final String message;
  final String? fieldKey;      // للـ validation بس

  factory AppError.from(Failure failure) { ... }
}
```

### القاعدة

| النوع | العرض | ليه |
|---|---|---|
| **network** + الشاشة فاضية | `AppErrorView` fullscreen مع Retry | الإعادة هي الحل كله، ومفيش حاجة تتقري |
| **network** + الشاشة فيها محتوى | `showAppError` → snackbar | اليوزر بيقرا حاجة، ماينفعش تختفي قدامه |
| **server** | `showAppError` → snackbar | رسالة الباك هي المفيدة، لازم تتعرض |
| **server** حرج (دفع/طلبات) | `showAppError(display: dialog)` | لازم اليوزر يسجّلها قبل ما يكمّل |
| **validation** | تحت الحقل نفسه بـ `fieldKey` | مكانها الطبيعي |

**نقطة مهمة:** خطأ من السيرفر ماينفعش يتحط ورا زرار Retry لوحده. لو الرسالة "الباقة غير متاحة"، اليوزر هيدوس Retry لحد ما يزهق. الشبكة بس هي اللي الإعادة تحلّها.

---

## 3. المكوّنات

| الملف | الدور |
|---|---|
| `core/errors/app_error.dart` | النوع + `AppError.from(Failure)` |
| `core/widgets/errors/app_error_view.dart` | الشاشة الكاملة — شكل الشبكة أو شكل السيرفر |
| `core/widgets/errors/app_error_dialog.dart` | الـ popup |
| `core/widgets/errors/show_app_error.dart` | `showAppError()` — بيختار snackbar ولا dialog |

`showAppError` بيتصرّف في النص كمان: خطأ الشبكة رسالته ثابتة داخلية، فبيعرض النص المترجم بدالها. خطأ السيرفر رسالته هي كل الحكاية، فبتكسب على أي default.

---

## 4. الاستخدام

### شاشة فشل تحميلها من أول مرة

```dart
if (state is XFailure) {
  return AppErrorView(
    error: state.error,       // ← النوع
    message: state.message,   // ← fallback للـ states القديمة
    onRetry: () => context.read<XCubit>().load(),
  );
}
```

### خطأ فوق شاشة فيها محتوى

```dart
BlocListener<XCubit, XState>(
  listener: (context, state) {
    if (state is XFailure) showAppError(context, state.error, message: state.message);
  },
  ...
)
```

### حالة حرجة

```dart
case PaymentError(:final message, :final error):
  showAppError(context, error, message: message, display: ErrorDisplay.dialog);
```

### في الكيوبت

```dart
case FailureResult(:final failure):
  emit(XFailure(failure.message, error: AppError.from(failure)));
```

---

## 5. اللي اتغيّر

| | العدد |
|---|---|
| Failure states اتضاف لها `AppError? error` | **46** |
| مواضع `emit` بتمرّر النوع | **60** |
| شاشات اتحوّلت لـ `AppErrorView` | **12** |
| مواضع snackbar اتحوّلت لـ `showAppError` | **14** |
| شاشات خطأ يدوية اتشالت | **3** |

### ملفات اتشالت
- `core/widgets/network_error_view.dart` → بقى `AppErrorView`
- `conversations/widgets/chat/chat_error_view.dart`
- `visits/widgets/meal_details/meal_details_error_view.dart`

### مفاتيح ترجمة جديدة
`errors.something_went_wrong` · `errors.generic_subtitle` · `errors.ok`

---

## 6. تفاصيل التنفيذ اللي تستاهل تتعرف

### الحقل اختياري عن قصد

```dart
const XFailure(this.message, {this.error});
```

`error` nullable وبقيمة افتراضية، فأي كود قديم بينادي `XFailure('msg')` لسه بيشتغل. و`null` بيتعامل كـ server error — الافتراضي الآمن، لأنه بيعرض الرسالة بدل ما يخبيها ورا Retry.

### `error` اتضاف لـ Equatable props

```dart
List<Object?> get props => [message, error];
```

مهم: `AppError` مش Equatable، فالمقارنة بالـ identity. يعني نفس الرسالة لو جت مرتين من فشلين مختلفين تفضل **حالتين مختلفتين** — و`BlocListener` بيشتغل تاني ويعرض الـ snackbar. من غير ده، فشل متكرر بنفس الرسالة كان هيتعرض مرة واحدة بس.

### ترتيب الفحص في `AppError.from`

```dart
if (failure is ValidationFailure) ...   // الأول!
if (failure is NetworkFailure) ...
```

`ValidationFailure extends ServerFailure`، فلو الفحص اتقلب كل validation هيتحسب server عادي وتضيع الـ `fieldKey`.

### ملفات `part of` مش بتقبل imports

7 ملفات state كانت `part of` الكيوبت بتاعها. الـ import بتاع `app_error.dart` اتحط في الكيوبت الأب مش في الـ part.

---

## 7. قايمة مراجعة لأي شاشة جديدة

- [ ] الكيوبت بيمرّر `error: AppError.from(failure)`؟
- [ ] الشاشة الفاضية بتستخدم `AppErrorView` مش widget يدوي؟
- [ ] الشاشة اللي فيها محتوى بتستخدم `showAppError` مش fullscreen؟
- [ ] `onRetry` متمرّر بس لما الإعادة فعلاً منطقية؟
- [ ] الحالات الحرجة (دفع/طلبات) بـ `ErrorDisplay.dialog`؟
- [ ] `error` موجود في `props`؟

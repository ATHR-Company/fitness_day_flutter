# FitnessDay Flutter — CLAUDE.md

## 1. Project Overview

**App domain:** Fitness & health tracking platform with dual-role support.

| Role | Description |
|------|-------------|
| **User** | Tracks diet plans, workouts, hydration, steps, challenges, market purchases, AI coaching, and personal progress |
| **Specialist** | Manages client assessments/visits, creates custom nutrition + workout + activity plans, monitors client progress and daily tasks |

**Language support:** Arabic (RTL primary) + English (LTR)  
**Base URL:** `https://fitnessday.tech/api`

---

## 2. Architecture

**Pattern:** Clean Architecture + Cubit (BLoC)

```
Presentation → Domain ← Data
```

Every feature follows this exact folder structure:

```
feature/
  data/
    datasources/    → abstract + impl pair; throws DioException, never Failure
    models/         → fromJson/toJson, extends nothing — plain Dart classes
    repositories/   → impl; catches exceptions → maps via ErrorHandler → ApiResult
  domain/
    repositories/   → abstract interface, returns ApiResult<T>
    usecases/       → 1 class = 1 action, call() returns ApiResult<T>
  presentation/
    manager/        → Cubit + sealed State class
    pages/          → screens; wraps BlocProvider, uses BlocBuilder/BlocListener
    widgets/        → reusable widgets within this feature
```

**Domain layer is pure Dart** — zero Flutter, Dio, or Firebase imports anywhere under `domain/`.

---

## 3. Key Project Files

| Purpose | Path |
|---------|------|
| **AppColors** | `lib/core/theme/app_colors.dart` |
| **TextStyleManager** | `lib/core/theme/app_text_styles.dart` |
| **SvgIcons / AppImages** | `lib/core/constant/app_assets.dart` |
| **ApiEndpoints** | `lib/core/constant/api_endpoints.dart` |
| **ApiService (Dio wrapper)** | `lib/core/network/api_service.dart` |
| **ApiResult (Success/Failure)** | `lib/core/network/api_result.dart` |
| **ErrorHandler** | `lib/core/errors/error_handler.dart` |
| **Failures** | `lib/core/errors/failures.dart` |
| **TokenInterceptor** | `lib/core/network/token_interceptor.dart` |
| **AppCache (GetStorage)** | `lib/core/cache/app_cache.dart` |
| **SecureCache (FlutterSecureStorage)** | `lib/core/cache/secure_cache.dart` |
| **AppLocale** | `lib/core/constant/app_locale.dart` |
| **DI setup** | `lib/core/injection/injection_container.dart` |
| **AppRouter (GoRouter)** | `lib/core/routes/app_router.dart` |
| **SharedRoutes** | `lib/core/routes/shared/shared_routes.dart` |
| **UserAppRoutes** | `lib/core/routes/user_routes/app_routes.dart` |
| **SpecialistAppRoutes** | `lib/core/routes/specialist_routes/app_routes.dart` |
| **FitnessHealthService** | `lib/core/services/health_service.dart` |
| **RoleNotifier / FitnessDay widget** | `lib/fitness_day.dart` |
| **main.dart** | `lib/main.dart` |

---

## 4. State Management Pattern

- **Cubit** for every feature — never raw BLoC events unless truly needed
- **Sealed state classes** using Dart 3 pattern matching:
  ```dart
  sealed class DietPlanState { const DietPlanState(); }
  class DietPlanInitial extends DietPlanState { const DietPlanInitial(); }
  class DietPlanLoading extends DietPlanState { const DietPlanLoading(); }
  class DietPlanSuccess extends DietPlanState { final DietPlanData? data; ... }
  class DietPlanFailure extends DietPlanState { final String message; ... }
  ```
- Switch on state in Cubits using Dart 3 patterns:
  ```dart
  switch (result) {
    case Success(:final data): emit(SuccessState(data));
    case FailureResult(:final failure): emit(FailureState(failure.message));
  }
  ```
- **Never use `setState` for business logic** — only for local UI state (animations, toggles)
- Cubits call **UseCases only** — never call repositories or datasources directly

---

## 5. Dependency Injection

**Library:** `get_it`  
**Setup file:** `lib/core/injection/injection_container.dart`

Registration rules:
- `registerLazySingleton` — services, datasources, repositories, use cases, and any cubit shared app-wide (e.g. `CartCubit`, `UserProfileCubit`)
- `registerFactory` — feature cubits that are per-screen (e.g. `DietPlanCubit`, `CheckoutCubit`)

Usage:
```dart
getIt<SomeCubit>()
getIt<AppCache>()
```

---

## 6. Network Layer

### ApiService (`lib/core/network/api_service.dart`)
Thin Dio wrapper with `get()`, `post()`, `patch()`, `delete()` methods.

### TokenInterceptor (`lib/core/network/token_interceptor.dart`)
- **Proactive refresh:** checks token expiry (JWT decode) 10s before expiry on every request
- **Single-flight refresh:** concurrent 401s share one in-flight refresh call via `_refreshFuture`
- **401 retry:** failed request is retried once with the new token
- **Session expired:** clears all caches + redirects to `/role-selection`
- Adds `lang` header from `AppLocale.langCode` on every request

### ApiResult (`lib/core/network/api_result.dart`)
```dart
sealed class ApiResult<T> { ... }
class Success<T> extends ApiResult<T> { final T data; }
class FailureResult<T> extends ApiResult<T> { final Failure failure; }
```

### ErrorHandler (`lib/core/errors/error_handler.dart`)
Maps `DioException` types to `NetworkFailure` (connection/timeout) or `ServerFailure` (bad response, uses backend's `message` field).

### Failures (`lib/core/errors/failures.dart`)
```dart
ServerFailure   // backend error or unexpected
NetworkFailure  // no connection / timeout
CacheFailure    // local storage error
```

---

## 7. Cache Layer

### AppCache (GetStorage — non-sensitive)
Keys stored: `is_logged_in`, `user_type`, `cached_user_profile`, `assessment_id`, `is_subscribed`

### SecureCache (FlutterSecureStorage — sensitive)
Keys stored: `access_token`, `refresh_token`

**Rule:** Tokens always go in `SecureCache`. Never store tokens in `AppCache`.

---

## 8. Navigation

**Library:** `go_router`  
**Single router:** `AppRouter` in `lib/core/routes/app_router.dart` — user + specialist routes unified, never swap `routerConfig`

### Shared Routes
```
/               → Splash
/onboarding     → Onboarding
/role-selection → Role selection
```

### User Routes (UserAppRoutes)
```
Auth:    /user-login, /sign-up, /forgot-password, /otp-verification,
         /reset-password, /user-info, /fitness-system, /diet-system,
         /health-problems, /bmi-report

App:     /user-home, /user-profile, /personal-profile, /user-progress,
         /notifications, /challenges, /scan-meal, /store,
         /visit-log, /visit-details, /upcoming-visit-show,
         /diet-plan, /meal-details, /workout-plan, /workout-video,
         /workout-rest, /hydration-details, /steps-details
```

### Specialist Routes (SpecialistAppRoutes)
```
/login, /home, /visits, /profile, /clients,
/today-tasks, /specialist-notifications
```

Pass data via `state.extra` (always a `Map<String, dynamic>`).

---

## 9. Responsive System

**Library:** `flutter_screenutil`  
**Design size:** `375 × 812` (set in `fitness_day.dart`)

| What | Suffix | Example |
|------|--------|---------|
| Vertical dimension | `.h` | `height: 56.h` |
| Horizontal dimension | `.w` | `width: 200.w` |
| Border radius | `.r` | `BorderRadius.circular(12.r)` |
| Font size | `.sp` | `fontSize: 14.sp` |
| Screen-proportional | `.sh` / `.sw` | `height: 0.4.sh` |
| Padding/margin | `.h` + `.w` | `EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h)` |

**Never use raw pixel values** anywhere in UI code.

---

## 10. Typography

**File:** `lib/core/theme/app_text_styles.dart`  
**Font family:** `Bukra` (Arabic-optimized, weights 300/400/500/700)

Named styles:
- `TextStyleManager.heading1` — 19sp w700
- `TextStyleManager.heading2` — 16sp w700
- `TextStyleManager.heading3` — 14sp w500
- `TextStyleManager.button` — 16sp w500
- `TextStyleManager.smallButtons` — 13sp w500

Generic styles: `styleXXWeight` pattern e.g. `style14Bold` (14sp w700), `style11Medium` (11sp w500)

**Never instantiate `TextStyle()` directly** — always use `TextStyleManager`.

---

## 11. Colors

**File:** `lib/core/theme/app_colors.dart`

Key colors:
| Name | Hex | Usage |
|------|-----|-------|
| `AppColors.primary` | `#00A417` | Brand green — buttons, active states |
| `AppColors.primaryDark` | `#046712` | Premium badges |
| `AppColors.secondary` | `#017D9E` | Teal/cyan flows |
| `AppColors.error` | `#EE1F1F` | Error states |
| `AppColors.textPrimary` | `#4A4949` | Body text |
| `AppColors.textSecondary` | `#8F8F8F` | Captions, placeholders |
| `AppColors.divider` | `#CACACA` | Borders |
| `AppColors.backgroundTint` | `#E6F6E8` | Subtle container backgrounds |
| `AppColors.white` | `#FFFFFF` | Surfaces |
| `AppColors.black` | `#000000` | Heavy titles |

**Never hardcode color hex values** in widgets — always use `AppColors`.

---

## 12. Assets

**File:** `lib/core/constant/app_assets.dart`

- SVGs: `SvgIcons.xxx` → `assets/svg/xxx.svg`
- Images: `AppImages.xxx` → `assets/images/xxx.png`

Asset directories: `assets/svg/`, `assets/images/`, `assets/translations/`, `assets/audio/`, `assets/video/`

---

## 13. Localization

**Library:** `easy_localization`  
**Files:** `assets/translations/en.json`, `assets/translations/ar.json`  
**Supported locales:** `ar` (default display), `en`

Usage:
```dart
'login.welcome_text'.tr()
'home.see_all'.tr()
```

Runtime language sync: `AppLocale.set('ar')` — updates the `lang` header on all subsequent API calls.

**Never hardcode user-facing strings** — always use translation keys.

---

## 14. Features Map

### User Features (`lib/features/user/`)
| Feature | Key screens/cubits |
|---------|-------------------|
| `auth` | Signup, OTP, signin, social (Google), forgot password, user info, fitness/diet system, health problems, BMI report |
| `user_home` | Home dashboard, articles, saved articles, scan meal (camera + Gemini AI), hydration details, steps/running details |
| `visits` | Visit log, visit details, diet plan, meal details, upcoming visit, assessments, change assessment requests |
| `workout` | Workout plan, workout details, workout video player, rest timer |
| `challenges` | Active challenges, suggested challenges, create challenge |
| `market` | Store home (banners/categories/products), product details, plans, favorites, cart, checkout, addresses, orders |
| `profile` | User profile, personal profile, change password, change phone, toggle notifications, language change, delete account |
| `progress` | Progress charts (fl_chart) |
| `notifications` | User notifications list, mark read |
| `ai_chat` | AI coach chat (google_generative_ai / Gemini) |

### Specialist Features (`lib/features/specialist/`)
| Feature | Key screens/cubits |
|---------|-------------------|
| `auth` | Login, logout (JWT + SecureCache) |
| `home` | Dashboard — client count, follow-up alerts, today's visits |
| `visits` | Assessment history, visit details, start/finish visit, custom plan (add/edit meals/workouts/activities), health report, goal update |
| `clients` | Clients list, client profile, upcoming/previous assessments, progress charts |
| `tasks` | Daily tasks list |
| `profile` | Specialist profile view and update |
| `notifications` | Specialist notifications, mark read |

### Shared Features (`lib/features/shared/`)
- Splash, onboarding, role selection, conversations/chat, AI chat

---

## 15. API Endpoints Reference

**Base:** `https://fitnessday.tech/api`  
**File:** `lib/core/constant/api_endpoints.dart`

### Auth
```
POST /auth/user/signup
POST /auth/user/signin
POST /auth/user/verify-otp
POST /auth/specialist/signin
POST /auth/specialist/signout
POST /auth/social
POST /auth/refresh
POST /auth/signout
POST /auth/forgot-password/send-otp
POST /auth/forgot-password/verify-otp
POST /auth/forgot-password/reset
POST /auth/forgot-password/resend-otp
```

### User
```
GET  /user-home
GET  /users/my-profile
POST /users/complete-personal-data
POST /users/submit-health-answers
GET  /health-questions
GET  /lookups/user
GET  /daily-tasks/days/:dayNumber
GET  /diet-plan?day=N
GET  /diet-plan/assessment/:id/days/:day/meals/:mealId
PATCH /diet-plan/assessment/:id/days/:day/meals/:mealId
GET  /workout-plan/days/:day/workouts
GET  /workout-plan/assessments/:id/days/:day/workouts/:workoutItemId
POST /workout-plan/assessments/:id/days/:day/workouts/:workoutItemId/sets/:setNum/complete
GET  /user-activities/assessments/:id/days/:day/activities/:activityId
POST /user-activities/assessments/:id/days/:day/activities/:activityId/hydration/increase
POST /user-activities/assessments/:id/days/:day/activities/:activityId/hydration/decrease
POST /user-activities/walking/sync
POST /user-activities/running/sync
GET  /user-assessments
GET  /user-assessments/:id/details
POST /assessment-change-requests
GET  /assessments/progress
GET  /articles
GET  /articles/saved
GET  /articles/:id
POST /articles/:id/save
GET  /notifications/:id/read
```

### Store / Market
```
GET  /store/home
GET  /products
GET  /products/:id
GET  /plans
GET  /plans/:id
GET  /cart
POST /cart
PATCH /cart/items/:itemIdentity
DELETE /cart/items/:itemIdentity
POST /cart/checkout
PATCH /orders/:orderId/coupon
PATCH /orders/:orderId/delivery
GET  /addresses
POST /addresses
PATCH /addresses/:id
DELETE /addresses/:id
POST /favorites
GET  /lookups/branches
```

### Specialist
```
GET  /specialist-home
GET  /specialist/my-profile
POST /specialist/update-my-profile
GET  /specialist/clients
GET  /specialist/clients/:id/profile
GET  /specialist/clients/:id/assessments/upcoming
GET  /specialist/clients/:id/assessments/previous
GET  /specialist/clients/:id/progress
GET  /specialist/daily-tasks
GET  /specialist/assessment-history
GET  /specialist/assessment-history/details/:id
POST /specialist/assessment-history/:id/start
POST /specialist/assessment-history/:id/finish
PATCH /specialist/assessment-history/:id/goal
PATCH /specialist/assessment-history/:id/health-report
GET  /specialist/assessments/meal-categories
GET  /specialist/assessments/meal-templates?mealCategoryId=X
GET  /specialist/assessments/exercises
GET  /specialist/assessments/activities
POST /specialist/assessments/:id/days/:day/meals
PATCH /specialist/assessments/:id/days/:day/meals/:mealId
POST /specialist/assessments/:id/days/:day/workouts
PATCH /specialist/assessments/:id/days/:day/workouts/:workoutItemId
POST /specialist/assessments/:id/days/:day/activities
PATCH /specialist/assessments/:id/days/:day/activities/:activityId
GET  /specialist/notifications
PATCH /specialist/notifications/:id/read
```

---

## 16. Data Flow Example (Full Stack)

Adding a meal to a specialist's custom plan:

```
UI (AddMealPage)
  → context.read<VisitDetailsCubit>().addDayMeal(assessmentId, dayNumber, params)

VisitDetailsCubit
  → AddSpecialistDayMealUseCase(SpecialistVisitsRepository).call(params)

SpecialistVisitsRepository (interface)
  ← SpecialistVisitsRepositoryImpl
      → SpecialistVisitsRemoteDataSourceImpl.addDayMeal(assessmentId, dayNumber, data)
        → ApiService.post(ApiEndpoints.addSpecialistDayMeal(assessmentId, dayNumber), data: data)
          → Dio (with TokenInterceptor)

Response path:
  Dio response → Model.fromJson() → toEntity() → ApiResult<T>
  → Repository returns Success(data) or FailureResult(failure)
  → Cubit emits success/failure state
  → UI rebuilds via BlocBuilder
```

---

## 17. Android Build Config

**File:** `android/app/build.gradle.kts`

```kotlin
minSdk = 26          // Health Connect requires API 26+
compileSdk = flutter.compileSdkVersion
JavaVersion.VERSION_17
isCoreLibraryDesugaringEnabled = true   // required by flutter_local_notifications
```

```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

Firebase GMS plugin applied for FCM.

---

## 18. Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | Cubit/BLoC state management |
| `equatable` | ^2.0.7 | State equality |
| `get_it` | ^8.2.0 | Dependency injection |
| `dio` | ^5.9.0 | HTTP client |
| `go_router` | ^16.2.4 | Navigation |
| `easy_localization` | ^3.0.8 | i18n |
| `flutter_screenutil` | ^5.9.3 | Responsive sizing |
| `get_storage` | ^2.1.1 | Non-sensitive cache |
| `flutter_secure_storage` | ^10.0.0-beta.4 | Token storage |
| `fl_chart` | ^1.1.1 | Progress charts |
| `video_player` | ^2.10.0 | Workout video playback |
| `health` | ^12.2.0 | HealthKit / Health Connect |
| `camera` | ^0.11.2+1 | Meal scan |
| `google_generative_ai` | ^0.4.7 | AI coach (Gemini) |
| `firebase_messaging` | ^16.0.0 | Push notifications |
| `flutter_local_notifications` | ^19.5.0 | Local notifications |
| `google_sign_in` | ^6.3.0 | Social auth |
| `shimmer` | ^3.0.0 | Loading skeletons |
| `flutter_image_compress` | ^2.4.0 | Image compression |
| `connectivity_plus` | ^6.1.0 | Offline detection |

---

## 19. Localization Key Namespaces

Keys follow dot-notation namespacing in `en.json` / `ar.json`:

```
login.*         — auth screens
home.*          — home dashboard
visits.*        — visits log
visit_details.* — visit details (day plans, report)
meal_details.*  — meal detail screen
add_meal.*      — add meal form
add_exercise.*  — add exercise form
add_activity.*  — add activity form
notifications.* — notification screens
conversations.* — chat screens
profile.*       — user profile
drawer.*        — side drawer
clients_page.*  — specialist clients
market.*        — store / market
challenges.*    — challenges feature
exercise_details_dialog.*
onboarding.*
role_selection.*
errors.*        — offline / network errors
```

---

## 20. Common Pitfalls & Rules

1. **`Future.wait` + typed results** — `Future.wait` returns `List<dynamic>`. Always use sequential `await` or explicit typing when results need to be cast to `ApiResult<T>`. The `List<dynamic>` cast crash in `UserHomeCubit` was caused by `Future.wait` returning untyped results.

2. **`SubscriptionPackageData` needs `id`** — the entity has an `id` field needed for the `ToggleFavoriteUseCase`. Always pass it when constructing the data object.

3. **`CartCubit` is a singleton** — registered with `registerLazySingleton` so the ✓ "in cart" state is shared across all store screens. Never create it with `registerFactory`.

4. **`CheckoutCubit` is a factory** — one instance per checkout flow, passed down via `BlocProvider.value` to child routes.

5. **Vertical tab bar** — use `VerticalDayTabBar` (not `VerticalTabBar`) everywhere. Props: `days:`, `selectedIndex:`, `onDaySelected:`.

6. **Article media** — `ArticleData.media` is `List<ArticleMediaItem>`. Fall back to `imageUrl` when empty.

7. **Coupon flow** — apply coupon via `PATCH /orders/:orderId/coupon` after order exists. `CouponStatus` enum: `idle/applying/applied/failed`.

8. **`ApiService.delete()`** exists — use it for cart item removal and address deletion.

9. **Token storage** — `accessToken` and `refreshToken` go in `SecureCache` (FlutterSecureStorage). Session flags (`isLoggedIn`, `userType`) go in `AppCache` (GetStorage).

10. **`AppLocale.set(lang)`** — call after every locale change to keep the `lang` header in sync with the current language.

---

## 21. Session Log

- **2026-07-25** — Initial CLAUDE.md created covering full architecture, all features, endpoints, patterns, and known pitfalls discovered during development.

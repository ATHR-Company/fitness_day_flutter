---
name: General & Flutter Engineering Rules
description: Strict architectural, styling, responsiveness, and localization constraints for the Flutter project.
---

# Section A — General Engineering Rules

## 1) Architecture & Separation of Concerns (YOU MUST FOLLOW)
- Follow the project's architecture layer boundaries strictly: presentation → domain → data
- Never bypass layers or mix responsibilities
- UI/presentation layer has ZERO business logic — only rendering, interaction, and state observation
- Business logic lives in the domain layer
- Data access (APIs, databases, storage) lives in the data layer
- Do not introduce new abstractions or patterns without justification

## 2) Shared Code & Asset Management (IMPORTANT)
- Any reusable logic, utility, constant, extension, or helper used in 2+ places goes in `core/`
- Check `core/` before creating new shared code — never duplicate across features
- **No Hardcoded/Static Paths:** Never use hardcoded asset paths, API endpoints, or routing strings directly in the UI. Centralize them into dedicated constants files (e.g., `AppAssets`, `ApiEndpoints`, `AppRoutes`) so everything remains reusable and maintainable.

## 3) Error Handling
- Errors flow cleanly across layers — never skip layers
- Handle null, empty, loading, and error states explicitly — no silent failures
- Catch errors at the boundary (data layer), not deep inside business logic

## 4) Change Discipline
- Make the smallest change that solves the problem
- Fix root causes, not symptoms
- Don't refactor unrelated code unless explicitly requested
- Never break existing functionality, APIs, flows, or UX unless explicitly instructed
- Read relevant code before modifying it — state assumptions when unclear

## 5) Dependencies
- Don't add new packages without justification
- Any new package must be: latest stable, well-maintained, production-grade

## 6) Security
- Never hardcode secrets, tokens, or credentials
- Never log sensitive information
- Validate all external and API input
- Proactively flag security risks when spotted

## 7) Testing
- Write tests for domain and data layer logic
- Bug fixes must include a reproducing test
- Tests must be deterministic — no flaky or timing-dependent tests
- One behavior per test case

---

# Section B — Flutter / Dart Specific Rules

## 1) State Management
- Use **Cubit/Bloc** for feature and application state — not Riverpod, Provider, or GetX
- Cubits depend ONLY on use cases — never directly on repositories or data sources
- `setState` is allowed ONLY for local UI state (e.g., toggles, form focus) — never for business logic
- Keep `setState` scoped to the smallest widget possible to avoid redundant rebuilds up the tree

## 2) No Code Generation
- **No Freezed. No build_runner.** Use Dart 3+ native features instead:
    - `sealed class` for state unions with exhaustive pattern matching
    - `switch` expressions and records for lightweight data

## 3) Domain Layer Purity
- Domain layer must have ZERO Flutter imports
- No `package:flutter/...` in any file under `domain/`

## 4) Feature Folder Structure
- `features/{feature_name}/data/`
- `features/{feature_name}/domain/`
- `features/{feature_name}/presentation/`

## 5) Error Handling Contract
- Data layer: catch exceptions and map to typed `Failure` classes
- Domain layer: return `ApiResult<T>` from use cases and repositories
- Presentation layer: map failures to user-friendly messages and UI states

## 6) Dependency Injection
- Use **`get_it`** as the service locator — not `Provider` or constructor-only injection
- Register dependencies in a single `core/di/` setup file
- Cubits, use cases, and repositories are resolved via `get_it`, not instantiated manually

## 7) Build Method Discipline (IMPORTANT)
- Prefer `const` constructors wherever possible
- NEVER create `TextEditingController`, `AnimationController`, `FocusNode`, or other expensive objects inside `build()`
- Avoid heavy work inside `build()` methods
- Dispose controllers and focus nodes in `StatefulWidget.dispose()`
- Prefer small, composed widgets to minimize rebuild scope
- Use `BlocBuilder`/`BlocSelector` on the smallest widget that needs the state — never at the top of the tree

## 8) UI Component Discipline & Custom Widgets
- **Widget Splitting:** Avoid long, deeply nested widget trees. Split complex layouts into smaller, focused private widgets within the same file, or move them to separate files if they exceed 100-150 lines.
- **Reusable Widgets:** Any custom button, text field, card, or UI pattern used across multiple screens must be built as a generic, parameterized reusable widget and placed in `core/widgets/`.

## 9) Responsiveness (MANDATORY)
- **Adaptability:** The app must look perfect on all screen sizes. Never use hardcoded pixel values for spacing, width, or height.
- **ScreenUtil Integration:** Wrap all dimensions, font sizes, margins, and paddings using **`flutter_screenutil`** extensions (e.g., `16.w`, `24.h`, `12.sp`, `EdgeInsets.all(16.r)`).

## 10) Localization & Typography
- **Localization (No Hardcoded Texts):** Never hardcode user-facing strings in UI files. All texts must be localized using **`easy_localization`** via translation keys (e.g., `'welcome_message'.tr()`) supporting all app languages.
- **Typography & Styling:** Never instantiate `TextStyle` inside widgets. All text styles must be retrieved exclusively from a centralized typography class (e.g., `AppStyles.font14Medium`), utilizing the app's theme system.

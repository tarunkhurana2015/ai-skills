# 07 - Phased Implementation Plan & Definition of Done

## 1. Phased Execution Roadmap

### Phase 1: Environment & Monorepo Foundation
- [ ] Verify developer environment (`flutter doctor`).
- [ ] Initialize workspace structure (`apps/`, `packages/`).
- [ ] Scaffold primary executable application (`apps/app`) for target platforms.
- [ ] Configure root theme tokens (`AppTheme`) and router foundation (`AppRouter`).

### Phase 2: Feature Packages & Contracts Scaffolding
- [ ] Scaffold `packages/[feature_1]_feature/` with `pubspec.yaml`, `l10n.yaml`, `docs/`, `test/`.
- [ ] Define domain entities as Freezed models (`@freezed`).
- [ ] Run code generation (`dart run build_runner build --delete-conflicting-outputs`) for `*.freezed.dart` and `*.g.dart`.
- [ ] Define immutable UI State classes with `copyWith`.
- [ ] Implement abstract domain repository interfaces.
- [ ] Write unit tests for ViewModels verifying initial states.

### Phase 3: Presentation, Routing & Localizations
- [ ] Implement ViewModels (`Notifier<State>`) handling business actions.
- [ ] Implement passive Views observing ViewModel state.
- [ ] Add `.arb` translation files and compile with `flutter gen-l10n`.
- [ ] Export `router.config.dart` from package and mount in host `AppRouter`.

### Phase 4: Integration, Hardening & Validation
- [ ] Wire package dependencies into `apps/app/pubspec.yaml`.
- [ ] Mount package localization delegates in `apps/app/lib/app.dart`.
- [ ] Execute `flutter analyze` ensuring zero warnings/errors.
- [ ] Execute `flutter test` across all packages and the host application.
- [ ] Verify execution on target platforms (`flutter run -d chrome`, `flutter run -d macos`, `flutter run -d ios`).

---

## 2. Definition of Done (DoD)
A feature or task is only considered **Done** when all of the following criteria are met:
1. **Spec Alignment**: Implementation matches Gherkin scenarios in `02_user_journeys_and_features.md`.
2. **Freezed Domain Models**: Domain entities are implemented as Freezed models (`@freezed`) with clean, generated `*.freezed.dart` and `*.g.dart` files.
3. **Localization**: All visible text strings are localized in `.arb` files; no hardcoded strings.
4. **Responsive**: UI adapts smoothly across compact, medium, and expanded breakpoints.
5. **Tested**: Unit test passes for ViewModel logic; widget test verifies key user flow.
6. **Clean Analysis**: `flutter analyze` reports 0 issues.
7. **No Breaking Changes**: All existing tests in `packages/` and `apps/` continue to pass.

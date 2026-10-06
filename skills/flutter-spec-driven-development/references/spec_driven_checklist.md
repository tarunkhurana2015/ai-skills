# Spec-Driven Development Readiness & Review Checklist

Before writing any code or executing scaffolding, the team must review and sign off on this checklist:

---

## 0. Prerequisite Environment Readiness (`flutter-environment-setup`)
- [ ] `./skills/flutter-environment-setup/scripts/verify_environment.sh` ran with zero blocking failures.
- [ ] `flutter doctor -v` reports clean status for all prioritized target platforms.
- [ ] Target devices/emulators verified (`flutter devices`).
- [ ] Target platform configs enabled (`enable-web`, `enable-macos-desktop`).

---

## 1. Scope & Product Spec (`01_product_scope.md`)
- [ ] App vision, value proposition, and personas are explicitly defined.
- [ ] Target platform matrix is prioritized (iOS, macOS Desktop, Web, Android).
- [ ] Clear in-scope MVP capabilities are identified (3–5 core features max).
- [ ] Explicit out-of-scope capabilities are recorded to prevent scope creep.

---

## 2. User Journeys & Gherkin Scenarios (`02_user_journeys_and_features.md`)
- [ ] Every in-scope feature has a corresponding User Story (`As a... I want... So that...`).
- [ ] Every feature has at least one happy path Gherkin scenario (`Given-When-Then`).
- [ ] Every feature has at least one edge case / error recovery Gherkin scenario.
- [ ] Scenarios test observable user behavior, not internal implementation mechanics.

---

## 3. Architecture & Monorepo Spec (`03_architecture_and_monorepo.md`)
- [ ] Monorepo structure (`apps/` vs `packages/`) is clearly mapped out.
- [ ] Each feature package adheres to MVVM (`router/`, `state/`, `viewmodel/`, `views/`).
- [ ] Dependency versions are pinned (e.g. `flutter_riverpod: ^3.3.2`, `go_router: ^17.5.0`, `freezed_annotation: ^2.4.4`).
- [ ] Modular routing strategy with `router.config.dart` is documented.

---

## 4. Design System & Responsive Spec (`04_design_system_and_responsive.md`)
- [ ] Material 3 color seeds, typography, and dark/light tokens are finalized.
- [ ] Responsive breakpoints are defined (Compact < 600, Medium 600–840, Expanded ≥ 840).
- [ ] Adaptation rules (BottomNav vs NavigationRail vs NavigationDrawer) are specified.

---

## 5. API & Data Contracts (`05_api_and_data_contracts.md`)
- [ ] Domain entity models are defined as Freezed models (`@freezed`) with `fromJson`/`toJson` factory constructors and `copyWith`.
- [ ] Code generation dependencies (`freezed_annotation`, `json_annotation`, `build_runner`, `freezed`, `json_serializable`) and build commands are specified.
- [ ] Request and response JSON payloads are fully documented.
- [ ] Error response formats (4xx, 5xx) are specified.
- [ ] Abstract repository interfaces decouple business logic from networking.

---

## 6. Testing Strategy (`06_testing_strategy.md`)
- [ ] Every Gherkin scenario maps to a unit or widget test.
- [ ] Mock boundaries are established for all external clients.
- [ ] CI quality gate commands are documented.

---

## 7. Phased Implementation Plan (`07_implementation_plan.md`)
- [ ] Development is broken down into sequential, verifiable milestones.
- [ ] Definition of Done (DoD) is agreed upon.

---

## 8. Scaffolding Execution Hand-off (`flutter-scaffold-project`)
- [ ] Specs validated cleanly with `validate_specs.sh`.
- [ ] Workspace scaffolded via `./skills/flutter-scaffold-project/scripts/scaffold_starter.sh`.
- [ ] Platform entitlements configured (e.g. macOS network client).
- [ ] Baseline test suites passing across all packages and host application.

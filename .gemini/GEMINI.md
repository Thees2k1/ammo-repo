## Introduction
 - Personal utilities library for Dart/Flutter project. embrace developer personal experience an DRY principle.
 - This project is a monorepo managed with `melos`, consisting of two sub-packages:
  1. `ammo-dart`: Pure Dart package providing opinionated Dart 3+ reusable helpers and utilities.
  2. `ammo-flutter`: Flutter package exposing widget helpers and Flutter-related utilities. It can depend on `ammo-dart`.

### Package Architecture & Dependency Rule
- **Inward Dependency Direction**: Outer apps/dependents -> `ammo-flutter` -> `ammo-dart`.
- Pure Dart utilities must reside in `ammo-dart`.
- When encountering or designing functionality in `ammo-flutter` that can be abstracted as pure Dart logic (without Flutter framework dependencies), extract it to `ammo-dart` first.

## Overview
1. Flutter Version control:
- `fvm` configured with `stable` channel (Flutter `3.47.6` / Dart `3.13.5`)
2. Repo manager
- `melos` (`8.9.0` globally activated via `fvm dart pub global activate melos`)
## Workspace Rules & Constraints

See dedicated agentic rules in [`.gemini/rules/melos_fvm.md`](file:///D:/Workplace/Personal/packages/ammo-repo/.gemini/rules/melos_fvm.md) for full Melos 8.x + FVM architecture and command specifications.

### Key Mandates
- **Always use FVM**: Prefix all raw Dart/Flutter commands with `fvm` (`fvm flutter ...`, `fvm dart ...`).
- **Formatting**: Format using `fvm dart format .` or `melos run format` before finalizing changes.
- **Zero Untested Code**: Any exposed public API must have automated tests.
- **Documentation**: All public APIs must have `///` method documentation for IDE hover support.

## Style
1. Embrace modern dart feature (post 3.13x): Record, pattern matching, Primary contructor.
2. SOLID principle adherence.
3. Every feature should be build with balancing between pratical and extensable. prevent over-engineer codes.
    - Prefer streamlined approach on small ulility + discriptive docs
    - Prefer SOLID, Clean and Maintainable code, Solve advance problem by composing sub-problem-solutions. let the code represent their own documentation.

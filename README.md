# Ammo Repository (`ammo-repo`)

A monorepo containing personal utility and helper libraries for modern Dart and Flutter projects, designed around developer ergonomics and the DRY (Don't Repeat Yourself) principle.

---

## 📦 Packages

| Package | Type | Directory | Description |
|---|---|---|---|
| [`ammo_dart`](file:///D:/Workplace/Personal/packages/ammo-repo/packages/ammo_dart) | Pure Dart | `packages/ammo_dart` | Reusable pure Dart utilities, extensions, and helpers (Dart 3+). |
| [`ammo_flutter`](file:///D:/Workplace/Personal/packages/ammo-repo/packages/ammo_flutter) | Flutter | `packages/ammo_flutter` | Flutter-specific utilities, widget helpers, and UI extensions. |

---

## 🏛️ Architecture & Dependency Flow

The monorepo enforces an **inward dependency direction**:

```
[ Outer Apps / Dependents ]
             │
             ▼
      [ ammo-flutter ]
             │
             ▼
       [ ammo-dart ]
```

- **Pure Dart First**: All general-purpose, non-UI utilities and logic reside in `ammo-dart`.
- **Extraction Rule**: If a utility or helper implemented in or planned for `ammo-flutter` does not strictly require Flutter framework dependencies (e.g. `dart:ui`, `package:flutter`), extract it to `ammo-dart` first.
- **Mono-repo Management**: Managed via [Melos](https://melos.invertase.dev/).

---

## 🛠️ Tooling & Standards

- **Flutter/Dart Version Management**: Managed using `fvm` configured to Flutter `stable` channel (Flutter `3.47.6` / Dart `3.13.5`).
- **Monorepo Tooling**: Managed using [`melos`](https://melos.invertase.dev/) (`8.9.0` globally activated via `fvm dart pub global activate melos`).
- **Workspace Commands**:
  - **Always prefix with FVM**: Run all Dart/Flutter commands via `fvm` (e.g., `fvm flutter test`, `fvm dart format .`).
  - **Resolve dependencies**: `fvm dart pub get`
  - **Run all lint & format checks**: `melos run lint:all`
  - **Run tests across packages**: `melos run test:all`
  - **Format code**: `melos run format` or `fvm dart format .`
  - **Code generation**: `melos run build_runner`
- **Code Standards**:
  - Modern Dart 3+ idioms (pattern matching, records, primary constructors).
  - SOLID design principles, avoiding over-engineering.
  - Comprehensive documentation with IDE hover support (`///`).
  - Strict test coverage for all exposed APIs.

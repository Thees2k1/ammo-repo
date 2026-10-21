# Melos & FVM Workspace Architecture Rules

These rules govern execution, dependency resolution, and multi-package management across the `ammo-repo` monorepo.

---

## 1. Environment & SDK Context
- **Flutter Version Manager (FVM)**: Configured at root with `stable` channel (Flutter `3.47.6` / Dart `3.13.5`).
- **Melos Version**: `8.9.0` globally activated.
- **Modern Dart Pub Workspaces (Melos 8.x Native)**:
  - No standalone `melos.yaml`. Configuration lives directly in root `pubspec.yaml` under the `melos:` key.
  - Root `pubspec.yaml` lists members under `workspace: [packages/**]`.
  - Packages live in `packages/` with strict Dart package naming conventions: `packages/ammo_dart` and `packages/ammo_flutter` (lowercase with underscores matching package names).
  - Subpackages opt-in to shared workspace resolution using `resolution: workspace`.
  - Inward workspace dependencies (e.g. `ammo_flutter` depending on `ammo_dart`) resolve without path overrides or `pubspec_overrides.yaml`.

---

## 2. Command Execution Rules

### Direct CLI Commands
- **Always prefix raw Dart/Flutter commands with `fvm`**:
  - `fvm flutter test`
  - `fvm dart analyze .`
  - `fvm dart format .`
  - `fvm dart pub get`

### Melos Multi-Package Commands
- `sdkPath: .fvm/flutter_sdk` is configured in the root `melos:` map, ensuring Melos internally delegates to the pinned FVM SDK.
- **Workspace Resolution**: `fvm dart pub get` (resolves all packages across the workspace).
- **Format Workspace**: `melos run format` (or `fvm dart format .`).
- **Analyze Workspace**: `melos run analyze`.
- **Test All Packages**: `melos run test:all` (delegates to `melos test`).
- **Scoped Tests**:
  - `melos run test:dart` (targets `ammo_dart`)
  - `melos run test:flutter` (targets `ammo_flutter`)
  - `melos exec --scope="<package>" -- <command>`
- **Code Generation**: `melos run build_runner`.

### Melos 8 Script Authoring Rules & Lessons Learned
- **`run` vs `exec` are Mutually Exclusive**:
  - `run: <command>` runs once at the monorepo root (e.g. `melos test`, `dart analyze .`). It does not change directory into packages.
  - `exec: { command: <command>, concurrency: 1 }` loops through packages matching `packageFilters` and runs inside each package directory.
  - Never combine `run:` and `exec:` on the same script (Melos 8 breaking change).
- **Hybrid Monorepo Testing (`dart test` vs `flutter test`)**:
  - Never run `dart test` across Flutter packages: Flutter code requires `flutter test` to link against `dart:ui`. Running `dart test` on Flutter code causes compilation failures.
  - For workspace-wide testing, use native `melos test` (it automatically dispatches `dart test` to Dart packages and `flutter test` to Flutter packages).
  - Use `concurrency: 1` in `exec:` test scripts to prevent multiple test runners from interleaving terminal output or causing race conditions.

---

## 3. Package Inward Flow & Extraction Rules
- **Dependency Flow**: Outer dependents -> `ammo_flutter` -> `ammo_dart`.
- Any utility or function drafted for `ammo_flutter` that has no strict dependency on Flutter framework (`dart:ui`, `package:flutter`) must be placed in or extracted to `ammo_dart` first.

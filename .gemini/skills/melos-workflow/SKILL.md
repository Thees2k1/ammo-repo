---
name: melos-fvm-workflow
description: >-
  Use this skill whenever building, testing, analyzing, or running scripts across
  packages in this Flutter/Dart monorepo using FVM and Melos.
---

# FVM & Melos Monorepo Runbook

This monorepo uses **Melos 8.x** with native **Dart Pub Workspaces** and **FVM** (Flutter `3.47.6` / Dart `3.13.5`), structured with industry standards under `packages/**`.

## Workspace Commands Reference

### 1. Dependency Resolution
Resolve dependencies across the entire workspace in a single pass:
```bash
fvm dart pub get
```

### 2. Code Quality & Static Analysis
Run all static analysis and format checks:
```bash
melos run lint:all
```
Run analyzer only:
```bash
melos run analyze
```
Format all Dart code across the repository:
```bash
melos run format
```
Check formatting compliance across all packages:
```bash
melos run format-check
```

### 3. Running Automated Tests
- **All tests across packages**:
  ```bash
  melos run test:all
  ```
  *(Uses `melos test --no-pub`, which automatically runs `dart test` for Dart packages and `flutter test` for Flutter packages).*
- **Pure Dart tests (`ammo_dart`)**:
  ```bash
  melos run test:dart
  ```
- **Flutter widget & unit tests (`ammo_flutter`)**:
  ```bash
  melos run test:flutter
  ```
- **Interactive/Scoped test selection**:
  ```bash
  melos run test:select
  ```
- **Scoped arbitrary test execution**:
  ```bash
  melos exec --scope="<package_name>" -- fvm flutter test
  ```
> **Note**: Never run `dart test` on Flutter packages (it lacks `dart:ui` bindings and will fail to compile). Scoped test scripts use `concurrency: 1` to prevent interleaving output.

### 4. Code Generation & Utilities
Execute `build_runner` on packages declaring it in dependencies:
```bash
melos run build_runner
```
Upgrade dependencies across packages:
```bash
melos run upgrade
```

### 5. Cleaning Workspace
Clean cached artifacts across all packages:
```bash
melos clean
```
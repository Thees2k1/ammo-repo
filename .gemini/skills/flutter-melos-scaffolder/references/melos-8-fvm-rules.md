# Melos 8.x + FVM Monorepo Engineering Reference

This reference documents the foundational rules, operational constraints, and architectural invariants for Dart & Flutter monorepos managed with **Melos 8.x**, **Dart Pub Workspaces**, and **FVM**.

---

## 1. Unified Configuration vs Standalone `melos.yaml`

In Melos 8.x and Dart 3.5+, the root `pubspec.yaml` is the single source of truth:
- **Do not create a `melos.yaml` file.** Embedding the `melos:` configuration directly into `pubspec.yaml` avoids duplicated project names, conflicting SDK bounds, and split metadata.
- Declare all sub-package globs under the top-level `workspace:` key:
  ```yaml
  workspace:
    - packages/**
    - apps/**
  ```
- Sub-packages opt into the unified workspace by declaring:
  ```yaml
  resolution: workspace
  ```

---

## 2. Dependency Resolution Invariants

- **No Path Overrides for Sibling Packages**:
  Because sub-packages participate in the same Pub workspace, declaring an inward dependency requires no local path or git URL:
  ```yaml
  dependencies:
    my_pkg_dart: # Automatically resolved to sibling package in workspace
  ```
- **Single Pass Workspace Pub Get**:
  Always resolve dependencies across the entire workspace from the monorepo root:
  - With FVM: `fvm dart pub get`
  - Without FVM: `dart pub get`
  Do not run `melos bootstrap` unless using legacy package resolution without Pub Workspaces.

---

## 3. Melos 8 Script Authoring Rules

### Rule A: `run` vs `exec` are Mutually Exclusive
Melos 8 enforces a strict separation:
- **`run: <command>`**: Runs a single command once at the workspace root directory.
  ```yaml
  analyze:
    run: dart analyze .
    description: "Run analyzer across root and all workspace packages"
  ```
- **`exec:`**: Iterates through packages matching `packageFilters` and executes the command inside each package's directory.
  ```yaml
  format-check:
    run: melos exec dart format . --set-exit-if-changed
  ```
  Or structured form:
  ```yaml
  build_runner:
    exec:
      command: dart run build_runner build --delete-conflicting-outputs
      concurrency: 1
    packageFilters:
      dependsOn: build_runner
  ```
- **Violation**: Defining both `run:` and `exec:` within the same script block causes Melos parsing errors.

### Rule B: Hybrid Monorepo Testing (`dart test` vs `flutter test`)
- Pure Dart packages run tests via the Dart VM test runner (`dart test`).
- Flutter packages require the Flutter test harness (`flutter test`) to link against `dart:ui` and platform channels.
- **Never run `dart test` on Flutter packages**: Dart VM cannot load `dart:ui` and will crash with compilation errors.
- **Root test runner**: Use `melos test --no-pub`. Melos automatically detects Flutter vs Dart packages and invokes the appropriate test runner.
- **Output Concurrency**: Always set `concurrency: 1` on test scripts iterating through packages to prevent interleaved, unreadable terminal output.

---

## 4. FVM (Flutter Version Manager) Integration

When FVM is enabled:
1. **Pin SDK in `.fvmrc`**:
   ```json
   { "flutter": "stable" }
   ```
2. **Explicit SDK Delegation in `pubspec.yaml`**:
   Ensure Melos uses the FVM-managed Flutter SDK rather than whichever Flutter is on system PATH:
   ```yaml
   melos:
     sdkPath: .fvm/flutter_sdk
   ```
3. **Git Ignore Rules**:
   Commit `.fvm/fvm_config.json` while ignoring generated SDK symlinks:
   ```gitignore
   .fvm/*
   !.fvm/fvm_config.json
   !.fvm/versions/
   ```
4. **Command Execution**:
   Prefix raw Dart/Flutter commands with `fvm`:
   - `fvm dart pub get`
   - `fvm flutter test`
   - Melos commands (`melos run ...`) automatically use `sdkPath` when configured.

---

## 5. Inward Dependency Architecture

Maintain a strict dependency flow:
```
[ Applications / Sandbox Catalogs ] (apps/*)
                 │
                 ▼
     [ Flutter UI Packages ]        (packages/*_flutter)
                 │
                 ▼
    [ Pure Dart Core Packages ]     (packages/*_dart)
```
- **Core logic** (models, state machines, business algorithms, network contracts) must remain in pure Dart (`*_dart`) without any Flutter dependency.
- **UI & Presentation** (`*_flutter`) depends on pure Dart core.
- This ensures maximum reusability, headless test execution speed, and clean separation between domain logic and rendering.

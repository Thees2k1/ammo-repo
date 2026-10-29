# Skill Blueprint: Flutter Melos Monorepo Scaffolder

## 1. Skill Metadata & Discovery (Frontmatter)

The description must be keyword-optimized for semantic matching so the agent triggers it when users ask to scaffold monorepos, set up Melos, or organize multi-package Flutter workspaces.

```yaml
---
name: flutter-melos-scaffolder
description: Scaffolds a multi-package Flutter and Dart monorepo using Melos, native pub workspaces, and FVM. Use when setting up workspace architecture, configuring candidate package matrices, or initializing multi-package R&D projects.
version: 1.0.0
tags:
  - flutter
  - dart
  - melos
  - monorepo
  - scaffolding
---
```

## 2. Recommended File & Directory Structure

To adhere to **progressive disclosure** and keep the core `SKILL.md` under 500 lines, structure the skill folder as follows:

```
flutter-melos-scaffolder/
├── SKILL.md                      # Core workflow rules and command reference
├── references/
│   └── melos-scripts.md          # Predefined Melos execution scripts & OS notes
├── templates/
│   ├── root-pubspec.yaml.template  # Dart workspace pubspec template
│   ├── melos.yaml.template       # Melos orchestration configuration template
│   └── analysis-options.yaml.template # Pinned global linter configuration
└── scripts/
    └── init-workspace.sh         # Automated setup & validation script
```

## 3. Core Workflow & Parameter Specifications

The skill must instruct the agent to parse and handle these specific inputs:

### Input Parameters & Flags

- `--packages=<list>`: Comma-separated names for candidate libraries (e.g., `candidate_a, candidate_b`).
- `--apps=<list>`: Comma-separated names for sandbox apps or catalogs (e.g., `sandbox_catalog`).
- `--use-fvm`: Flag to prefix Flutter/Dart commands with `fvm`.
- `--git-init`: Flag to initialize a git repository and commit initial scaffolding.

### Step-by-Step Execution Process for the Agent

1. **Validate Environment:** Check if `flutter`, `dart`, and `melos` are available (or via `fvm`).
2. **Directory Generation:** Create root structure (`packages/`, `apps/`, `docs/`, `references/`).
3. **Template Rendering:** Populate root files (`pubspec.yaml`, `melos.yaml`, `analysis_options.yaml`) using the templates folder.
4. **Sub-package Scaffolding:** Loop through packages/apps inputs and run `flutter create --template=package` or `app` inside respective subfolders.
5. **Post-Scaffold Verification:**
   - Run global dependency bootstrapping (`melos bootstrap`).
   - Execute global formatting and static analysis (`melos run analyze` / `melos run format`).
   - Run targeted execution tests in specific sub-repos if requested (`melos exec --scope=...`).

## 4. Operational Guidelines & Rules for the Agent

### What the Agent MUST Do:

- **OS-Aware Command Handling:** Reference `references/melos-scripts.md` to ensure scripts handle cross-platform differences (Windows PowerShell vs. macOS/Linux Bash).
- **Workspace Resolution:** Ensure root `pubspec.yaml` properly declares workspace globs (`packages/*`, `apps/*`) to leverage native Pub workspace linking.
- **Explicit Failure Handling:** If `melos bootstrap` fails due to version mismatches or SDK constraints, instruct the agent to inspect package-level pubspecs.

### What the Agent MUST NOT Do:

- Do **not** put verbose configuration code directly in `SKILL.md`; pull templates dynamically from `templates/`.
- Do **not** mix UI catalogs and backend/code-gen scaffolding rules unless explicitly requested.

## 5. Verification Checklist

Before finishing the scaffolding task, the agent must pass this internal checklist:

- [ ] Root `pubspec.yaml` contains `workspace:` array mapping packages and apps.
- [ ] `melos.yaml` includes scripts for clean, bootstrap, analyze, and test.
- [ ] `melos bootstrap` executes successfully with zero resolution errors.
- [ ] Global linting (`analysis_options.yaml`) is enforced across all sub-packages.

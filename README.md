# ai-skills

A curated repository of AI Agent Skills and workflows designed for Antigravity and AI coding assistants.

## Repository Architecture

This repository organizes skills under `skills/` at the root, and registers them directly with Antigravity via `.agents/skills.json` and a `.agents/skills` symlink for native workspace discovery.

```text
ai-skills/
├── .agents/
│   ├── skills.json                           # Antigravity customization registration
│   └── skills -> ../skills                   # Symlink for filesystem crawlers
├── skills/
│   ├── flutter-environment-setup/            # Flutter multi-platform environment skill
│   │   ├── SKILL.md                          # Main skill instructions and workflows
│   │   ├── scripts/
│   │   │   └── verify_environment.sh         # Executable environment diagnostic script
│   │   └── references/
│   │       ├── platform_troubleshooting.md   # Android, iOS, macOS, Web troubleshooting
│   │       └── fvm_guide.md                  # Flutter Version Management (FVM) setup
│   ├── flutter-scaffold-project/             # Feature-First Riverpod starter skill
│   │   ├── SKILL.md                          # Main scaffolding workflows
│   │   ├── scripts/
│   │   │   └── scaffold_starter.sh           # Automated starter project generator
│   │   └── references/
│   │       ├── feature_first_guide.md        # Architecture layout and layer guide
│   │       └── riverpod_best_practices.md    # Riverpod state & test patterns
│   └── flutter-spec-driven-development/      # Gated Spec-Driven Development (SDD) lifecycle
│       ├── SKILL.md                          # SDD workflow, gated interview protocol
│       ├── templates/                        # 7-stage specification templates (Freezed models)
│       ├── scripts/                          # init_specs.sh and validate_specs.sh
│       └── references/                       # SDD guide, Gherkin guide, checklist
└── README.md
```

## Available Skills

| Skill | Description | Platforms |
| :--- | :--- | :--- |
| [`flutter-environment-setup`](./skills/flutter-environment-setup/SKILL.md) | Validate, configure, and troubleshoot the Flutter development environment for Mobile (iOS, Android), macOS Desktop, and Web. Supports both standard Flutter CLI and FVM. | iOS, Android, macOS, Web |
| [`flutter-scaffold-project`](./skills/flutter-scaffold-project/SKILL.md) | Scaffold a production-ready Flutter starter project using Feature-First architecture, Riverpod, GoRouter, and Material 3. Includes automated generator script. | iOS, macOS, Web, Android |
| [`flutter-spec-driven-development`](./skills/flutter-spec-driven-development/SKILL.md) | Guide and execute Spec-Driven Development (SDD) across 7 gated stages with Freezed domain models, Gherkin criteria, and automated monorepo handoff. | iOS, macOS, Web, Android |

## Quick Start

### 1. Diagnostic Check
To verify your local Flutter multi-platform development environment:

```bash
./skills/flutter-environment-setup/scripts/verify_environment.sh --skip-android
```

### 2. Scaffold a Starter App
To generate a new feature-first Flutter application with Riverpod & GoRouter:

```bash
./skills/flutter-scaffold-project/scripts/scaffold_starter.sh \
  --name my_app \
  --org com.mycompany \
  --platforms ios,macos,web
```
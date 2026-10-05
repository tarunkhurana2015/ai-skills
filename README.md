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
│   └── flutter-environment-setup/            # Flutter multi-platform environment skill
│       ├── SKILL.md                          # Main skill instructions and workflows
│       ├── scripts/
│       │   └── verify_environment.sh         # Executable environment diagnostic script
│       └── references/
│           ├── platform_troubleshooting.md   # Android, iOS, macOS, Web troubleshooting
│           └── fvm_guide.md                  # Flutter Version Management (FVM) setup
└── README.md
```

## Available Skills

| Skill | Description | Platforms |
| :--- | :--- | :--- |
| [`flutter-environment-setup`](./skills/flutter-environment-setup/SKILL.md) | Validate, configure, and troubleshoot the Flutter development environment for Mobile (iOS, Android), macOS Desktop, and Web. Supports both standard Flutter CLI and FVM. | iOS, Android, macOS, Web |

## Quick Diagnostic

To quickly test and verify your local Flutter multi-platform development environment:

```bash
./skills/flutter-environment-setup/scripts/verify_environment.sh
```
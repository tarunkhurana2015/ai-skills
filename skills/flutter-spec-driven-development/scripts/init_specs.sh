#!/usr/bin/env bash
# Flutter Spec-Driven Development: Initialize Specs Directory Script
# Populates specs/ with standard templates for all 7 SDD stages or a specific stage.

set -euo pipefail

TARGET_DIR="."
STAGE_OPT="all"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -d, --dir <path>             Target project directory (default: current directory)"
  echo "  -s, --stage <1-7|all>        Stage template to initialize (1 to 7, or 'all', default: all)"
  echo "  -h, --help                   Display this help message"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    -s|--stage)
      STAGE_OPT="$2"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

DEST_SPECS_DIR="$TARGET_DIR/specs"

echo "==> Initializing specs directory at: $DEST_SPECS_DIR..."
mkdir -p "$DEST_SPECS_DIR"

# Ensure specs/README.md exists
if [ ! -f "$DEST_SPECS_DIR/README.md" ]; then
cat << 'EOF' > "$DEST_SPECS_DIR/README.md"
# Project Specifications (Single Source of Truth)

This directory contains the authoritative specifications for the project following the **Spec-Driven Development (SDD)** lifecycle:

| Specification Document | Purpose |
|---|---|
| [`01_product_scope.md`](./01_product_scope.md) | Vision, target audience, platform matrix, and MVP scope boundaries |
| [`02_user_journeys_and_features.md`](./02_user_journeys_and_features.md) | User journeys, Gherkin acceptance criteria (`Given/When/Then`), and edge cases |
| [`03_architecture_and_monorepo.md`](./03_architecture_and_monorepo.md) | Monorepo layout (`apps/` vs `packages/`), MVVM, state management, and routing |
| [`04_design_system_and_responsive.md`](./04_design_system_and_responsive.md) | Material 3 tokens, responsive breakpoints, and accessibility |
| [`05_api_and_data_contracts.md`](./05_api_and_data_contracts.md) | Freezed domain entities, DTOs, JSON payloads, and repository interfaces |
| [`06_testing_strategy.md`](./06_testing_strategy.md) | Testing pyramid, Gherkin test mappings, and CI quality gates |
| [`07_implementation_plan.md`](./07_implementation_plan.md) | Phased roadmap and Definition of Done (DoD) |

## Gated Workflow
1. Complete Stage 0 Environment Verification (`flutter-environment-setup`).
2. Complete each spec gate (1 to 7) sequentially with developer interview and sign-off.
3. Validate specs using `validate_specs.sh`.
4. Scaffold the workspace using `flutter-scaffold-project`.
EOF
fi

TEMPLATES=(
  "01_product_scope"
  "02_user_journeys_and_features"
  "03_architecture_and_monorepo"
  "04_design_system_and_responsive"
  "05_api_and_data_contracts"
  "06_testing_strategy"
  "07_implementation_plan"
)

if [ "$STAGE_OPT" = "all" ]; then
  for T in "${TEMPLATES[@]}"; do
    if [ ! -f "$DEST_SPECS_DIR/${T}.md" ]; then
      cp "$SKILL_DIR/templates/${T}.template.md" "$DEST_SPECS_DIR/${T}.md"
      echo "  Created: $DEST_SPECS_DIR/${T}.md"
    else
      echo "  Exists: $DEST_SPECS_DIR/${T}.md (skipped)"
    fi
  done
  echo "==> Success! All 7 specification templates ready in $DEST_SPECS_DIR."
elif [[ "$STAGE_OPT" =~ ^[1-7]$ ]]; then
  IDX=$((STAGE_OPT - 1))
  T="${TEMPLATES[$IDX]}"
  if [ ! -f "$DEST_SPECS_DIR/${T}.md" ]; then
    cp "$SKILL_DIR/templates/${T}.template.md" "$DEST_SPECS_DIR/${T}.md"
    echo "  Created Stage $STAGE_OPT template: $DEST_SPECS_DIR/${T}.md"
  else
    echo "  Stage $STAGE_OPT spec already exists: $DEST_SPECS_DIR/${T}.md"
  fi
else
  echo "Error: Unknown stage '$STAGE_OPT'. Use '1' through '7' or 'all'."
  exit 1
fi

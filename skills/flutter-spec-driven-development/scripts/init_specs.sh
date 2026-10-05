#!/usr/bin/env bash
# Flutter Spec-Driven Development: Initialize Specs Directory Script
# Populates specs/ with standard templates for all 7 SDD stages.

set -euo pipefail

TARGET_DIR="."
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -d, --dir <path>             Target project directory (default: current directory)"
  echo "  -h, --help                   Display this help message"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      TARGET_DIR="$2"
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

# Copy all templates
cp "$SKILL_DIR/templates/01_product_scope.template.md" "$DEST_SPECS_DIR/01_product_scope.md"
cp "$SKILL_DIR/templates/02_user_journeys_and_features.template.md" "$DEST_SPECS_DIR/02_user_journeys_and_features.md"
cp "$SKILL_DIR/templates/03_architecture_and_monorepo.template.md" "$DEST_SPECS_DIR/03_architecture_and_monorepo.md"
cp "$SKILL_DIR/templates/04_design_system_and_responsive.template.md" "$DEST_SPECS_DIR/04_design_system_and_responsive.md"
cp "$SKILL_DIR/templates/05_api_and_data_contracts.template.md" "$DEST_SPECS_DIR/05_api_and_data_contracts.md"
cp "$SKILL_DIR/templates/06_testing_strategy.template.md" "$DEST_SPECS_DIR/06_testing_strategy.md"
cp "$SKILL_DIR/templates/07_implementation_plan.template.md" "$DEST_SPECS_DIR/07_implementation_plan.md"

# Create specs/README.md
cat << 'EOF' > "$DEST_SPECS_DIR/README.md"
# Project Specifications (Single Source of Truth)

This directory contains the authoritative specifications for the project following the **Spec-Driven Development (SDD)** lifecycle:

| Specification Document | Purpose |
|---|---|
| [`01_product_scope.md`](./01_product_scope.md) | Vision, target audience, platform matrix, and MVP scope boundaries |
| [`02_user_journeys_and_features.md`](./02_user_journeys_and_features.md) | User journeys, Gherkin acceptance criteria (`Given/When/Then`), and edge cases |
| [`03_architecture_and_monorepo.md`](./03_architecture_and_monorepo.md) | Monorepo layout (`apps/` vs `packages/`), MVVM, state management, and routing |
| [`04_design_system_and_responsive.md`](./04_design_system_and_responsive.md) | Material 3 tokens, responsive breakpoints, and accessibility |
| [`05_api_and_data_contracts.md`](./05_api_and_data_contracts.md) | Entities, DTOs, JSON payloads, and repository interfaces |
| [`06_testing_strategy.md`](./06_testing_strategy.md) | Testing pyramid, Gherkin test mappings, and CI quality gates |
| [`07_implementation_plan.md`](./07_implementation_plan.md) | Phased roadmap and Definition of Done (DoD) |

## Workflow
1. Fill out each spec sequentially.
2. Review and sign off using the SDD review checklist.
3. Once approved, scaffold and implement code in alignment with these specs.
EOF

echo "==> Success! 7 specification templates created in $DEST_SPECS_DIR."
echo "Next step: Author specs sequentially starting with 01_product_scope.md."

#!/usr/bin/env bash
# Flutter Spec-Driven Development: Validate Specs Readiness Script
# Checks that all 7 spec files exist and verifies readiness for implementation.

set -euo pipefail

TARGET_DIR="."

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

SPECS_DIR="$TARGET_DIR/specs"

if [ ! -d "$SPECS_DIR" ]; then
  echo "Error: Specs directory not found at $SPECS_DIR."
  echo "Run init_specs.sh first to create spec templates."
  exit 1
fi

REQUIRED_SPECS=(
  "01_product_scope.md"
  "02_user_journeys_and_features.md"
  "03_architecture_and_monorepo.md"
  "04_design_system_and_responsive.md"
  "05_api_and_data_contracts.md"
  "06_testing_strategy.md"
  "07_implementation_plan.md"
)

echo "==> Auditing specifications in $SPECS_DIR..."

TOTAL_SPECS=${#REQUIRED_SPECS[@]}
PASSED_SPECS=0
WARNINGS=0

for SPEC in "${REQUIRED_SPECS[@]}"; do
  SPEC_PATH="$SPECS_DIR/$SPEC"
  if [ ! -f "$SPEC_PATH" ]; then
    echo "  [FAIL] Missing spec file: $SPEC"
    continue
  fi

  FILE_SIZE=$(wc -c < "$SPEC_PATH" | tr -d ' ')
  if [ "$FILE_SIZE" -lt 100 ]; then
    echo "  [FAIL] Spec file is too short or empty (<100 bytes): $SPEC"
    continue
  fi

  # Check for unedited placeholder brackets [e.g. or [Name
  PLACEHOLDER_COUNT=$(grep -o "\[e\.g\." "$SPEC_PATH" 2>/dev/null | wc -l | tr -d ' ' || true)
  TODO_COUNT=$(grep -i -o "\[TODO" "$SPEC_PATH" 2>/dev/null | wc -l | tr -d ' ' || true)

  if [ "$PLACEHOLDER_COUNT" -gt 0 ] || [ "$TODO_COUNT" -gt 0 ]; then
    echo "  [WARN] Spec has unfilled placeholders ($PLACEHOLDER_COUNT examples, $TODO_COUNT TODOs): $SPEC"
    ((WARNINGS++))
  else
    echo "  [PASS] Spec verified: $SPEC"
  fi

  ((PASSED_SPECS++))
done

echo ""
echo "=========================================="
echo "SDD Audit Summary: $PASSED_SPECS / $TOTAL_SPECS specs present"
if [ "$WARNINGS" -gt 0 ]; then
  echo "Notice: $WARNINGS specs contain unfilled placeholders or example markers."
fi
echo "=========================================="

if [ "$PASSED_SPECS" -eq "$TOTAL_SPECS" ] && [ "$WARNINGS" -eq 0 ]; then
  echo "Status: READY FOR CODE IMPLEMENTATION."
  exit 0
elif [ "$PASSED_SPECS" -eq "$TOTAL_SPECS" ]; then
  echo "Status: SPECS PRESENT WITH UNFILLED PLACEHOLDERS. Review before coding."
  exit 0
else
  echo "Status: INCOMPLETE SPECS. Missing required spec files."
  exit 1
fi

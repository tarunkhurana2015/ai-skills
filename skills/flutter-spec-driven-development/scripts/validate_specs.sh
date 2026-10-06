#!/usr/bin/env bash
# Flutter Spec-Driven Development: Validate Specs Readiness Script
# Checks that spec files exist and verifies readiness for implementation.
# Supports checking all 7 stages or a specific stage (--stage <1-7>).

set -euo pipefail

TARGET_DIR="."
STAGE_FILTER=""

print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -d, --dir <path>             Target project directory (default: current directory)"
  echo "  -s, --stage <1-7>            Validate only a specific stage gate (1 to 7)"
  echo "  -h, --help                   Display this help message"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    -s|--stage)
      STAGE_FILTER="$2"
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
  echo "Run init_specs.sh first or create specs directory."
  exit 1
fi

ALL_SPECS=(
  "01_product_scope.md"
  "02_user_journeys_and_features.md"
  "03_architecture_and_monorepo.md"
  "04_design_system_and_responsive.md"
  "05_api_and_data_contracts.md"
  "06_testing_strategy.md"
  "07_implementation_plan.md"
)

REQUIRED_SPECS=()

if [ -n "$STAGE_FILTER" ]; then
  if [[ "$STAGE_FILTER" =~ ^[1-7]$ ]]; then
    IDX=$((STAGE_FILTER - 1))
    REQUIRED_SPECS=("${ALL_SPECS[$IDX]}")
    echo "==> Auditing Stage $STAGE_FILTER specification: ${REQUIRED_SPECS[0]} in $SPECS_DIR..."
  else
    echo "Error: Invalid stage '$STAGE_FILTER'. Must be between 1 and 7."
    exit 1
  fi
else
  REQUIRED_SPECS=("${ALL_SPECS[@]}")
  echo "==> Auditing all 7 specifications in $SPECS_DIR..."
fi

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

  # Check for unedited placeholder brackets [e.g. or [Name or [TODO
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
if [ -n "$STAGE_FILTER" ]; then
  echo "SDD Stage $STAGE_FILTER Audit: $PASSED_SPECS / $TOTAL_SPECS specs passed"
else
  echo "SDD Audit Summary: $PASSED_SPECS / $TOTAL_SPECS specs present"
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "Notice: $WARNINGS spec(s) contain unfilled placeholders or example markers."
fi
echo "=========================================="

if [ "$PASSED_SPECS" -eq "$TOTAL_SPECS" ] && [ "$WARNINGS" -eq 0 ]; then
  if [ -n "$STAGE_FILTER" ]; then
    echo "Status: STAGE $STAGE_FILTER GATE READY FOR DEVELOPER SIGN-OFF."
  else
    echo "Status: ALL SPECS APPROVED. READY FOR CODE IMPLEMENTATION."
  fi
  exit 0
elif [ "$PASSED_SPECS" -eq "$TOTAL_SPECS" ]; then
  echo "Status: SPECS PRESENT WITH UNFILLED PLACEHOLDERS. Review before sign-off."
  exit 0
else
  echo "Status: INCOMPLETE SPECS. Missing required spec files."
  exit 1
fi

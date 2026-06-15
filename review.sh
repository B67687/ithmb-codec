#!/usr/bin/env bash
# review.sh — unified quality pipeline orchestrator
# Single source of truth for all project quality checks.
# Usage:
#   bash review.sh              run all available stages
#   bash review.sh test codeql  run specific stages
#   bash review.sh --list       enumerate stages
#   bash review.sh --fix        auto-fix where possible (editor layer)
#
# Stages map 1:1 to CI workflow steps. Adding a stage here makes it
# uniformly available locally and in CI.

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

# ---- Stage registry ----
# Each stage: name|description|auto_fixable|function

STAGES=()
stage() { STAGES+=("$1|$2|$3|$4"); }

stage editor "EditorConfig + Roslyn analyzers (dotnet format --verify-no-changes)" \
  true run_editor
stage precommit "pre-commit hooks (trailing-whitespace, JSON/YAML lint, markdown)" \
  false run_precommit
stage commitlint "Conventional commit enforcement (.commitlintrc.json)" \
  false run_commitlint
stage test "dotnet test -c Release" \
  false run_test
stage ocr "LLM review via Alibaba OCR (if installed)" \
  false run_ocr
stage codeql "CodeQL security analysis (if installed)" \
  false run_codeql
stage links "Broken link check via lychee (if installed)" \
  false run_links

# ---- Stage implementations ----

run_editor() {
  echo "--- Editor layer: dotnet format ---"
  if [ "${FIX:-}" = "true" ]; then
    dotnet format && echo "PASS (auto-fix applied)" || {
      echo "FAIL"
      return 1
    }
  else
    dotnet format --verify-no-changes && echo "PASS" || {
      echo "FAIL — run 'bash review.sh --fix' to auto-fix"
      return 1
    }
  fi
}

run_precommit() {
  echo "--- Pre-commit hooks ---"
  if command -v pre-commit &>/dev/null; then
    pre-commit run --all-files 2>&1 && echo "PASS" || {
      echo "FAIL — some hooks failed"
      return 1
    }
  else
    echo "SKIP (pre-commit not installed)"
  fi
}

run_commitlint() {
  echo "--- Commit convention ---"
  if command -v commitlint &>/dev/null; then
    commitlint --from HEAD~1 --to HEAD --config .commitlintrc.json 2>&1 &&
      echo "PASS" || {
      echo "FAIL — commit message violates convention"
      return 1
    }
  else
    echo "SKIP (commitlint not installed)"
  fi
}

run_test() {
  echo "--- Test layer: dotnet test -c Release ---"
  dotnet test src/IthmbCodec/test/IthmbCodec.Tests.csproj -c Release --verbosity normal && echo "PASS" || {
    echo "FAIL"
    return 1
  }
}

run_ocr() {
  echo "--- LLM review (OCR) ---"
  if command -v ocr &>/dev/null; then
    ocr review --from main --to HEAD --audience agent --format text 2>&1 && echo "PASS (review generated)" || {
      echo "FAIL"
      return 1
    }
  else
    echo "SKIP (ocr CLI not installed)"
  fi
}

run_codeql() {
  echo "--- CodeQL security ---"
  if command -v codeql &>/dev/null; then
    codeql database create --language=csharp --source-root=. --overwrite /tmp/ithmb-codeql 2>&1 &&
      codeql database analyze /tmp/ithmb-codeql --format=sarif-latest --output=/tmp/ithmb-results.sarif 2>&1 &&
      echo "PASS" || {
      echo "FAIL"
      return 1
    }
  else
    echo "SKIP (codeql CLI not installed)"
  fi
}

run_links() {
  echo "--- Link check (lychee) ---"
  if command -v lychee &>/dev/null; then
    lychee --verbose --no-progress --config .lycheeignore '**/*.md' '**/*.html' 2>&1 &&
      echo "PASS" || {
      echo "FAIL — broken links found"
      return 1
    }
  else
    echo "SKIP (lychee not installed)"
  fi
}

# ---- CLI dispatch ----

show_list() {
  echo "Available pipeline stages:"
  for entry in "${STAGES[@]}"; do
    IFS='|' read -r name desc fixable func <<<"$entry"
    fixable_str=""
    [ "$fixable" = "true" ] && fixable_str=" (--fix)"
    printf "  %-14s %s%s\n" "$name" "$desc" "$fixable_str"
  done
  echo ""
  echo "Run 'bash review.sh [stage...]' to execute specific stages."
  echo "Default (no args): run all stages."
}

FIX="false"
REQUESTED_STAGES=()

for arg in "$@"; do
  case "$arg" in
  --list)
    show_list
    exit 0
    ;;
  --fix) FIX="true" ;;
  --help)
    show_list
    exit 0
    ;;
  *) REQUESTED_STAGES+=("$arg") ;;
  esac
done

# If no stages requested, run all
if [ ${#REQUESTED_STAGES[@]} -eq 0 ]; then
  for entry in "${STAGES[@]}"; do
    IFS='|' read -r name desc fixable func <<<"$entry"
    REQUESTED_STAGES+=("$name")
  done
fi

# Execute requested stages
EXIT_CODE=0
for stage_name in "${REQUESTED_STAGES[@]}"; do
  found=false
  for entry in "${STAGES[@]}"; do
    IFS='|' read -r name desc fixable func <<<"$entry"
    if [ "$name" = "$stage_name" ]; then
      found=true
      echo ""
      echo "========================================"
      echo "  [$stage_name] $desc"
      echo "========================================"
      if ! $func; then
        EXIT_CODE=1
      fi
      break
    fi
  done
  if [ "$found" = false ]; then
    echo "ERROR: unknown stage '$stage_name'. Run 'bash review.sh --list'"
    EXIT_CODE=1
  fi
done

echo ""
echo "=== Pipeline complete (exit code: $EXIT_CODE) ==="
exit $EXIT_CODE

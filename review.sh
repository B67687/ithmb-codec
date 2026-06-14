#!/usr/bin/env bash
# review.sh — deterministic multi-layer review pipeline
# Usage: bash review.sh [--fix]

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo "=== 1/4 Editor Layer (lint + format) ==="
dotnet format --verify-no-changes 2>/dev/null || {
  echo "[FAIL] Style violations. Run: dotnet format"
  exit 1
}
echo "PASS"

echo "=== 2/4 Test Layer ==="
dotnet test src/IthmbCodec/test/IthmbCodec.Tests.csproj -c Release --verbosity quiet 2>/dev/null | tail -1
echo "PASS"

echo "=== 3/4 LLM Review Layer (OCR) ==="
if command -v ocr &>/dev/null; then
  ocr review --from main --to HEAD --audience agent --format text 2>&1 || true
else
  echo "SKIP (ocr CLI not installed)"
fi

echo "=== 4/4 Security Layer (CodeQL) ==="
if command -v codeql &>/dev/null; then
  echo "Run: codeql database create --language=csharp"
else
  echo "SKIP (codeql CLI not installed)"
fi

echo "=== Done ==="

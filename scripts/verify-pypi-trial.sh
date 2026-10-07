#!/usr/bin/env bash
# verify-pypi-trial.sh — local pre-flight for the TestPyPI trial pipeline.
# Replicates .github/workflows/test-publish.yml gates WITHOUT spending CI minutes:
#   rename audit, zero-tokens audit, wheel build, clean-venv install + version check.
# Run from repo root BEFORE pushing pymod/workflow changes: bash scripts/verify-pypi-trial.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== 1/4 rename audit (no ithmb-python outside flagged history) ==="
if grep -rn "ithmb-python" --include="*.toml" --include="*.yml" --include="*.md" --include="*.rs" --include="*.py" --include="*.pyi" . 2>/dev/null \
  | grep -v -e "\.venv/" -e "target/" -e "uv\.lock" -e "Cargo\.lock" -e "\.omo/" -e "\.playwright-mcp/" \
  | grep -v -e "^\./docs/" \
  | grep -v -e "test-publish\.yml" -e "RELEASE_NOTES\|release\.yml.*manual\|docs\.python\|sdist.*history" ; then
  echo "FAIL: stale ithmb-python references above"; exit 1
fi
echo "ok: rename clean"

echo "=== 2/4 zero-tokens audit (no PyPI credentials in tree) ==="
if grep -rniE "pypi-[A-Za-z0-9_-]{20,}|://__token__@|twine.*(password|token)|POETRY_PYPI_TOKEN" \
  --include="*.yml" --include="*.toml" --include="*.cfg" --include="*.ini" --include="*.env" . 2>/dev/null \
  | grep -v "test-publish.yml"; then
  echo "FAIL: possible credential above"; exit 1
fi
echo "ok: no tokens"

echo "=== 3/4 wheel build (maturin, local toolchain) ==="
command -v maturin >/dev/null || { echo "install maturin first: pip install maturin"; exit 1; }
maturin build --release --manifest-path pymod/Cargo.toml 2>&1 | tail -2

echo "=== 4/4 clean-venv install + version/profile check (local wheel) ==="
CARGO_VER=$(grep '^version = ' Cargo.toml | head -1 | cut -d'"' -f2)
rm -rf /tmp/pypi-preflight-venv
python3 -m venv /tmp/pypi-preflight-venv
WHEEL=$(ls -t target/wheels/*.whl | head -1)
echo "installing newest wheel: $WHEEL"
/tmp/pypi-preflight-venv/bin/pip -q install "$WHEEL"
/tmp/pypi-preflight-venv/bin/python -c "
import ithmb_core
assert ithmb_core.__version__ == '$CARGO_VER', f'version mismatch: {ithmb_core.__version__} != $CARGO_VER'
assert len(ithmb_core.list_profiles()) == 53, 'expected 53 active profiles'
print(f'ok: local wheel {ithmb_core.__version__} == Cargo, 53 profiles')
"
echo "ALL PRE-FLIGHT CHECKS PASSED — safe to push (CI remains the gate)."

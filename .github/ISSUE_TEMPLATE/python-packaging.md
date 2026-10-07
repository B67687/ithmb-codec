---
name: Python packaging issue
about: Install or wheel problems with the ithmb-codec Python package
title: ""
labels: packaging
assignees: ""
---

## What failed

`pip install ithmb-codec` error, wrong wheel, or import failure after install.

## Required info (reports without these will be asked to add them)

- `pip --version` output:
- Python version (`python --version`):
- Platform/arch (`uname -m` / Windows version):
- Wheel filename attempted (or `pip install` command used):
- Index used: [ ] real PyPI / [ ] TestPyPI trial (`--index-url https://test.pypi.org/simple/`)
- Full install log (paste below or attach):

```
<paste here>
```

## After install (if install succeeded but import/use failed)

- `python -c "import ithmb_core; print(ithmb_core.list_profiles())"` output:

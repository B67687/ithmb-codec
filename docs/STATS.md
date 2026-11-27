# Project Statistics

Stable, code-verifiable numbers for the Ithmb-Codec Rust workspace. Test-case,
fuzz-iteration, and commit counts change with every run, so this file does not
pin them; `cargo nextest` and the CI workflows (`.github/workflows/`) report
those. Other documentation should reference this file rather than duplicating
the stable values.

## Codec

| Stat | Value |
|------|-------|
| Decoders | 8 (RGB565, RGB555, ReorderedRGB555, UYVY, YCbCr420, CL, CLCL, JPEG) |
| Encoders | 7 (same minus JPEG) |
| Built-in profiles | 53 active profiles (54th raw entry, prefix 1044, disabled at load) |
| Device profiles | 18 iPod/iPhone generations |
| Max frame size | 810 KiB (829,440 bytes; 480×864 RGB565) |

## Test and verification assets

| Stat | Value |
|------|-------|
| Golden test vectors | 14 `.enc`/`.bin` pairs in `crates/ithmb-core/tests/fixtures/` |
| libfuzzer targets | 6 in `fuzz/fuzz_targets/` |
| Divan benchmark targets | 6 in `crates/ithmb-core/benches/` |

## Codebase

| Stat | Value |
|------|-------|
| Source modules | 21 in `ithmb-core` (default), 23 with `cache` + `metrics` |
| Workspace members | 5 (`ithmb-core`, `ithmb-cli`, `ithmb-gen`, `ithmb-wasm`, `pymod`) |

## Performance

See [`BENCHMARKS.md`](benchmarks/BENCHMARKS.md) for full benchmark data across all decoders, resolutions, and input patterns.

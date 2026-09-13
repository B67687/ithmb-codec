# Test fixtures — families, provenance, regeneration

Three fixture families live in this repo. They differ in provenance, and the
difference matters: only independently-produced vectors can catch a systematic
bug in our own encoder/decoder pair.

## Family 1 — golden `.enc`/`.bin` pairs (strongest)

- Location: `crates/ithmb-core/tests/fixtures/` (`*_solid_white_*`,
  `*_gradient_*`, `rgb565_solid_red_2x2`, `uyvy_interlaced_4x4`, `cl_*`, `jpeg_*`).
- Provenance: **independent** — `.enc` inputs produced by the C# reference
  encoder (archived `Ithmb-Codec-CSharp` repo), `.bin` = expected BGRA.
- Consumed by: `crates/ithmb-core/tests/golden_comparison.rs` — decodes each
  `.enc` with the Rust decoder, asserts bit-exact BGRA against `.bin`.
- Strength: encoder and decoder come from different codebases; agreement proves
  compatibility, not just self-consistency.

## Family 2 — golden F-files + PNGs + manifest (real-device shapes)

- Location: `crates/ithmb-core/tests/fixtures/golden/` (`F1061_1`, `F1055_1`,
  `F1060_1` multi-frame files + 30 `*_off*_decl*slot*.png` + `manifest.csv`).
- Provenance: **generated, parser-validated** — synthetic iPod Classic 6/7G
  artwork-cache shapes; an independent parser walks the `ArtworkDB` cleanly and
  every raw thumbnail sha256 round-trips against the manifest. Full write-up:
  `samples/reuhno-reference/README.md` (slot-vs-declared-rect subtlety, magenta
  padding, MSB-replication note).
- Consumed by: `golden_comparison.rs` "Reuhno synthetic golden vectors" section —
  all 30 frames are sliced by hardcoded offsets (mirroring the manifest) and
  compared against the PNGs.
- `manifest.csv` role: **human/external reference, deliberately not
  machine-read.** The offsets live in both the CSV and the test code; the CSV
  exists so external validators (e.g. d2phap) can verify the same bytes without
  reading our test harness. `raw_sha256` is the canonical ground truth (decoder-
  convention-independent); the PNGs assume MSB replication.

## Family 3 — release per-format fixtures (weakest, documented as such)

- Location: shipped in plugin GitHub releases as `ithmb-test-fixtures.zip`
  (5 files, one per decodable format); regenerated from tree on demand.
- Provenance: **self-consistent** — produced by `crates/ithmb-gen` (our own
  encoder) and verified by our own decoder. Catches regressions, not systematic
  encoder bugs. This is known and accepted: these files exercise the
  release path (plugin loads real files), not format correctness.
- Regeneration recipe (equivalent files; byte-identical only with the same
  `--seed`, which the release process does not record — sizes must match):
  `cargo run -p ithmb-gen -- --format <fmt> --output <file>.ithmb`
  with profile-matched defaults (`ithmb-gen --recommended` prints them):
  RGB565 320×240 (prefix 1024), RGB555 320×320 (3005), Reordered 256×256
  (3001), UYVY 720×480 (1019), YCbCr420 720×480 (1067). Default pixels are a
  smooth gradient; `--seed N` gives deterministic LCG noise.

## Known limits (not hidden)

- 5/8 formats covered by release fixtures; smooth gradients under-stress
  chroma paths (seeded noise only partially compensates).
- Whole-file multi-frame decode path untested (CLI rejects real F-files with
  `unknown format prefix 0`; plugin decodes frame 0 only) — future feature.
- Seeded/corpus fixtures (fuzz-seed set) parked.
- Golden `.enc`/`.bin` pairs are tiny (2×2/4×4) — they prove exactness, not
  stride/crop behavior at real sizes; Family 2 covers the latter.

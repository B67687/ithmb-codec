# Dependency policy

How this project decides what to build, what to borrow, and what to use only as a reference. It applies to the Rust codec, the website/web decoder, the ImageGlass plugin, and the archived C# port.

The short version: **own the format, borrow the commodities.** If a piece is why the project exists or encodes format-specific knowledge, it is implemented here. If it is a well-understood generic primitive, a maintained permissively licensed library is preferred over a first-party reimplementation.

## 1. Decision order

When evaluating a dependency (or whether to implement something), work through these in order:

1. **Identity.** Is this the differentiator? `.ithmb`/`.ipm` parsing, profile tables, encoders, PhotoDB/ArtworkDB handling, and the plugin's frame protocol are the product. Implement them here, even when another project has a partial implementation. A wrapper around someone else's decoder would not be this project.
2. **Commodity or host primitive.** JPEG entropy decoding, ZIP compression, CLI argument parsing, language bindings and host SDKs are generic. Use a maintained library unless it violates a later rule.
3. **Trust boundary.** Anything that parses untrusted input sits on a security boundary. Prefer memory-safe, reviewed, pinned code. Rust is used for the parsers; the web build runs inside WASM. Do not pull in a large parser for one small feature.
4. **License and provenance.** MIT, Apache-2.0 and BSD are acceptable with attribution. GPL/AGPL are not acceptable for an MIT project. A reference implementation is not a dependency: reading it to understand a format is different from linking or copying its code.
5. **Size, platform and performance.** Browser/WASM payloads, plugin DLL size, build time and cross-platform support all count. A correct but enormous dependency can be worse than a small one plus tests.
6. **Maintenance and bus factor.** For a solo-maintained project, every dependency is a future upgrade and security obligation. Prefer healthy, small-surface libraries; pin versions; avoid abandoned crates.
7. **Privacy and network behaviour.** No dependency may phone home, inject telemetry, load fonts/CDNs, or open a socket as a side effect. This is a local-first tool.
8. **Exit strategy.** Keep integration boundaries narrow (C ABI, WASM exports, data formats) so a dependency can be replaced or vendored if it is abandoned or becomes unsuitable.

## 2. Current inventory

### Rust codec (`ithmb-codec`)

| Component | Scratch | Existing runtime crates |
|---|---|---|
| Format decoders, encoders, profile table, PhotoDB/ArtworkDB, CLI logic, C ABI, SIMD | Yes | — |
| `ithmb-core` | — | `zune-jpeg` (embedded JPEG streams), `thiserror` (error types) |
| `ithmb` CLI | Command behaviour | `clap` (parsing), `anyhow`, optional `png` (PNG output) |
| `ithmb-gen` | Generators | `clap` |
| WASM bindings | Decode surface | `wasm-bindgen`, `wasm-bindgen-test` |
| Python bindings | Python API | `pyo3` |
| Tests/benches | Test logic, fixtures | `image` (dev-only), fuzz/bench tooling |

### Website / web decoder (`ithmb-codec-web`)

| Component | Scratch | Existing |
|---|---|---|
| HTML, CSS, TypeScript app, nav/footer shell, build script, i18n, all UI | Yes | — |
| Browser decoder | Yes — own Rust core compiled to WASM | `wasm-bindgen` glue |
| ZIP download | — | `fflate` (single shipped third-party runtime library, lazy-loaded) |
| Typeface | — | Inter (SIL Open Font License) |
| Build/QA | — | TypeScript, esbuild, Playwright, axe-core, Biome, bun (not shipped) |

### ImageGlass plugin (`imageglass-ithmb-plugin`)

| Component | Scratch | Existing |
|---|---|---|
| ImageGlass plugin protocol, frame delivery, FFI surface | Yes | — |
| Decoding | Reuses `ithmb-core` | `libc` |

### Archived C# port (`Ithmb-Codec-CSharp`)

| Component | Scratch | Existing |
|---|---|---|
| Decoders and format logic | Yes | — |
| JPEG decoding | — | `StbImageSharp` |
| ImageGlass integration | — | `ImageGlass.SDK` |

## 3. Reference implementations are not dependencies

Other decoders are used as **specifications and test oracles**, not linked code:

- iOpenPod (profile validation), libgpod (PhotoDB/ArtworkDB structure), Keith's iPod Photo Reader (multi-frame), clickwheel and OrgZ (ArtworkDB), pyithmb (Python YUV reference), and the other projects credited in [`ACKNOWLEDGMENTS.md`](ACKNOWLEDGMENTS.md) (33 projects in total).
- Their observations are turned into first-party profile data, parsers and tests. Fixtures and synthetic CC0 vectors are used for differential/golden tests; reference PNGs are compared for regressions.
- Code is not copied from reference implementations. The only attribution obligation is the credit list; if a future change does reuse licensed code, the licence and attribution must be recorded before merge.

### Choosing reference vs dependency

- Another implementation exists, but the format has quirks, undocumented variants, or profiles that library does not model → **implement, use the other as an oracle**.
- Another implementation exists, is maintained, licence-compatible, small, and the task is generic (JPEG, ZIP, CLI parsing, bindings) → **use it**.
- Another implementation exists but is GPL/AGPL, abandoned, oversized, or handles the untrusted file itself → **do not depend on it**; use its documented behaviour only as a reference.
- No reliable implementation exists → **implement it**; that is the normal case for `.ithmb`.

## 4. Review process for a new dependency

1. Open an issue describing the need and the alternatives (implement vs existing crate).
2. Check licence, maintenance activity, advisory history, dependency tree size, MSRV, WASM/no-std/platform support, and whether it performs network I/O.
3. Run the repo's audit/lint gates (`cargo fmt`, `cargo clippy`, `cargo audit`/`cargo deny` where configured, browser/type checks on the web side) after adding it.
4. Pin the version in `Cargo.toml`/`package.json`; never depend on a floating branch or CDN asset.
5. Update [`ACKNOWLEDGMENTS.md`](ACKNOWLEDGMENTS.md) (codec) or the website credits when adding runtime code; record the decision in the PR/commit message.
6. If the dependency is only used for tooling, keep it in dev-dependencies / devDependencies so it never ships.

## 5. Known deliberate exceptions

- `zune-jpeg` is a dependency even though JPEG is an image format: writing a correct, fast, memory-safe JPEG decoder is a separate project, and embedded JPEG streams are a small part of the `.ithmb` surface.
- `fflate` is a devDependency in `package.json` but is bundled into the shipped site because ZIP export needs it. It is lazy-loaded so the decoder initial payload stays small.
- The C# port uses `StbImageSharp` and `ImageGlass.SDK`; it is archived and not the reference implementation for new work.
- No UI framework is used on the website. If the site grew into a genuinely stateful app, that decision should be revisited explicitly rather than accreted.

## 6. Review cadence

- Check advisories and stale dependencies before each release.
- Remove unused dependencies as part of cleanup (see the code-health and docs passes).
- Re-evaluate a dependency if it becomes unmaintained, changes licence, grows substantially, or starts doing network I/O.
- Update this document when a dependency is added, removed, or a first-party implementation replaces one.

# Code Quality Bar — Living Standard

**What this is:** The single table of what we enforce today (lint → level → CI layer → rationale → ADR).  
**What this is not:** History — for _why_ at decision time, see `docs/adr/2026-09-14-code-quality-bar.md` (ADR-0011).  
**Rule:** Change the bar here first, ADR when the _why_ changes. `Cargo.toml` and `AGENTS.md` point here; they don't duplicate it.

**Scope:** ithmb-codec (Rust workspace), imageglass-ithmb-plugin (same Rust bar, `unsafe_code = allow` for C ABI), ithmb-codec-web (TS/Biome), pymod (Python). Authoritative bar = rust-lang + rustsec/Embark + nextest/typos/lychee + ruff/pyright + biome. Boutique (`shear`, `bunch`, `mutants`) = Tier-3 report, not gate (see ADR-0011).

## Rust — `rust` lints

| Lint                                                                | Level    | CI layer           | Rationale                                                                                 |
| ------------------------------------------------------------------- | -------- | ------------------ | ----------------------------------------------------------------------------------------- |
| `unsafe_code`                                                       | deny     | pr-checks (clippy) | Library must not smuggle unsafe; Plugin `allow` with reason is the exception.             |
| `unsafe_op_in_unsafe_fn`                                            | deny     | pr-checks          | Every op inside `unsafe fn` explicit.                                                     |
| `unused_imports`                                                    | **deny** | pr-checks          | ADR-0011 promotion — pure signal, omission after ADR-0009 fixed.                          |
| `unused_variables`                                                  | **deny** | pr-checks          | As above.                                                                                 |
| `unused_mut`                                                        | **deny** | pr-checks          | As above.                                                                                 |
| `unused_crate_dependencies`                                         | **deny** | pr-checks          | Free — machete proves it, rust lint catches earlier.                                      |
| `unused_must_use`                                                   | deny     | pr-checks          | Must-use returns must be handled.                                                         |
| `dead_code`                                                         | warn     | pr-checks          | `#[cfg]` scaffolding (SIMD dispatch, feature gates) — `deny` would be noisy; keep `warn`. |
| `missing_docs`, `missing_debug_implementations`, `unreachable_pub`  | warn     | pr-checks          | Library with 53 profiles; incomplete docs, not correctness.                               |
| `rust_2018_idioms`, `non_ascii_idents`                              | deny     | pr-checks          | Edition hygiene.                                                                          |
| `trivial_numeric_casts`, `unused_lifetimes`, `single_use_lifetimes` | warn     | pr-checks          | Candidate for future `deny`; keep `warn` until `unused_*` sweep lands.                    |

## Rust — Clippy

`clippy::all = deny` (priority -1). `pedantic/nursery/cargo = warn` (cherry-pick, never wholesale — ADR-0011).

| Lint                                                                                                                                                                                    | Level               | CI layer  | Rationale                                                                                      |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | --------- | ---------------------------------------------------------------------------------------------- |
| `ptr_as_ptr`, `borrow_as_ptr`                                                                                                                                                           | **deny**            | pr-checks | Unsafe-adjacent pointer casts — audit surface.                                                 |
| `as_ptr_cast_mut`, `as_underscore`, `fn_to_numeric_cast_any`, `mem_forget`                                                                                                              | deny                | pr-checks | Hard denies (pointer + lifecycle).                                                             |
| `todo`, `unimplemented`                                                                                                                                                                 | deny                | pr-checks | No shipped todos.                                                                              |
| `needless_pass_by_value`, `needless_pass_by_ref_mut`                                                                                                                                    | warn                | pr-checks | `Copy` false positives + intentional moves; `warn` catches real `String`→`&str` without noise. |
| `cast_possible_truncation/wrap/precision_loss/sign_loss`                                                                                                                                | warn                | pr-checks | Many `as u32` intentional; fix with `try_from` where it fires.                                 |
| `undocumented_unsafe_blocks`, `multiple_unsafe_ops_per_block`, `unwrap_used`, `expect_used`, `panic`, `indexing_slicing`, `arithmetic_side_effects`, `dbg_macro`, `print_stdout/stderr` | warn                | pr-checks | Cherry `warn` — SAFETY review owns the unsafe math; promotion would churn SIMD without win.    |
| `module_name_repetitions`, `must_use_candidate`, `missing_errors_doc`                                                                                                                   | allow               | —         | Project-wide relaxations (see Cargo.toml).                                                     |
| `mod_module_files`                                                                                                                                                                      | allow (with reason) | —         | Legacy `mod.rs` layout — rename would churn public mod tree (14 modules).                      |

## CI Gates

| Gate                                    | Command                                                                | Layer                            | Level               | Notes                                                                                             |
| --------------------------------------- | ---------------------------------------------------------------------- | -------------------------------- | ------------------- | ------------------------------------------------------------------------------------------------- |
| `fmt`                                   | `cargo fmt --check`                                                    | pr-checks                        | deny                | `rustfmt.toml` `style_edition=2024`, 120 width.                                                   |
| `clippy`                                | `cargo clippy --workspace --all-targets --all-features -- -D warnings` | pr-checks                        | deny/warn per table | `--all-features` added by ADR-0011 (Plugin already had it). Local must mirror this exact command. |
| `semver-checks`                         | `cargo semver-checks`                                                  | pr-checks                        | **warn**            | Added by ADR-0011 — watches crates.io `ithmb-core` public API breakage.                           |
| `deny`                                  | `cargo deny check` (licenses/bans/sources, `deny.toml`)                | pr-checks                        | deny                | Authoritative supply chain.                                                                       |
| `audit`                                 | `cargo audit` (RUSTSEC)                                                | pr-checks                        | deny                | Advisory check.                                                                                   |
| `doc`                                   | `cargo doc --no-deps --document-private-items -W warnings`             | pr-checks                        | deny                | Docs build + warnings.                                                                            |
| `machete`                               | `cargo machete 0.9.2`                                                  | pr-checks                        | deny                | Unused deps — authoritative; `shear`/`bunch` parked.                                              |
| `typos`                                 | `typos 1.42.3`                                                         | pr-checks                        | deny                | Spell check.                                                                                      |
| `lychee`                                | `lychee`                                                               | pr-checks                        | deny                | Link check.                                                                                       |
| `gitleaks`                              | `gitleaks`                                                             | pr-checks                        | deny                | Secret scan (full history on push).                                                               |
| `check-ci-pins`                         | pinned action SHAs                                                     | pr-checks                        | deny                | Supply chain pins.                                                                                |
| `nextest`                               | `cargo nextest run --workspace`                                        | ci-full (push main) + local-ci   | deny                | 3-OS matrix on ci-full; fast local run mirrors.                                                   |
| `benchmark_regression` + `fuzz` (6×30s) | `tools/check-benchmark-regression.sh` + `cargo fuzz`                   | ci-full (gated on `changes` job) | deny                | Paths-ignore docs/** — not on every push.                                                         |
| `build_c_api`, `wasm`                   | cross-build + wasm-pack                                                | ci-full                          | deny                | Deterministic backbone — always runs.                                                             |

## Parked Tools (Tier-3 — local report, not PR-gate)

| Tool                         | Status          | Why not gate                                                                                       |
| ---------------------------- | --------------- | -------------------------------------------------------------------------------------------------- |
| `cargo-shear`, `cargo-bunch` | parked          | Duplicate signal — `machete` authoritative enough.                                                 |
| `cargo-mutants`              | parked (Tier-3) | Maintained (Martin Nowak) but 10-30min per run; local `cargo mutants --in-place` report, not gate. |
| `cargo vet`                  | parked          | `deny` + `audit` already authoritative; `vet` is niche alternative.                                |

## Python — pymod (local-only, PYM-01)

| Check          | Command                                            | Level | Notes                                                            |
| -------------- | -------------------------------------------------- | ----- | ---------------------------------------------------------------- |
| `ruff`         | `uv run ruff check pymod/ --select E,F,UP,B,SIM,I` | local | Local-only per ADR-0011; `N`/`D`/`C4` expansion is a future ADR. |
| `basedpyright` | `uv run basedpyright --level recommended`          | local | Local-only.                                                      |
| `pytest`       | `uv run pytest pymod/tests -q` (11 tests)          | local | Not wired to `pr-checks` — see PYM-01.                           |

## Web — TypeScript / Biome

| Check                | Command                                                                             | Level                                                                  |
| -------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `tsc`                | `tsc --noEmit` (strict + `exactOptionalPropertyTypes` + `noUncheckedIndexedAccess`) | deny (lint job)                                                        |
| `biome format`       | `biome format .`                                                                    | deny                                                                   |
| `biome check` (lint) | `biome check .`                                                                     | **warn → deny** (format-only → warn gate → deny after sweep; ADR-0011) |
| `playwright`         | `npx playwright test`                                                               | deny (3-browser matrix, `guard` whole-line `[skip browsers]`)          |

## Docs Home

- **This file** — what we enforce today.
- **ADR-0011** (`docs/adr/2026-09-14-code-quality-bar.md`) — why at decision time.
- `Cargo.toml [workspace.lints]` + `AGENTS.md strictness table` point here; they don't duplicate it.
- Docs scatter closed: strictness no longer lives in comments alone; `TECH_DEBT_AUDIT` PYM-01 links here.

## Change Process

1. Edit this file (the bar you want).
2. If the _why_ changes, write/amend the ADR.
3. Implement: `Cargo.toml` lints → `pr-checks.yml` flags → `cargo clippy --fix` sweep (verify via `cargo clippy` green, file reads, `git diff --stat` — never phantom stdout).

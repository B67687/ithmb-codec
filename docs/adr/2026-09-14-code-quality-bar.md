# ADR-0011: Code Quality Bar — Authoritative Lints, CI Gates, and Parked Tools

**Status:** Accepted (2026-09-14) — ratified with user 2026-09-09 lightweight dev-protocol
**Supersedes:** Implicit strictness in `Cargo.toml` comment + `AGENTS.md` table (no prior ADR)
**Living doc:** `docs/standards/CODE_QUALITY.md` (what we enforce today)

## Context

After ADR-0009 removed the action-injected `RUSTFLAGS=-D warnings`, the full `unused_*` family stayed `warn` — not by decision but by omission. No ADR recorded why `pedantic/nursery/cargo = warn` is correct, why `shear`/`bunch`/`mutants` were parked, or where `pymod` and `biome check` stand. The strictness table lived in `Cargo.toml` comments, `AGENTS.md`, and `TECH_DEBT_AUDIT` scatter. This ADR records the authoritative bar: every gate the Rust project itself watches, at its sharpest useful level, with zero docs scatter.

Authoritative = `cargo clippy`/`rustfmt`/`cargo` (rust-lang), `cargo-deny`/`cargo-audit` (rustsec/Embark), `typos`/`lychee`/`nextest`, `ruff`/`basedpyright` (Python), `biome` (Web). Boutique (`cargo-shear`, `cargo-bunch`, `cargo-mutants`) stays parked — `machete` already covers unused deps, mutants is 10-30min and maintained (Martin Nowak) but Tier-3 report, not PR-gate per user 2026-09-09.

## Decision

### 1. Rust `rust` lints — promote the cheap `unused_*` family; keep `dead_code` at warn

| Lint                                                                | Level                                        | Rationale                                                                                                        |
| ------------------------------------------------------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `unused_imports`, `unused_variables`, `unused_mut`                  | **deny**                                     | Pure signal. Omission after ADR-0009, now fixed.                                                                 |
| `unused_crate_dependencies`                                         | **deny**                                     | Free — `machete` proves it, rust lint catches it earlier.                                                        |
| `dead_code`                                                         | **warn** (keep)                              | `#[cfg]` scaffolding (SIMD dispatch, feature-gated modules) makes `deny` noisy; `warn` is the production choice. |
| `missing_docs`, `missing_debug_implementations`, `unreachable_pub`  | **warn** (keep)                              | Library with 53 profiles; incomplete docs, not correctness.                                                      |
| `trivial_numeric_casts`, `unused_lifetimes`, `single_use_lifetimes` | **warn→deny** candidate, keep `warn` for now | Small signal; revisit after the `unused_*` sweep lands green.                                                    |

### 2. Clippy — cherry-pick, never wholesale `pedantic = deny`

`pedantic/nursery/cargo = warn` stays (1754 warns would have become errors overnight — Cargo.toml comment + AGENTS.md were correct to avoid wholesale). We triage cherry-picks:

| Lint                                                                                                                                                | Level           | Rationale                                                                                                                 |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `ptr_as_ptr`, `borrow_as_ptr`                                                                                                                       | **deny**        | Unsafe-adjacent codec + C ABI boundary — pointer casts are audit surface (your call-by-pointer concern).                  |
| `needless_pass_by_value`, `needless_pass_by_ref_mut`                                                                                                | **warn** (keep) | `Copy` false positives + intentional moves in pipeline code; `warn` catches the real `String`→`&str` cases without noise. |
| `cast_possible_truncation / wrap / precision_loss / sign_loss`                                                                                      | **warn** (keep) | Many `as u32` casts are intentional; fix with `try_from` where it fires, don't `deny` the family.                         |
| `undocumented_unsafe_blocks`, `multiple_unsafe_ops_per_block`, `unwrap_used`, `expect_used`, `panic`, `indexing_slicing`, `arithmetic_side_effects` | **warn** (keep) | Already cherry `warn`; promotion would churn SIMD math without safety win (SAFETY review owns it).                        |
| `redundant_pub_crate`, `missing_const_for_fn` (nursery)                                                                                             | **warn** (keep) | Low-noise but not worth `deny` until the `unused_*` sweep is proven.                                                      |

Wholesale `pedantic = deny` remains rejected — not production for a codec with SIMD math.

### 3. CI gates — add the missing authoritative flags, park the niche

| Gate                                                                                                | Decision                                                                                                                     |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `clippy --all-features`                                                                             | **add** to Codec `pr-checks` (Plugin already has it; feature-gated dead imports unseen without it).                          |
| `cargo semver-checks`                                                                               | **warn** gate in `pr-checks` (crates.io `ithmb-core` — watches public API breakage, authoritative).                          |
| `fmt --check`, `deny`, `audit`, `doc -W`, `gitleaks`, `typos`, `lychee`, `machete`, `check-ci-pins` | **keep deny** (already).                                                                                                     |
| `cargo vet`                                                                                         | **park** — `deny` (licenses/bans) + `audit` already authoritative; `vet` is niche alternative.                               |
| `cargo-shear` / `cargo-bunch`                                                                       | **park** — `machete` authoritative enough, duplicate signal.                                                                 |
| `cargo-mutants`                                                                                     | **park as Tier-3 local report** — maintained, heavy 10-30min, not PR-gate (correctly identified as authoritative but heavy). |
| `pymod` (`ruff E,F,UP,B,SIM,I` + `basedpyright recommended` + `pytest`)                             | **keep local-only** (PYM-01) — no `pr-checks` wiring until `ruff` rule expand (`N`, `D`, `C4`) is ratified separately.       |
| Web `biome`                                                                                         | `biome format` stays deny; `biome check` (lint) added as **warn-then-deny** (format-only → warn gate → deny after sweep).    |

### 4. Docs home

`docs/standards/CODE_QUALITY.md` becomes the single living table (lint → level → CI layer → rationale → ADR link). `Cargo.toml` and `AGENTS.md` point at it; this ADR records _why_ at time of decision.

## Consequences

- `Cargo.toml` `[workspace.lints]` promotes 4 `unused_*` + 2 pointer lints (see §1-2); `pr-checks.yml` adds `--all-features` + `semver-checks` warn.
- `cargo clippy --fix` sweep + hand-fix remainder (expect <30 hits); verified via `cargo clippy` green, not phantom stdout.
- `semver-checks`, `biome check`, and parked tools are no longer "omitted" — they are explicitly decided (wire or park with reason).
- Future lint tightening goes through `CODE_QUALITY.md` first, ADR when the _why_ changes — not scattered comments.

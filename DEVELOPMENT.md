# Development History

The plugin was developed through an iterative research-and-review pipeline, completed in June 2026. Prior work includes the [original IthmbDecoder](https://github.com/d2phap/ImageGlass/pull/2316) (ImageGlass PR #2316, iPhone 5 validation) and the [feature request](https://github.com/d2phap/ImageGlass/issues/2256) that prompted this project.

<div align="center"><img src="docs/pipeline.svg" alt="Development pipeline diagram" width="100%"></div>

1. **Format survey** — 25 open-source .ithmb implementations found across GitHub, GitLab, Codeberg, SourceHut, Bitbucket, and Gitee. Complete source analysis of each.

2. **Format table extraction** — iOpenPod (50+ entries), libgpod, iLounge threads, and Keith's iPod Photo Reader provided dimension/encoding tables for 48 profiles (22 photo + 26 cover art).

3. **Implementation** — C# Native AOT plugin with 5 decoders (RGB565, RGB555, UYVY, YCbCr420, CLCL) and SIMD acceleration (SSE2, SSSE3, Vector128 for x64 + ARM64 NEON). Standalone CLI decoder at `tools/IthmbDecoder/`.

4. **Testing** — 329 unit tests covering roundtrip (65,536 RGB565 + 32,768 RGB555 values), fuzz (250 random inputs across 5 engines), SIMD identity (10 tests), YUV tolerance, EXIF parsing, JSON profile loading, and speculative decoder paths (CL, CLCL, rotation, swapped chroma).

5. **Review cycles** — 4 rounds of multi-agent review. ~42 findings fixed covering memory safety, threading, ABI compatibility, SIMD correctness, and defense-in-depth hardening.

6. **Release** — Windows Native AOT binary published to GitHub Releases as `v1`.

7. **Documentation** — All 25 surveyed references credited with specific contributions (see [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md)). Full profile reference in [PROFILES.md](PROFILES.md).

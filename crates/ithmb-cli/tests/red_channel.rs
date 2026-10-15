//! Pure-red channel-order regression for CLI PNG output.
//!
//! A pure-red BGRA image (`[0, 0, 255, 255]`) through the real `ithmb`
//! binary's PNG path must decode back as RGBA red (`R=255, B=0`). With the
//! old `write_png` bug (BGRA bytes written as-is under an `Rgba` header),
//! pixel0 read back as `R=0, B=255` and the explicit index asserts below
//! fail. Any future R/B swap anywhere on this path fails the same way.
#![allow(
    clippy::pedantic,
    clippy::unwrap_used,
    unused_crate_dependencies,
    reason = "strict migration"
)]

use std::path::PathBuf;
use std::process::Command;

/// Path to the compiled `ithmb` binary.
fn ithmb_bin() -> PathBuf {
    PathBuf::from(env!("CARGO_BIN_EXE_ithmb"))
}

/// Temporary output directory, unique per test case.
fn tmp_dir(name: &str) -> PathBuf {
    let dir = std::env::temp_dir().join("ithmb-cli-test").join(name);
    std::fs::create_dir_all(&dir).unwrap();
    dir
}

#[test]
fn write_png_pure_red_roundtrip_preserves_red_channel() {
    // Profile 1009: 42x30 RGB565, little-endian by default — small and fast.
    let db = ithmb_core::ProfileDb::load_builtin().unwrap();
    let profile = db.get(1009).unwrap().clone();
    assert_eq!((profile.width, profile.height), (42, 30));

    // Pure red in ground-truth BGRA8 order: B=0, G=0, R=255, A=255.
    let red_bgra: Vec<u8> = vec![[0u8, 0, 255, 255]; 42 * 30].concat();
    let frame = ithmb_core::enc::encode_bgra(&red_bgra, 42, 30, &profile);
    let mut ithmb = 1009_u32.to_be_bytes().to_vec();
    ithmb.extend_from_slice(&frame);

    let dir = tmp_dir("red_channel_png");
    let input = dir.join("red.ithmb");
    let output = dir.join("red.png");
    std::fs::write(&input, &ithmb).unwrap();

    let out = Command::new(ithmb_bin())
        .arg(&input)
        .arg(&output)
        .output()
        .expect("failed to execute ithmb binary");
    assert!(
        out.status.success(),
        "expected success, got exit={:?}\nstdout: {}\nstderr: {}",
        out.status.code(),
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr),
    );
    assert!(output.exists(), "output PNG not created");

    // Read the PNG back and pin the RGBA channel layout with explicit indices.
    let file = std::fs::File::open(&output).unwrap();
    let decoder = png::Decoder::new(std::io::BufReader::new(file));
    let mut reader = decoder.read_info().unwrap();
    let mut buf = vec![0; reader.output_buffer_size().expect("PNG must report buffer size")];
    let info = reader.next_frame(&mut buf).unwrap();
    assert_eq!(info.color_type, png::ColorType::Rgba, "PNG must be RGBA8");
    assert_eq!((info.width, info.height), (42, 30));
    assert!(buf.len() >= 4, "PNG pixel buffer too small");
    assert_eq!(buf[0], 255, "R channel of pixel0 must be 255 (pure red)");
    assert_eq!(buf[1], 0, "G channel of pixel0 must be 0 (pure red)");
    assert_eq!(buf[2], 0, "B channel of pixel0 must be 0 (pure red)");
    assert_eq!(buf[3], 255, "A channel of pixel0 must be 255 (opaque)");
}

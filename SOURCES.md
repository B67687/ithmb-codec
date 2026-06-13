# Known Public .ithmb File Sources

These are URLs where .ithmb thumbnail cache files have been found publicly accessible.
All files are T-prefix format (JPEG-embedded). No F-prefix (raw format) files have been
found on any public source.

## Directories with verified .ithmb files

### Jakarade.com (F00–F08, 227 files)

```
https://www.jakarade.com/inc/Picture/yugioh/iPod%20Photo%20Cache/F00/
https://www.jakarade.com/inc/Picture/yugioh/iPod%20Photo%20Cache/F01/
...
https://www.jakarade.com/inc/Picture/yugioh/iPod%20Photo%20Cache/F08/
```

- Status: ✅ Live (last verified June 2026)
- Files per directory: 6–28 files
- File pattern: `T###.ithmb` (e.g. `T149.ithmb`)
- Size: ~210–346 KB per file
- All verified: T-prefix with embedded JPEG + EXIF

### Florida Atlantic University (F00–F50, ~500+ files)

```
https://home.fau.edu/schilitj/web/iPod%20Photo%20Cache/F00/
https://home.fau.edu/schilitj/web/iPod%20Photo%20Cache/F01/
...
https://home.fau.edu/schilitj/web/iPod%20Photo%20Cache/F50/
```

- Status: ⚠️ Partial — directory listings are live but all .ithmb file downloads return HTTP 404 (access denied, verified June 2026)
- Host: FAU user directory (`~schilitj/`)
- Files per directory: ~8–11 files
- File pattern: `T###.ithmb`
- Size: ~672 KB per file

### Hungrypoint.com (Photo Database only)

```
https://hungrypoint.com/Niki/iPod%20Photo%20Cache/Photo%20Database
```

- Status: ✅ Live
- File: `Photo Database` (binary index, 30 KB)
- No .ithmb files at this source (only database index)

## Dead / unavailable sources

- `dragonnorth.com/pictures/PollysPhotos/Calli/iPod%20Photo%20Cache/` — empty directories
- `vhromanov.com/Males/Cody/iPod_Photo_Cache/` — domain gone
- `home.fau.edu/schilitj/` (user root) — redirected; the full subpath (`/web/iPod%20Photo%20Cache/F*/`) still serves directory listings but .ithmb file downloads return 404

## File Juicer sample file (T117.ithmb)

The macOS tool [File Juicer](https://echoone.com/filejuicer/formats/ithmb) provides a sample
`.ithmb` file at `https://echoone.com/filejuicer/sample-files/T117.ithmb.zip`.

This file begins with 67,696 bytes of the repeating pattern `80 10` followed by
726,344 bytes of data that doesn't correspond to any known iPod/iPhone .ithmb format.
It contains no embedded JPEG, no known profile prefix, and no image markers.
**This is not a standard iPod/iPhone thumbnail cache file** — likely a File Juicer
internal test file or a format variant specific to a different Apple OS version.

Our codec correctly rejects it (`DecodeFailed`).

## Privacy note

These files are hosted on personal web servers and university user directories.
They contain possibly personal photographs. **Do not redistribute the .ithmb files
themselves.** The synthetic encoder (`IthmbEncoder.cs`)
generates test files without any privacy concerns.

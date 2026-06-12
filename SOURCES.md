# Known Public .ithmb File Sources

These are URLs where .ithmb thumbnail cache files have been found publicly accessible.
All files are T-prefix format (JPEG-embedded). No F-prefix (raw format) files have been
found on any public source.

## Directories with verified .ithmb files

### Jakarade.com (F00–F08, ~228 files)

```
https://www.jakarade.com/inc/Picture/yugioh/iPod%20Photo%20Cache/F00/
https://www.jakarade.com/inc/Picture/yugioh/iPod%20Photo%20Cache/F01/
...
https://www.jakarade.com/inc/Picture/yugioh/iPod%20Photo%20Cache/F08/
```

- Status: ✅ Live (last verified June 2026)
- Files per directory: 8–28 files
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

- Status: ✅ Live (last verified June 2026)
- Host: FAU user directory (`~schilitj/`)
- Files per directory: ~9–10 files
- File pattern: `T###.ithmb`
- Size: ~672 KB per file
- Also contains: `Photo Database` (685 KB, binary index)

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
- `home.fau.edu/schilitj/` — redirected (Wayback only)

## Privacy note

These files are hosted on personal web servers and university user directories.
They contain possibly personal photographs. **Do not redistribute the .ithmb files
themselves.** Use the scripts in `scripts/` to download directly from the original
sources if you need them for testing. The synthetic encoder (`IthmbEncoder.cs`)
generates test files without any privacy concerns.

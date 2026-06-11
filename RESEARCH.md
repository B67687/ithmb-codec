# ithmb Research — Reference URLs

All open-source .ithmb implementations and format documentation sources surveyed
during the development of this plugin. Grouped by relevance.

## Core Implementations (source code directly informed our codec)

| Project                           | URL                                                                      | Type                                                   |
| --------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------ |
| iOpenPod                          | https://github.com/TheRealSavi/iOpenPod                                  | Python — most complete format table (50+ entries)      |
| ithmbrdr                          | https://github.com/cyianor/ithmbrdr                                      | Go — F1067 YCbCr 4:2:0, correct BT.601                 |
| Keith's iPod Photo Reader         | https://github.com/kebwi/Keiths_iPod_Photo_Reader                        | C++ — original 2005 RE, 13 decode methods              |
| libgpod/gtkpod                    | https://github.com/gtkpod/libgpod                                        | C — 22 format variants, complete format ID table       |
| andrewmalta/ithmb                 | https://github.com/andrewmalta/ithmb                                     | Python — F1019 CLCL packed-chroma decoder              |
| Gaurav-Phogat/F1007               | https://github.com/Gaurav-Phogat/ithmb-extractor-F1007                   | Python — F1007 RGB565 at 480×864                       |
| pygpod                            | https://github.com/Bionded/pygpod                                        | Python — libgpod port with cover art tables            |
| repear                            | https://github.com/worstje/repear                                        | Python — ArtworkDB writer, model-based format IDs      |
| podsyncr                          | https://github.com/tbutter/podsyncr                                      | Java — iPod Nano 2G syncer, F1023/F1032                |
| shinyquagsire23 gist              | https://gist.github.com/shinyquagsire23/5ac38487b4c8f9252e78e0275814c90b | C — Nano 6G Photo DB, F1093 = 512×512                  |
| Steee29/ithmb_converter           | https://github.com/Steee29/ithmb_converter                               | Python — iOS 1.x format table, Photo DB parser         |
| wrinklykong/pyithmb               | https://github.com/wrinklykong/pyithmb                                   | Python — CLCL nibble-chroma decoder                    |
| thomas-alrek/iPod-photo-database  | https://github.com/thomas-alrek/iPod-photo-database                      | JavaScript — Photo DB + ithmb→JPEG                     |
| epireyn/ithmb-rs                  | https://gitlab.com/epireyn/ithmb-rs                                      | Rust — implementation (source not directly accessible) |
| MasterCard007/ithmb2jpg-converter | https://github.com/MasterCard007/ithmb2jpg-converter                     | Python — converter                                     |
| atimevil/Ithmb-Converter          | https://github.com/atimevil/Ithmb-Converter                              | Python — converter                                     |
| yosoyemi/ithmb-converter-a-jpg    | https://github.com/yosoyemi/ithmb-converter-a-jpg                        | Python — converter (MIT)                               |

## Lost / Unrecoverable

| Project          | URL                                                                                                        | Notes                           |
| ---------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| iThmbConv        | https://web.archive.org/web/20140625032820/http://www.mediafire.com/download/gvtxgwj2k0m2o1d/iThmbConv.zip | C — lost source, behind Captcha |
| iThmbConv thread | https://forums.whirlpool.net.au/archive/661720                                                             | Original 2007 release post      |

## Format Documentation

| Source                 | URL                                                                                                             | Content                                 |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| iLounge Gory Details   | https://web.archive.org/web/20090120040252/http://forums.ilounge.com/showthread.php?t=66435                     | Per-device format ID table              |
| iLounge hacking thread | https://web.archive.org/web/20191225184817/https://forums.ilounge.com/threads/hacking-ithmb-file-format.110066/ | Original YUV 4:2:2 RE                   |
| keyj.emphy.de blog     | https://web.archive.org/web/2024*/https://keyj.emphy.de/an-ipod-hackers-diary/                                  | ArtworkDB reverse engineering           |
| iPodLinux Wiki         | http://www.ipodlinux.org/ITunesDB/                                                                              | iTunesDB/ArtworkDB binary spec          |
| Just Solve wiki        | http://fileformats.archiveteam.org/wiki/IThmb                                                                   | Profile prefix/resolution summary       |
| ithmb.org decoder      | https://ithmb.org/                                                                                              | Web-based decoder with decode mode list |

## Commercial / Closed-Source (reference only)

| Tool            | URL                                          |
| --------------- | -------------------------------------------- |
| iThmb Converter | https://www.ithmbconverter.com/              |
| File Juicer     | https://echoone.com/filejuicer/formats/ithmb |

## Public Sample File Sources

| Host                 | URL                                                                               | Files                    |
| -------------------- | --------------------------------------------------------------------------------- | ------------------------ |
| Jakarade F00–F08     | https://www.jakarade.com/inc/Picture/yugioh/iPod%20Photo%20Cache/F00/             | 228 T-prefix .ithmb      |
| Hungrypoint Photo DB | https://hungrypoint.com/Niki/iPod%20Photo%20Cache/Photo%20Database                | Photo Database (30 KB)   |
| Dragonnorth (dead)   | https://www.dragonnorth.com/pictures/PollysPhotos/Calli/iPod%20Photo%20Cache/F00/ | Empty directories        |
| home.fau.edu (dead)  | https://home.fau.edu/schilitj/web/iPod%20Photo%20Cache/F00/                       | Server dead, Wayback 302 |

## Key Forum Threads

| Forum        | URL                                                                                                     | Content                                   |
| ------------ | ------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| MyBroadband  | https://mybroadband.co.za/forum/threads/iphone-ipad-recover-deleted-images-through-ithmb-files.1298535/ | 3 .ithmb + reference JPEGs (login-walled) |
| XnView forum | https://newsgroup.xnview.com/viewtopic.php?t=32698                                                      | ithmb sample discussion                   |

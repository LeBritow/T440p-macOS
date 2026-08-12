# How we diagnosed each issue — index

Detailed, hardware-verified write-ups for every accepted problem and solved fix
on this ThinkPad **T440p** (macOS **Sequoia 15.7.9**, OpenCore **1.0.7**).

> **Full guide, specs and known-issues table live in the root
> [README](../README.md)** — this page is only the index of the per-issue
> folders below.

**Status: ✅ Sequoia 15.7.9 is stable and in daily use.** Path A (`-rtsxnopm` SD
reader experiment) is still being tested — the stable `Config.plist` keeps the
reader off.

| Folder | Issue / topic | Status |
|--------|---------------|--------|
| [`01-specifications/`](01-specifications/specs.md) | Full hardware/software specs, USB architecture, EFI layout | ✅ |
| [`02-dead-usb-port/`](02-dead-usb-port/) | Dead left-side USB port (EHCI, driver removed in macOS 14/15) | 🚫 No solution |
| [`03-sd-card-reader/`](03-sd-card-reader/) | SD reader (RTS5227) panics; Path A `-rtsxnopm` experiment | 🔇 Disabled · 🧪 testing |
| [`04-direct-boot/`](04-direct-boot/) | Direct boot (no picker) + FAT `dirty` EFI repair | ✅ |
| [`05-open-core-config/`](05-open-core-config/) | Production `config.plist` + kext/quirk reference | ✅ |
| [`06-post-install/`](06-post-install/) | TRIM, monitoring, EFI maintenance, Sequoia upgrade log | ✅ |
| [`07-credits.md`](07-credits.md) | Credits for every kext/driver/tool | ✅ |
| [`08-bluetooth/`](08-bluetooth/) | Bluetooth dead by hardware (Intel `0x07DA`, no BIOS toggle) | 🔇 Accepted |
| [`09-nvram-reset-recovery/`](09-nvram-reset-recovery/) | NVRAM reset wiped the picker → rescue via EFI Shell `boot.efi` | ✅ Solved |
| [`10-session-log-2026-08-11.md`](10-session-log-2026-08-11.md) | Full session backup (SD Path A, caddy fix, decisions) | ✅ |

EFI snapshots: [`efi-sonoma-14.8.8/`](efi-sonoma-14.8.8/) (historical, OC 1.0.4) and
[`efi-sequoia-15.7.9/`](efi-sequoia-15.7.9/) (current working EFI, OC 1.0.7,
placeholder SMBIOS — in sync with the root `EFI/`).

Contributing: see [`CONTRIBUTING.md`](../CONTRIBUTING.md).
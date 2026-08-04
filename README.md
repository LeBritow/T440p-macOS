# T440p Hackintosh — macOS 14.8.8 (Sonoma) via OpenCore

A **Lenovo ThinkPad T440p** running **macOS 14.8.8 (Sonoma, build 23J620)** with
**OpenCore 1.0.4**. This repository documents the real, hardware-verified issues
encountered during setup and the solutions applied — intended for anyone working
with the same laptop (or any Haswell / Intel 8-series chipset).

> **SMBIOS notice:** All SMBIOS data in this repository are **placeholders**
> (`AAAAAAAA...`). Generate your own values with GenSMBIOS before use — a public
> serial number can cause iMessage/FaceTime blacklisting.

## Machine status

| Component | Status |
|-----------|--------|
| Boot | Straight to the Apple logo (picker disabled; hold **Esc** at power-on for the menu) |
| Wi-Fi / Bluetooth / Ethernet / Audio | ✅ Working |
| Left-side USB port (below the SD reader) | 🔌 **Dead** — EHCI controller, driver removed in macOS 14 (no solution) |
| SD card reader (RTS5227) | 🔇 **Disabled** — both drivers caused boot/wake/shutdown panics |
| ABNT2 keyboard (`?`→`/`) | ✅ Fixed with a userspace remapper (see `keyboard-remap/`) |

## Specifications

| Item | Value |
|------|-------|
| Model | Lenovo ThinkPad T440p |
| CPU | Intel Core **i7-4700MQ** @ 2.40 GHz (4C/8T, Haswell) |
| iGPU | Intel **HD Graphics 4600** (1536 MB, Metal 2) |
| RAM | 16 GB |
| Storage | 240 GB SATA SSD (APFS, GUID) |
| Wi-Fi | Intel (802.11 a/b/g/n) — driven by AirportItlwm |
| Bluetooth | Broadcom **BCM_4350C2** — driven by BrcmPatchRAM3 |
| Ethernet | Intel (I217-V) — driven by IntelMausi |
| Audio | Realtek ALC — AppleALC + CodecCommander |
| SD reader | Realtek **RTS5227** (`pci10ec,5227`) — **disabled** |
| SMBIOS | `MacBookPro16,1` |
| macOS | 14.8.8 (Sonoma, build 23J620) |
| OpenCore | 1.0.4 |
| Boot args | `keepsyms=1 amfi_get_out_of_my_way=1 revpatch=sbvmm` |

Detailed specs: [`01-specifications/`](hackintosh-t440p/01-specifications/specs.md)

## Documented issues

| Issue | Outcome | Details |
|-------|---------|---------|
| Dead left-side USB port, below the SD reader (EHCI, no driver in Sonoma) | 🚫 No solution | [`02-dead-usb-port/`](hackintosh-t440p/02-dead-usb-port/) |
| SD card reader (boot/wake/shutdown panics) — full investigation + fix research | 🔇 Disabled | [`03-sd-card-reader/`](hackintosh-t440p/03-sd-card-reader/) |
| Direct boot (`ShowPicker=false`) + dirty-EFI repair | ✅ Solved | [`04-direct-boot/`](hackintosh-t440p/04-direct-boot/) |
| Production `config.plist` + kext/quirk reference | ✅ | [`05-open-core-config/`](hackintosh-t440p/05-open-core-config/) |
| Post-install: TRIM, monitoring, EFI maintenance, Sequoia roadmap | ✅ | [`06-post-install/`](hackintosh-t440p/06-post-install/) |
| ABNT2 keyboard remap (`?`/`/`, `'`/`\`, Delete, Cmd+Tab) | ✅ Solved | [`keyboard-remap/`](keyboard-remap/README.md) |

## Sequoia status

**Sonoma 14.8.8 is stable and in daily use.** We are now **working on macOS
Sequoia (15)** — updates to OpenCore and the kexts are being tested. Progress is
tracked in [issue #1](https://github.com/LeBritow/T440p-hackintosh-sonoma/issues/1)
(checklist + roadmap). The upgrade plan is in
[`06-post-install/`](hackintosh-t440p/06-post-install/README.md).

## Contributing

Found a fix, a better kext, or a tip for this hardware? Open an **issue** or a
**pull request** — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Key lessons

1. **Always back up `config.plist` (`config.plist.bak-<date>`) before editing it.**
   A single backup restored the boot after USBInjectAll locked the machine.
2. **Do not use legacy USB kexts (USBInjectAll 0.8.1) on Sonoma** — it breaks boot.
3. **Do not fight EHCI on macOS 14** — Apple removed the driver; even the OCLP
   path panics. The legacy USB 2.0 port has no solution.
4. **The Realtek SD reader is unstable on Sonoma** — panics at boot, wake and
   shutdown regardless of card presence. Disabled by choice.
5. **The EFI partition (FAT) gets flagged `dirty` after unclean shutdowns** — if it
   stops mounting, run `sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1`.

## Repository layout

```
EFI/                     OpenCore EFI — placeholder SMBIOS (== release v1.0.0)
scripts/                 Recovery download utilities (macrecovery)
hackintosh-t440p/        Full project documentation
  ├── 01-specifications/
  ├── 02-dead-usb-port/
  ├── 03-sd-card-reader/
  ├── 04-direct-boot/
  ├── 05-open-core-config/
  ├── 06-post-install/
  ├── 07-credits.md       Credits for every kext/driver/tool used
  └── efi-sonoma-14.8.8/  Snapshot of the working EFI (Sonoma)
keyboard-remap/          ABNT2 keyboard remapper (C + LaunchAgent)
```

## Releases

Ready-to-use EFI zips are published under
[Releases](https://github.com/LeBritow/T440p-hackintosh-sonoma/releases) —
the current one is **v1.0.0** (Sonoma 14.8.8, OpenCore 1.0.4). Generate your own
SMBIOS before using it (see the SMBIOS notice above).

## Credits

This build relies on many open-source projects — Acidanthera (OpenCore, Lilu,
WhateverGreen, VirtualSMC, AppleALC, ...), OpenIntelWireless (AirportItlwm),
zhen-zen (YogaSMC), 0xFireWolf (RealtekCardReader), cholonam (Sinetek-rtsx),
RehabMan, Dolnor & Sniki (CodecCommander), VoodooProjects (VoodooRMI),
corpnewt (USBMap, GenSMBIOS), exelban (Stats), Dortania (install guide), Tulugaak &
valnoxy (base EFI collection this build started from), and more.
Full list: [`hackintosh-t440p/07-credits.md`](hackintosh-t440p/07-credits.md).

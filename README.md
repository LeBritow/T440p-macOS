# T440p Hackintosh — macOS 15.7.8 (Sequoia) via OpenCore

A **Lenovo ThinkPad T440p** running **macOS 15.7.8 (Sequoia, build 24G824)** with
**OpenCore 1.0.7**. This repository documents the real, hardware-verified issues
encountered during setup and the solutions applied — intended for anyone working
with the same laptop (or any Haswell / Intel 8-series chipset).

> **SMBIOS notice:** All SMBIOS data in this repository are **placeholders**
> (`AAAAAAAA...`). Generate your own values with GenSMBIOS before use — a public
> serial number can cause iMessage/FaceTime blacklisting.

## Machine status

| Component | Status |
|-----------|--------|
| Boot | OpenCore picker shown at power-on (5 s timeout; select **macOS**) |
| Wi-Fi / Bluetooth / Ethernet / Audio | ✅ Working |
| Graphics | ✅ Full acceleration + blur/animations — HD 4600 with OCLP post-install patch + `-amfipassbeta` |
| Left-side USB port (below the SD reader) | 🔌 **Dead** — EHCI controller, driver removed in macOS 14/15 (no solution) |
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
| Wi-Fi | Intel Centrino 6235 — driven by `AirportItlwm_Sequoia` (native AirPort via OCLP post-install patch) |
| Bluetooth | Broadcom **BCM_4350C2** — driven by BrcmPatchRAM3 |
| Ethernet | Intel (I217-V) — driven by IntelMausi |
| Audio | Realtek ALC — AppleALC + CodecCommander |
| SD reader | Realtek **RTS5227** (`pci10ec,5227`) — **disabled** |
| SMBIOS | `MacBookPro16,1` |
| macOS | 15.7.8 (Sequoia, build 24G824) |
| OpenCore | 1.0.7 |
| SIP / CSR | `csr-active-config = 0x80003` (nvram shows `%03%08%00%00`) |
| Boot args | `keepsyms=1 revpatch=sbvmm -amfipassbeta amfi_get_out_of_my_way=1` |

Detailed specs: [`01-specifications/`](hackintosh-t440p/01-specifications/specs.md)

## Documented issues

| Issue | Outcome | Details |
|-------|---------|---------|
| Dead left-side USB port, below the SD reader (EHCI, no driver in Sonoma/Sequoia) | 🚫 No solution | [`02-dead-usb-port/`](hackintosh-t440p/02-dead-usb-port/) |
| SD card reader (boot/wake/shutdown panics) — full investigation + fix research | 🔇 Disabled | [`03-sd-card-reader/`](hackintosh-t440p/03-sd-card-reader/) |
| Direct boot (`ShowPicker=false`) + dirty-EFI repair | ✅ Solved | [`04-direct-boot/`](hackintosh-t440p/04-direct-boot/) |
| Production `config.plist` + kext/quirk reference | ✅ | [`05-open-core-config/`](hackintosh-t440p/05-open-core-config/) |
| Post-install: TRIM, monitoring, EFI maintenance, Sequoia upgrade | ✅ | [`06-post-install/`](hackintosh-t440p/06-post-install/) |
| ABNT2 keyboard remap (`?`/`/`, `'`/`\`, Delete, Cmd+Tab) | ✅ Solved | [`keyboard-remap/`](keyboard-remap/README.md) |

## Sequoia status

**✅ Done — Sequoia 15.7.8 is stable and in daily use** (replaced Sonoma 14.8.8).

What was needed to get from Sonoma to Sequoia:

- OpenCore **1.0.4 → 1.0.7**
- macOS **14.8.8 → 15.7.8** (fresh install, since the Sonoma install couldn't be
  upgraded in place and the root volume is sealed)
- New/changed kexts for Sequoia:
  - `AirportItlwm_Sequoia` (Sequoia build) + `IOSkywalkFamily` + `IO80211FamilyLegacy`
  - `AMFIPass` (1.4.0) with `-amfipassbeta` — supports full GPU acceleration on
    Haswell (patched by OCLP)
  - `BrcmPatchRAM3` replaced `BrcmFirmwareRepo`/`IntelBluetoothFirmware`-based
    Broadcom handling (BlueToolFixup kept)
  - `IOSkywalkFamily` downgrade blocked via `Kernel.Block` for Sequoia
- **OCLP post-install patch** ran on the sealed root volume and patched **both**:
  - **network** (AirportItlwm-Mod) → WiFi works as native AirPort
  - **graphics** (HD 4600) → full acceleration + blur/animations
- csr-active-config stays `0x80003` (root patchable + `-amfipassbeta`)

The full upgrade log is in [`06-post-install/`](hackintosh-t440p/06-post-install/README.md).

## Contributing

Found a fix, a better kext, or a tip for this hardware? Open an **issue** or a
**pull request** — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Key lessons

1. **Always back up `config.plist` (`config.plist.bak-<date>`) before editing it.**
   A single backup restored the boot after USBInjectAll locked the machine.
2. **Do not use legacy USB kexts (USBInjectAll 0.8.1) on Sonoma/Sequoia** — it breaks boot.
3. **Do not fight EHCI on macOS 14/15** — Apple removed the driver; even the OCLP
   path panics. The legacy USB 2.0 port has no solution.
4. **The Realtek SD reader is unstable on Sonoma/Sequoia** — panics at boot, wake
   and shutdown regardless of card presence. Disabled by choice.
5. **The EFI partition (FAT) gets flagged `dirty` after unclean shutdowns** — if it
   stops mounting, run `sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1`.
6. **Sequoia needs the `IOSkywalkFamily` downgrade blocked + `AirportItlwm_Sequoia`
   (or the OCLP `AirportItlwm-Mod`)** — the Sonoma kexts will not load. Use the
   OCLP post-install patch to get native AirPort.
7. **The ABNT2 remap is a LaunchAgent, not a kernel change** — it can silently
   disappear on reinstalls; re-install it from `keyboard-remap/`.

## Repository layout

```
EFI/                     OpenCore EFI — placeholder SMBIOS (Sequoia, OC 1.0.7)
scripts/                 Recovery download utilities (macrecovery)
hackintosh-t440p/        Full project documentation
  ├── 01-specifications/
  ├── 02-dead-usb-port/
  ├── 03-sd-card-reader/
  ├── 04-direct-boot/
  ├── 05-open-core-config/
  ├── 06-post-install/
  ├── 07-credits.md       Credits for every kext/driver/tool used
  ├── efi-sonoma-14.8.8/  Snapshot of the working EFI (Sonoma, OC 1.0.4)
  └── efi-sequoia-15.7.8/ Snapshot of the working EFI (Sequoia, OC 1.0.7)
keyboard-remap/          ABNT2 keyboard remapper (C + LaunchAgent)
```

## Releases

Ready-to-use EFI zips are published under
[Releases](https://github.com/LeBritow/T440p-hackintosh-sonoma/releases):
**v1.0.0** is the Sonoma 14.8.8 build (OC 1.0.4). The current working tree targets
**Sequoia 15.7.8** (OC 1.0.7) — the repo is being renamed to
`T440p-hackintosh-sequoia` and a new release will follow. Generate your own SMBIOS
before using it (see the SMBIOS notice above).

## Credits

This build relies on many open-source projects — Acidanthera (OpenCore, Lilu,
WhateverGreen, VirtualSMC, AppleALC, ...), OpenIntelWireless (AirportItlwm, incl.
the Sequoia build), zhen-zen (YogaSMC), 0xFireWolf (RealtekCardReader),
cholonam (Sinetek-rtsx), RehabMan, Dolnor & Sniki (CodecCommander),
VoodooProjects (VoodooRMI), corpnewt (USBMap, GenSMBIOS), exelban (Stats),
Dortania (install guide), Tulugaak & valnoxy (base EFI collection this build
started from), and more.
Full list: [`hackintosh-t440p/07-credits.md`](hackintosh-t440p/07-credits.md).

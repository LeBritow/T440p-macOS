# T440p Hackintosh — macOS 15.7.8 (Sequoia) via OpenCore

This guide installs **macOS Sequoia 15.7.8** on a **Lenovo ThinkPad T440p** using
the EFI in this repository (**OpenCore 1.0.7**). Everything here is hardware-
verified on the author's machine (i7-4700MQ, HD 4600, 16 GB, Intel WiFi).

> **SMBIOS notice:** All SMBIOS data in this repository are **placeholders**
> (`AAAAAAAA...`). Before using the EFI, **generate your own values with
> GenSMBIOS** — a public serial number can cause iMessage/FaceTime blacklisting.

---

## What works / what doesn't

| Component | Status |
|-----------|--------|
| Boot | OpenCore picker shown at power-on (5 s timeout; select **macOS**) |
| Wi-Fi / Bluetooth / Ethernet / Audio | ✅ Working |
| Graphics | ✅ Full acceleration + blur/animations — HD 4600 with OCLP post-install patch + `-amfipassbeta` |
| Left-side USB port (below the SD reader) | 🔌 **Dead** — EHCI controller, driver removed in macOS 14/15 (no solution) |
| SD card reader (RTS5227) | 🔇 **Disabled** — both drivers caused boot/wake/shutdown panics |
| ABNT2 keyboard (`?`→`/`) | ✅ Fixed with a userspace remapper (see `keyboard-remap/`) |

---

## Prerequisites

- A **Lenovo ThinkPad T440p** with a Haswell i5/i7 (iGPU HD 4600).
- A **mac** (or a Hackintosh) to prepare the installer USB.
- A **USB stick of 8 GB or more** (will be erased).
- The files in this repo: the **`EFI/`** folder and the **`scripts/`** folder.
- A backup of anything you don't want to lose (the target disk is erased).

---

## 1. Generate your own SMBIOS

The EFI ships with placeholder values. Generate your own `MacBookPro16,1` values
with [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) and write them into
`EFI/OC/Config.plist` → `PlatformInfo → Generic`:

| Key | Value |
|-----|-------|
| `SystemProductName` | `MacBookPro16,1` |
| `SystemSerialNumber` | *your generated serial* |
| `MLB` | *your generated MLB* |
| `SystemUUID` | *your generated UUID* |

## 2. BIOS / UEFI settings (T440p)

Set these in the BIOS (Enter at the Lenovo logo → **Config** / **Security** /
**Startup**):

- **Config → USB**: all enabled.
- **Config → Power → Intel SpeedStep**: Enabled.
- **Config → CPU → Hyper-Threading**: Enabled.
- **Security → Secure Boot**: **Disabled**.
- **Security → Virtualization → Intel Virtualization Technology**: Enabled
  (VT-d doesn't matter: `DisableIoMapper=true` already handles it).
- **Startup → UEFI/Legacy Boot**: **UEFI Only** (CSM off).
- **Startup → Boot Mode**: Quick.
- **Startup → Boot**: make sure the USB stick is first, or use **F12** at boot.
- **Config → Serial ATA**: **AHCI** (default on the T440p).

CFG Lock can stay **on** — the config sets `AppleXcpmCfgLock=true`.

## 3. Prepare the installer USB

On the Mac you're using to prepare the stick:

```bash
# 1. Erase the USB stick (in Disk Utility: Erase as "Mac OS Extended (Journaled)",
#    GUID Partition Map) — it shows up as /dev/diskX.

# 2. Download the Sequoia recovery image with the macrecovery script from this repo
#    (canonical "latest" download, as in the Dortania guide):
cd scripts
python3 macrecovery.py -b Mac-937A206F2EE63C01 download
```

The recovery image is downloaded as `BaseSystem.dmg` + `BaseSystem.chunklist`
(Big Sur and later). Create two partitions on the stick: one **Mac OS Extended
(Journaled)** and one small **EFI** partition. Restore `BaseSystem.dmg` to the
Mac OS Extended partition (`asr restore --source BaseSystem.dmg --target /dev/diskXs2`
or via Disk Utility's Restore). Finally copy the **`EFI/`** folder from this repo
to the stick's EFI partition.

> Alternative: the [Dortania OpenCore Guide](https://dortania.github.io/OpenCore-Install-Guide/)
> has a full step-by-step for creating the USB — the `scripts/` here are the same
> `macrecovery.py` used there.

## 4. Boot the installer

1. Insert the USB, power on, press **F12**, choose the USB (UEFI).
2. OpenCore's picker appears. Select the **macOS Installer** entry
   (an external drive icon with the macOS name).
3. When the installer loads, open **Disk Utility**, erase the internal SSD as
   **APFS, GUID Partition Map**, close Disk Utility, and run **Install macOS
   Sequoia**.
4. The machine reboots several times. If the picker doesn't show the install
   volume automatically, keep selecting the **macOS Installer** entry each time
   until the installer finishes and you reach the setup assistant.

## 5. First boot + post-install

### 5a. OpenCore Legacy Patcher (WiFi + graphics) — REQUIRED

This machine needs the OCLP root patch for **both WiFi and the HD 4600**:

1. Download [OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher)
   (the GUI app) and open it.
2. **Post-Install Root Patch** → it applies the patches for the **network**
   (AirportItlwm-Mod → native AirPort) and the **graphics** (HD 4600).
3. Reboot. WiFi shows up as a native AirPort interface and the UI is fully
   accelerated (blur, animations).

> OCLP needs the root volume to be patchable — the config already keeps
> `csr-active-config = 0x80003` and `amfi_get_out_of_my_way=1`.

### 5b. ABNT2 keyboard remap

On a Brazilian ABNT2 keyboard the `?`/`/` key (and the `'`↔`\`, `"`↔`|` swaps)
are wrong. The fix is a userspace remapper in this repo:

```bash
cp -R keyboard-remap/05-remap-usuario "/Users/<you>/Documents/Default Project/remap-teclado/05-remap-usuario"
cd "/Users/<you>/Documents/Default Project/remap-teclado/05-remap-usuario"
./instalar.sh
```

Then add the binary to **System Settings → Privacy & Security → Accessibility**
(the remap can't receive keys without it). Full docs: [`keyboard-remap/`](keyboard-remap/README.md).

### 5c. Optional tweaks

- **TRIM** for the SSD: `sudo trimforce enable` (type `y` twice; auto-reboots).
- **Direct boot** (skip the picker): see `hackintosh-t440p/04-direct-boot/`.

---

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

---

## Known issues and documented fixes

| Issue | Outcome | Details |
|-------|---------|---------|
| Dead left-side USB port, below the SD reader (EHCI, no driver in Sonoma/Sequoia) | 🚫 No solution | [`02-dead-usb-port/`](hackintosh-t440p/02-dead-usb-port/) |
| SD card reader (boot/wake/shutdown panics) — full investigation + fix research | 🔇 Disabled | [`03-sd-card-reader/`](hackintosh-t440p/03-sd-card-reader/) |
| Direct boot (`ShowPicker=false`) + dirty-EFI repair | ✅ Solved | [`04-direct-boot/`](hackintosh-t440p/04-direct-boot/) |
| Production `config.plist` + kext/quirk reference | ✅ | [`05-open-core-config/`](hackintosh-t440p/05-open-core-config/) |
| Post-install: TRIM, monitoring, EFI maintenance, Sequoia upgrade log | ✅ | [`06-post-install/`](hackintosh-t440p/06-post-install/) |
| ABNT2 keyboard remap (`?`/`/`, `'`/`\`, Delete, Cmd+Tab) | ✅ Solved | [`keyboard-remap/`](keyboard-remap/README.md) |

**Maintenance tip:** the EFI partition (FAT) gets flagged `dirty` after unclean
shutdowns and stops mounting — fix with
`sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1`.

---

## Key lessons

1. **Always back up `config.plist` (`config.plist.bak-<date>`) before editing it.**
   A single backup restored the boot after USBInjectAll locked the machine.
2. **Do not use legacy USB kexts (USBInjectAll 0.8.1) on Sonoma/Sequoia** — it breaks boot.
3. **Do not fight EHCI on macOS 14/15** — Apple removed the driver; even the OCLP
   path panics. The legacy USB 2.0 port has no solution.
4. **The Realtek SD reader is unstable on Sonoma/Sequoia** — panics at boot, wake
   and shutdown regardless of card presence. Disabled by choice.
5. **Sequoia needs the Sequoia WiFi stack** (`AirportItlwm_Sequoia` +
   `IOSkywalkFamily`/`IO80211FamilyLegacy` + a `Kernel.Block` on the system
   `IOSkywalkFamily`) — the Sonoma kexts will not load. Then run the OCLP
   post-install patch.
6. **The ABNT2 remap is a LaunchAgent, not a kernel change** — it can silently
   disappear on reinstalls; re-install it from `keyboard-remap/`.

---

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

- **v1.0.0** — Sonoma 14.8.8 (OC 1.0.4).
- **v2.0.0** — Sequoia 15.7.8 (OC 1.0.7) *(pending)*.

Generate your own SMBIOS before using them (see the SMBIOS notice above).

## Contributing

Found a fix, a better kext, or a tip for this hardware? Open an **issue** or a
**pull request** — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Credits

This build relies on many open-source projects — Acidanthera (OpenCore, Lilu,
WhateverGreen, VirtualSMC, AppleALC, ...), OpenIntelWireless (AirportItlwm, incl.
the Sequoia build), zhen-zen (YogaSMC), 0xFireWolf (RealtekCardReader),
cholonam (Sinetek-rtsx), RehabMan, Dolnor & Sniki (CodecCommander),
VoodooProjects (VoodooRMI), corpnewt (USBMap, GenSMBIOS), exelban (Stats),
Dortania (install guide + OpenCore Legacy Patcher), Tulugaak & valnoxy (base EFI
collection this build started from), and more.
Full list: [`hackintosh-t440p/07-credits.md`](hackintosh-t440p/07-credits.md).

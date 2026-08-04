# Post-install, maintenance and roadmap

Post-stabilization work and notes: TRIM, system monitoring, EFI maintenance and
the planned upgrade to Sequoia.

## TRIM on the SSD (recommended)

Non-Apple SSDs ship with TRIM disabled on macOS (`system_profiler SPSerialATADataType`
→ `No`). Enabling it prevents gradual performance degradation over time:

```bash
sudo trimforce enable    # type "y" twice — it reboots automatically
```

- The OpenCore `ThirdPartyDrives` quirk is **ignored on Sonoma+** (only applied up
  to macOS 10.15). On Sonoma the only path is `trimforce`.
- Verify with: `system_profiler SPSerialATADataType | grep TRIM` → `Yes`.
- On this machine it was enabled and the system felt noticeably more responsive.

## Monitoring (CPU / RAM / temps / fan)

Recommended app: **[Stats](https://github.com/exelban/stats)** (free, open source).

- Shows CPU, memory, disk, network, **temperatures**, **fan** and battery in the
  menu bar.
- Works well on Hackintoshes because `VirtualSMC` + `SMCProcessor` + `SMCSuperIO`
  expose the **real physical sensors** (CPU via MSR, fan via Super I/O).
- **Exception:** GPU usage/temperature is not reliably exposed on the HD 4600
  (not available through SMC).
- Install without Homebrew: download the `.dmg` from the release page and drag to
  /Applications.

Alternatives: iStat Menus (paid), MenuMeters (free), Intel Power Gadget
(CPU frequency/temp).

## EFI partition maintenance (FAT `dirty`)

Unclean shutdowns mark the EFI as `dirty` and it stops mounting:

```bash
sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1
```

Golden rule: **always** `cp config.plist config.plist.bak-$(date +%Y%m%d-%H%M%S)`
before touching the config.

## Roadmap: upgrade to macOS Sequoia (15)

Motivation: current iMovie and other apps require macOS 15; the T440p (Haswell
HD 4600) is supported.

> **Not yet executed** — planned, with the safe steps defined:

1. **Time Machine backup** first (safety net to return to the current state).
2. **Update OpenCore + kexts** while still on Sonoma, and test boot:
   - `AirportItlwm` → the **Sequoia build (2.4.x)** — 2.3.0 is the Sonoma build
     and kills Wi-Fi on Sequoia.
   - `Lilu`, `WhateverGreen`, `AppleALC` → latest versions.
   - `OpenCore` 1.0.4 → latest available.
3. **OTA**: Settings → Software Update (SMBIOS `MacBookPro16,1` + boot arg
   `revpatch=sbvmm` already allow OTA).
4. **Post-upgrade**: verify Wi-Fi/audio/USB/battery; reinstall Stats if needed.

Returning to Sonoma is possible (restore the old EFI + Time Machine restore), so
the upgrade does not "burn the bridge".

## Ports and hardware — practical summary

| Item | Situation |
|------|-----------|
| **Right-side** USB (Always-On) | ✅ Working |
| Left **USB 3.0** (top/bottom) | ✅ Working |
| **Left-side** USB (below SD) | 🔌 Dead — EHCI without driver on Sonoma |
| **SD** card reader (RTS5227) | 🔇 Disabled (kexts panicked on boot/wake/shutdown) |
| Wi-Fi / BT / Audio / Ethernet / Battery | ✅ Working |
| Boot | Direct to logo; **Esc** at power-on = menu |

## Backup

`~/Documents/backup/` contains the EFI with the real SMBIOS, the keyboard project
and the restore guide — **copy the whole folder to an external drive**.

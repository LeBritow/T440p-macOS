# Post-install, maintenance and upgrade log

Post-stabilization work and notes: TRIM, system monitoring, EFI maintenance and
the completed Sequoia upgrade.

## TRIM on the SSD (recommended — currently OFF on this machine)

Non-Apple SSDs ship with TRIM disabled on macOS (`system_profiler SPSerialATADataType`
→ `No`). Enabling it prevents gradual performance degradation over time:

```bash
sudo trimforce enable    # type "y" twice — it reboots automatically
```

- The OpenCore `ThirdPartyDrives` quirk is **ignored on Sonoma+** (only applied up
  to macOS 10.15). On Sonoma/Sequoia the only path is `trimforce`.
- Verify with: `system_profiler SPSerialATADataType | grep TRIM` → `Yes`.
- On this machine it was enabled (Sonoma) and the system felt noticeably more
  responsive. **Not yet re-enabled after the Sequoia reinstall.**

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

## Sequoia upgrade — DONE (Sonoma 14.8.8 → Sequoia 15.7.8)

Motivation: current iMovie and other apps require macOS 15; the T440p (Haswell
HD 4600) is supported.

**Result:** Sequoia 15.7.8 (build 24G824) is stable and in daily use.

### What happened

1. **In-place upgrade failed** — the OTA/upgrader kept failing (sealed root volume
   + legacy kernel extensions), so the route was a **fresh install** from a USB
   stick (macrecovery → Install macOS Sequoia), overwriting the Sonoma install.
2. **OpenCore 1.0.4 → 1.0.7**, SMBIOS kept at `MacBookPro16,1`.
3. **Kexts updated/changed for Sequoia:**
   - `AirportItlwm` → **`AirportItlwm_Sequoia`** (Sequoia build, `MinKernel 24.0.0`)
     + `IOSkywalkFamily` + `IO80211FamilyLegacy` (+ `Kernel.Block` on the system
     `IOSkywalkFamily`). The Sonoma `AirportItlwm` stays with `MaxKernel 23.9.9`.
   - `AMFIPass` 1.4.0 + boot arg **`-amfipassbeta`** → full GPU acceleration and
     blur kept on the HD 4600, **no OCLP graphics patch** needed.
   - `BrcmPatchRAM3` (with `BlueToolFixup`) for the Broadcom BT — same as Sonoma.
   - Realtek SD kexts dropped from the Sequoia build (still disabled anyway).
4. **WiFi = native AirPort** after running the **OCLP post-install patch** (the
   `AirportItlwm-Mod` build). No root volume patch for graphics.
5. `csr-active-config` stays `0x80003` (`%03%08%00%00`), boot args
   `keepsyms=1 revpatch=sbvmm -amfipassbeta amfi_get_out_of_my_way=1`.

### After the reinstall (checklist, machine-specific)

- [x] WiFi (native AirPort via en1) — **192.168.1.206**
- [x] Bluetooth, Ethernet, Audio, Battery, Trackpad
- [x] GPU acceleration (Metal 2, 1536 MB) + blur/animations
- [x] **ABNT2 remap reinstalled** (LaunchAgent did not survive the fresh install —
      see `keyboard-remap/`); still needs **Acessibilidade** permission granted
      in System Settings → Privacy & Security → Accessibility
- [ ] **TRIM re-enabled** (`sudo trimforce enable`)
- [ ] Optional: re-enable direct boot (`04-direct-boot/`) if desired

Returning to Sonoma is still possible (restore the old EFI + Time Machine), so
the upgrade did not "burn the bridge".

## Ports and hardware — practical summary

| Item | Situation |
|------|-----------|
| **Right-side** USB (Always-On) | ✅ Working |
| Left **USB 3.0** (top/bottom) | ✅ Working |
| **Left-side** USB (below SD) | 🔌 Dead — EHCI without driver on macOS 14/15 |
| **SD** card reader (RTS5227) | 🔇 Disabled (kexts panicked on boot/wake/shutdown) |
| Wi-Fi / BT / Audio / Ethernet / Battery | ✅ Working |
| Boot | Picker shown (5 s), select **macOS** |

## Backup

`~/Documents/backup/` contains the EFI with the real SMBIOS, the keyboard project
and the restore guide — **copy the whole folder to an external drive**.

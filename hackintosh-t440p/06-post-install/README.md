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

### OCLP vs OCLP-Mod — pick the right build (and the right moment)

- **Sonoma:** the **standard OCLP**
  ([dortania/OpenCore-Legacy-Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher))
  works fine.
- **Sequoia:** you **must** use **OCLP-Mod**
  ([laobamac/OCLP-Mod](https://github.com/laobamac/OCLP-Mod)) — the standard OCLP
  does not patch Sequoia properly.
- **Order matters:** run the **Post-Install Root Patch only after** the
  Sonoma → Sequoia upgrade has completed. The patch is tied to the running macOS
  version and re-seals the root volume — applying the wrong version's patch
  breaks the system and can force a fresh install.

### What happened

1. **In-place upgrade failed** — the OTA/upgrader kept failing (sealed root volume
   + legacy kernel extensions), so the route was a **fresh install** from a USB
   stick (macrecovery → Install macOS Sequoia), overwriting the Sonoma install.
2. **OpenCore 1.0.4 → 1.0.7**, SMBIOS kept at `MacBookPro16,1`.
3. **Kexts updated/changed for Sequoia:**
   - `AirportItlwm` → **`AirportItlwm_Sequoia`** (Sequoia build, `MinKernel 24.0.0`)
     + `IOSkywalkFamily` + `IO80211FamilyLegacy` (+ `Kernel.Block` on the system
     `IOSkywalkFamily`). The Sonoma `AirportItlwm` stays with `MaxKernel 23.9.9`.
   - `AMFIPass` 1.4.0 + boot arg **`-amfipassbeta`** → supports GPU acceleration on
     the HD 4600 (which OCLP then patches).
   - `BrcmPatchRAM3` (with `BlueToolFixup`) for the Broadcom BT — same as Sonoma.
   - Realtek SD kexts dropped from the Sequoia build (still disabled anyway).
4. **OCLP-Mod post-install patch** ran on the sealed root volume (Sequoia build)
   and patched **both**:
   - **network** (`AirportItlwm-Mod` build) → WiFi runs as native AirPort;
   - **graphics** (HD 4600) → full acceleration + blur/animations.
5. `csr-active-config` stays `0x80003` (`%03%08%00%00`), boot args
   `keepsyms=1 revpatch=sbvmm -amfipassbeta amfi_get_out_of_my_way=1`.

### After the reinstall (checklist, machine-specific)

- [x] WiFi (native AirPort via en1) — **192.168.1.206**
- [ ] **Bluetooth — dead (unsupported Intel chip `0x07DA`)** — see
      `08-bluetooth/`; `bluetoothd` crash-loop is reduced by disabling BT in
      the BIOS (`Config → Network → Bluetooth`)
- [x] Ethernet, Audio, Battery, Trackpad
- [x] GPU acceleration (Metal 2, 1536 MB) + blur/animations
- [x] **ABNT2 remap reinstalled** (LaunchAgent did not survive the fresh install —
      see `keyboard-remap/`); still needs **Acessibilidade** permission granted
      in System Settings → Privacy & Security → Accessibility
- [ ] **TRIM re-enabled** (`sudo trimforce enable`)
- [ ] Optional: re-enable direct boot (`04-direct-boot/`) if desired

Returning to Sonoma is still possible (restore the old EFI + Time Machine), so
the upgrade did not "burn the bridge".

## Performance — what was applied and what is left

Boot and day-to-day responsiveness audit (Aug 2026). Priorities, biggest first.

### 1. TRIM on the SSD — OFF, re-enable (see section above)

`system_profiler SPSerialATADataType` reports `No`. It was enabled under Sonoma and
reverted by the Sequoia reinstall. Re-enable with `sudo trimforce enable` (reboots).

### 2. Power management — make OC and macOS agree

`HibernateMode` is `None` in OpenCore, but macOS still has `hibernatemode 3` — the
hibernate (dark-wake / disk image) path. Align them so sleep is fast and clean:

```bash
sudo pmset -a hibernatemode 0      # match OC HibernateMode=None
sudo pmset -b tcpkeepalive 0       # battery only: drop Wi-Fi keepalive while asleep
```

- `powernap 0` and `FileVault off` are already good on this machine (both hurt
  battery/boot).
- Sanity check: `pmset -g | grep -E "hibernatemode|tcpkeepalive"`.

### 3. Battery-friendly while keeping speed

- `tcpkeepalive` only applies while the lid is closed on battery — no perf cost.
- Fan/heat: the i7-4700MQ under sustained load is thermal-limited in the T440p.
  Keeping the heatsink clean and the fan curve healthy (watch it in Stats) is the
  most effective "free" performance upgrade.
- **Not recommended:** VoltageShift-style undervolting on this Haswell — unstable
  on modern macOS and a real risk of boot loops for little gain.

### 4. Not worth doing (checked, no win)

- **CPUFriend**: loaded but has no `CPUFriendDataProvider` plugin, so it changes
  nothing. Removing the kext would only save a few ms of load time — left in place
  in case a real power profile is added later.
- **Spotlight**: `Indexing enabled` is the default and cheap once the initial index
  is done; only disable it (`sudo mdutil -i off /`) if the first minutes after
  install feel sluggish and search is not used.
- **Animations/transparency**: with full HD 4600 acceleration they are not the
  bottleneck.
- **Login items**: already clean (only the ABNT2 remap agent).

### 5. Boot time — the first (cold) boot vs restarts

A cold boot is always slower than a warm restart on any Mac/Hackintosh (cold APFS
mount, kext cache, BIOS POST). The T440p's Lenovo logo delay is the BIOS POST and
it is already minimized:

- unplug USB sticks/devices (biggest single win);
- BIOS `Startup → Boot Mode: Quick`;
- EFI drivers kept to the minimum (Linux/NTFS/Ext4 drivers removed);
- the rest is OpenCore + kext load + OCLP root-patch kexts, which are needed for
  the graphics/WiFi patches — nothing safe to shave there.

## Ports and hardware — practical summary

| Item | Situation |
|------|-----------|
| **Right-side** USB (Always-On) | ✅ Working |
| Left **USB 3.0** (top/bottom) | ✅ Working |
| **Left-side** USB (below SD) | 🔌 Dead — EHCI without driver on macOS 14/15 |
| **SD** card reader (RTS5227) | 🔇 Disabled (kexts panicked on boot/wake/shutdown) |
| Wi-Fi / Audio / Ethernet / Battery | ✅ Working |
| **Bluetooth** | 🔇 Dead — Intel `0x07DA` unsupported (see `08-bluetooth/`) |
| Boot | Picker shown (5 s), select **macOS** |

## Backup

`~/Documents/backup/` contains the EFI with the real SMBIOS, the keyboard project
and the restore guide — **copy the whole folder to an external drive**.

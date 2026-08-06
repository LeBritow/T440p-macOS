# Hackintosh ThinkPad T440p — Issues and Solutions

Documentation of **real issues resolved (and accepted)** on a ThinkPad T440p
running macOS **15.7.8 (Sequoia)** with **OpenCore 1.0.7** — for anyone with the
same laptop (or the same Haswell / 8-series chipset) and the same symptoms.

## Summary

| Issue | Status | Solution |
|-------|--------|----------|
| [Dead left-side USB port (below the SD reader)](02-dead-usb-port/) | 🚫 **No solution** | It is **EHCI**; macOS 14/15 removed the driver. Accepted as dead |
| [Bluetooth — Intel chip unsupported](08-bluetooth/) | 🔇 **Dead** | `0x8087:0x07DA` not supported by IntelBluetoothFirmware; no Broadcom present |
| [SD card reader (RTS5227)](03-sd-card-reader/) | 🔇 Disabled | Both kexts panicked (boot/wake/shutdown); reader disabled |
| [Direct boot to logo (no menu)](04-direct-boot/) | ✅ Option (picker on) | `ShowPicker=true`/`Timeout=5` now; direct boot via **Esc** recipe documented |
| [EFI won't mount (FAT dirty)](04-direct-boot/) | ✅ Manual fix | `sudo fsck_msdos -y /dev/rdisk0s1` |
| Production config.plist | — | [05-open-core-config/](05-open-core-config/) |
| Post-install: TRIM, monitoring, Sequoia upgrade | ✅ Done | [06-post-install/](06-post-install/) |
| ABNT2 keyboard remap | ✅ Working | [keyboard-remap/](../keyboard-remap/README.md) |

## Quick specs

ThinkPad **T440p** · Core **i7-4700MQ** · **HD 4600** (Metal 2) · **16 GB** RAM ·
SSD **240 GB** SATA/APFS · Wi-Fi **Intel Centrino 6235** · BT **Broadcom BCM_4350C2** ·
SD reader **Realtek RTS5227** · SMBIOS `MacBookPro16,1` · macOS 15.7.8 (24G824).

Full details: [01-specifications/](01-specifications/specs.md)

## Status and roadmap

**✅ Sequoia 15.7.8 is stable and in daily use** (replaced Sonoma 14.8.8 — fresh
install, OpenCore 1.0.7, new WiFi stack + AMFIPass). The upgrade log is in
[06-post-install/](06-post-install/).

## Contributing

Share your fixes and ideas — see [`CONTRIBUTING.md`](../CONTRIBUTING.md).

## Key lessons

1. **Always keep a `config.plist.bak-<date>` before editing the config.** A backup
   restored the boot after USBInjectAll locked the machine.
2. **Legacy USB kexts (USBInjectAll 0.8.1) break boot on Sonoma/Sequoia.** Avoid them.
3. **Do not fight EHCI on macOS 14/15.** The driver was removed by Apple; even the
   OCLP route panics. Accept the dead port and move on.
4. **The Realtek SD reader is a trap on Sonoma/Sequoia:** panics at boot **and** on
   wake from sleep (even with no card); Sinetek has a shutdown bug. Both were disabled.
5. **The EFI partition gets `dirty` after unclean shutdowns** — if the EFI will
   not mount, run the manual `fsck_msdos` (see [04-direct-boot](04-direct-boot/)).
6. **Sequoia needs the Sequoia WiFi stack** (`AirportItlwm_Sequoia` +
   `IOSkywalkFamily`/`IO80211FamilyLegacy` + `Kernel.Block`) and `AMFIPass` +
   `-amfipassbeta`, plus the **OCLP-Mod post-install patch** (which patches both
   the network and the HD 4600 graphics). On Sequoia you **must** use **OCLP-Mod**
   (`laobamac/OCLP-Mod`) — the standard OCLP is only for Sonoma. Run the root
   patch **only after** the Sonoma → Sequoia upgrade finishes.
7. **Bluetooth on the stock Intel combo card (`0x8087:0x07DA`) is dead by
   hardware** — `IntelBluetoothFirmware` has no personality for it and there is
   no Broadcom to patch. The "BCM_4350C2" in `system_profiler` is a phantom
   report. See [08-bluetooth/](08-bluetooth/).

## Layout

```
01-specifications/      laptop specs (collected from the system)
02-dead-usb-port/       EHCI diagnosis + SSDT-DEHCI.aml + USBInjectAll attempt
03-sd-card-reader/      RealtekCardReader vs Sinetek saga + fix research
04-direct-boot/         ShowPicker + dirty-EFI repair
05-open-core-config/    production config.plist + kext/quirk reference
06-post-install/        TRIM, monitoring, EFI maintenance, Sequoia upgrade log
07-credits.md           credits for every kext/driver/tool used
08-bluetooth/           Bluetooth investigation (unsupported Intel chip, accepted dead)
efi-sonoma-14.8.8/      snapshot of the working EFI (Sonoma, OC 1.0.4)
efi-sequoia-15.7.8/     snapshot of the working EFI (Sequoia, OC 1.0.7)
```

## Credits

This build relies on many open-source projects (Acidanthera, OpenIntelWireless,
zhen-zen, 0xFireWolf, cholonam, RehabMan, Dolnor, Sniki, VoodooProjects, corpnewt,
exelban, Dortania, Tulugaak & valnoxy (base EFI), ...). Full list with authors: [07-credits.md](07-credits.md).

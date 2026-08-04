# Hackintosh ThinkPad T440p — Issues and Solutions

Documentation of **real issues resolved (and accepted)** on a ThinkPad T440p
running macOS **14.8.8 (Sonoma)** with **OpenCore 1.0.4** — for anyone with the
same laptop (or the same Haswell / 8-series chipset) and the same symptoms.

## Summary

| Issue | Status | Solution |
|-------|--------|----------|
| [Dead left-side USB port (below the SD reader)](02-dead-usb-port/) | 🚫 **No solution** | It is **EHCI**; macOS 14 removed the driver. Accepted as dead |
| [SD card reader (RTS5227)](03-sd-card-reader/) | 🔇 Disabled | Both kexts panicked (boot/wake/shutdown); reader disabled |
| [Direct boot to logo (no menu)](04-direct-boot/) | ✅ Applied | `ShowPicker=false`, `Timeout=0`; menu via **Esc** |
| [EFI won't mount (FAT dirty)](04-direct-boot/) | ✅ Manual fix | `sudo fsck_msdos -y /dev/rdisk0s1` |
| Production config.plist | — | [05-open-core-config/](05-open-core-config/) |
| Post-install: TRIM, monitoring, Sequoia roadmap | — | [06-post-install/](06-post-install/) |
| ABNT2 keyboard remap | ✅ Working | [keyboard-remap/](../keyboard-remap/README.md) |

## Quick specs

ThinkPad **T440p** · Core **i7-4700MQ** · **HD 4600** (Metal 2) · **16 GB** RAM ·
SSD **240 GB** SATA/APFS · Wi-Fi **Intel** · BT **Broadcom BCM_4350C2** ·
SD reader **Realtek RTS5227** · SMBIOS `MacBookPro16,1` · macOS 14.8.8 (23J620).

Full details: [01-specifications/](01-specifications/specs.md)

## Key lessons

1. **Always keep a `config.plist.bak-<date>` before editing the config.** A backup
   restored the boot after USBInjectAll locked the machine.
2. **Legacy USB kexts (USBInjectAll 0.8.1) break boot on Sonoma.** Avoid them.
3. **Do not fight EHCI on macOS 14.** The driver was removed by Apple; even the
   OCLP route panics. Accept the dead port and move on.
4. **The Realtek SD reader is a trap on Sonoma:** panics at boot **and** on wake
   from sleep (even with no card); Sinetek has a shutdown bug. Both were disabled.
5. **The EFI partition gets `dirty` after unclean shutdowns** — if the EFI will
   not mount, run the manual `fsck_msdos` (see [04-direct-boot](04-direct-boot/)).

## Layout

```
01-specifications/      laptop specs (collected from the system)
02-dead-usb-port/       EHCI diagnosis + SSDT-DEHCI.aml + USBInjectAll attempt
03-sd-card-reader/      RealtekCardReader vs Sinetek saga + fix research
04-direct-boot/         ShowPicker=false + dirty-EFI repair
05-open-core-config/    production config.plist + kext/quirk reference
06-post-install/        TRIM, monitoring, EFI maintenance, Sequoia roadmap
07-credits.md           credits for every kext/driver/tool used
efi-sonoma-14.8.8/      snapshot of the working EFI (Sonoma)
```

## Credits

This build relies on many open-source projects (Acidanthera, OpenIntelWireless,
zhen-zen, 0xFireWolf, cholonam, RehabMan, Dolnor, Sniki, VoodooProjects, corpnewt,
exelban, Dortania, Tulugaak & valnoxy (base EFI), ...). Full list with authors: [07-credits.md](07-credits.md).

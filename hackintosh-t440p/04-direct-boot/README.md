# Direct Boot to the Apple Logo (boot picker disabled)

**Status: OPTION — applied on the author's machine (Sequoia).** The **published
EFI keeps the picker enabled** (`ShowPicker=true`, `Timeout=5`) so first-time
installers see the menu; this page documents how to switch your own install.

## Config changes

To boot straight into macOS:

```
Misc → Boot → ShowPicker       = false
Misc → Boot → Timeout          = 0
Misc → Boot → PollAppleHotKeys = true   ← required for the Esc fallback below
```

## How to reach the boot menu again

- **Hold `Esc`** at power-on / restart (`PollAppleHotKeys=true` makes the key
  work — without it you'd have no way back to the picker).
- To revert permanently: set `ShowPicker=true` and restore a `Timeout` in seconds.

## Faster boot (reduces time spent on the Lenovo logo before macOS)

- Unplug USB sticks/drives — an attached USB device makes the T440p BIOS POST
  much slower.
- BIOS: `Startup → Boot Mode: **Quick**` (not Diagnostics).
- Keep the EFI drivers to the minimum — Ext4/NTFS/Linux drivers only extend the
  filesystem probe surface. Removed from the config: `Ext4Dxe.efi`,
  `OpenNtfsDxe.efi`, `OpenLinuxBoot.efi`.

## Recurring issue: EFI partition "dirty" (FAT) will not mount

Unclean shutdowns flag the EFI partition (FAT) as `dirty`, after which
`diskutil mount disk0s1` fails:

```
Volume on disk0s1 failed to mount
If you think the volume is supported but damaged, try the "readOnly" option
```

### Manual repair (required whenever the EFI needs to be accessed)

```bash
sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1
```

## Good practice before editing `config.plist`

Always keep a backup before editing:

```bash
cp config.plist config.plist.bak-$(date +%Y%m%d-%H%M%S)
```

This is exactly what saved the system when USBInjectAll broke the boot — the last
good backup was restored and the machine booted again.

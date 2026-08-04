# Direct Boot to the Apple Logo (boot picker disabled)

**Status: APPLIED.** OpenCore skips the boot menu and boots straight into macOS.

## Config changes

```
Misc → Boot → ShowPicker = false
Misc → Boot → Timeout    = 0
```

## How to reach the boot menu again

- **Hold `Esc`** at power-on / restart.
- To revert permanently: set `ShowPicker=true` and restore a `Timeout` in seconds.

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

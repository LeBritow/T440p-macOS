# Dead Left-Side USB Port (Below the SD Reader) — Diagnosis: EHCI, no solution on Sonoma/Sequoia

**Status: NO SOLUTION.** The port is controlled by the **EHCI** controller, whose
driver Apple removed in macOS 14 (still absent on Sequoia 15). Accepted as a
hardware limitation.

## The problem

- The **left-side** USB port (right below the SD reader) does not work: a USB device
  does not light up and is not enumerated.
- The **right-side** port (Always-On, battery icon) works normally.
- The SD reader and the dead port are on the **same side** (left).

## Hypotheses tested (in order)

### 1. An XHCI port that was simply mis-mapped? ❌
`USBMap` had only 6 active ports (HSP2@3, HSP5@6, HSPA@b, HSPB@c). `HS05`
(reg `01000000`) and `HS06` (reg `02000000`) were added as "Top/Bottom Left USB 2.0".
**Result:** registers 1 and 2 **do not exist** on the XHCI controller (confirmed in
`ioreg`) → the dead port is **not** XHCI.

### 2. An EHCI port whose driver was removed? ✅ (conclusion)
- The DSDT defines `EHC1@1d0000` (EHCI), but on the running system **only XHCI**
  exists in `ioreg`.
- macOS 14 **removed the EHCI driver** (`IOUSBFamily`/AppleUSBEHCI no longer exists).
- `SSDT-DEHCI.aml` disables EHCI via `_INI` (strings `EH1D`/`EH2D`/`Darwin`) — the
  original OpenCore setup deliberately deactivated the controller.

### 3. USBInjectAll attempt — ⚠️ BROKE BOOT
- Downloaded `USBInjectAll 0.8.1` (a legacy kext from the Big Sur/Monterey era).
- Enabled it in the config + disabled `USBMap` + `XhciPortLimit=true`.
- **Result:** on reboot the machine **would not boot**.
- Recovery: restored `config.plist` from backup and removed the kext.

## Conclusion

1. The dead port is **EHCI** (legacy USB 2.0). On the T440p it sits on the left
   side, right below the SD reader.
2. macOS 14 has no EHCI driver → the port is **physically unreachable** on Sonoma.
3. The OCLP route (injecting the legacy USB driver) **also panics** on 14.1+.
4. `SSDT-DEHCI.aml` disables the controller at boot; even without it there is no
   driver to bind.

**Lesson learned:** do not test legacy USB kexts on Sonoma without first having a
`config.plist.bak` and a bootable USB at hand. This attempt broke boot and required
booting from a recovery USB to revert.

## Useful diagnostic commands

```bash
# What the controller sees (only XHCI is running)
ioreg -l -w0 | grep -E 'EHC1|pci8086,8c31|pciclass,0c0330'

# USB details
system_profiler SPUSBDataType

# XHCI ports in use
ioreg -p IODeviceTree -l | grep -E 'HSP|SSP'
```

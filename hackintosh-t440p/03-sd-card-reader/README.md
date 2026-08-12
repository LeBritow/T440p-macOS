# SD Card Reader — Realtek RTS5227

**Status: DISABLED (user decision).** Neither of the two available drivers proved
stable enough — each caused panics. The SD reader stays off; boot and sleep/wake
are now stable.

> Provenance: the base EFI this build started from
> ([Tulugaak/t440p-hackintosh-efi-collection](https://github.com/Tulugaak/t440p-hackintosh-efi-collection))
> also ships without SD support — "no compatible kext". We went further and tested
> both RealtekCardReader and Sinetek-rtsx before disabling the reader by choice.

## The problem

- Built-in SD reader = **Realtek RTS5227** (`pci10ec,5227`), left side.
- Two competing kexts, each with **one or more severe defects**:

| Driver | Reader works? | Defects |
|--------|---------------|---------|
| **RealtekCardReader 0.9.8** (`science.firewolf.rtsx`) | Yes | 1. **Boot panic** with a card in the slot; 2. **Wake-from-sleep panic** (even with no card) |
| **Sinetek-rtsx 9.0** | Yes | **Shutdown/restart bug** (wallpaper stuck on shutdown) |

## Timeline

1. **RealtekCardReader 0.9.8** chosen ("worked perfectly") under a usage protocol:
   no card at boot, insert only after boot, eject before shutdown.
2. **New symptom:** during a normal sleep/wake cycle **with no card in the slot**,
   the machine panicked on wake:

```
panic: Wake transition timed out after 180 seconds while calling power state change
callbacks. Suspected bundle: science.firewolf.rtsx.
RealtekCardReaderController::prepareToWakeUp → onSDCardInsertedSync → setPowerState
```

   In other words: the driver's power management is broken on this hardware
   **regardless of whether a card is present**.

3. **Decision:** disable **both kexts** and give up the SD reader in exchange for
   fully stable boot + sleep/wake.

## Research notes (if someone wants to try again later)

The **Sinetek-rtsx** driver has a documented fix specifically for the RTS5227:

> *"RTS5227 — Seems to work fine with sleep disabled. Adding boot parameter
> `rtsx_sleep_wake_delay_ms=1000` may help with sleep/wake."*

Verified by users on **T440S/X240** (same chip `0x522710EC`), who confirmed the
reader working after wake with that boot argument. If priorities change, that is
the path to test (Sinetek + `rtsx_sleep_wake_delay_ms=1000`).

**RealtekCardReader** has no sleep/wake boot argument (its `rtsxdcib` only delays
card init at boot), which is why disabling it entirely won.

## 2026-08-11 — New lead: `-rtsxnopm` boot argument (Path A)

A **binary analysis** of `RealtekCardReader.kext` (v0.9.7, the version shipped in
the EFI) found the exact panic path and a built-in escape hatch:

1. The kext **does** carry an `RealtekRTS5227Controller` personality
   (`IOPCIMatch 0x522710EC`) — it matches this chip. It simply never loaded
   because `Enabled=false`.
2. The wake-panic chain (confirmed in assembly):
   `prepareToWakeUp` → `IOCommandGateRunAction(onSDCardInsertedSync)` →
   `onSDCardInsertedSyncGated` waits on `onSDCardEventProcessedSyncCompletion`,
   and `setPowerState` calls a power-management virtual method (vtable+0x9d0)
   that **blocks forever** → the kernel's 180 s wake-transition timeout fires →
   panic. This is a **driver power-management bug**, independent of the macOS
   version.
3. The kext parses the boot argument **`-rtsxnopm`** and, when present,
   `setPowerState` **returns immediately** without calling the blocking PM
   routine — the author's own mitigation.

**Path A (in progress):** `EFI/OC/Config.pathA-rtsxnopm.plist` re-enables
`RealtekCardReader.kext` (`Enabled=true`) and adds `-rtsxnopm` to the boot-args.

Test protocol:
- Boot **without** a card in the slot; insert the card only after login.
- Eject the card before shutdown.
- Most important: exercise **sleep → wake** (that is where the old panic hit).

If it still panics on wake, fall back to the **stable `Config.plist`** and try
**Path B** (Sinetek + `rtsx_sleep_wake_delay_ms=1000`, verified on T440S/X240).

## Current state in `config.plist`

- `Config.plist` (stable default) → `RealtekCardReader.kext` **Enabled = false**
- `Config.pathA-rtsxnopm.plist` (experimental) → **Enabled = true** + `-rtsxnopm`
- `Sinetek-rtsx.kext` → **Enabled = false** (Path B, not yet re-tested)

(Rename the variant to `Config.plist` to activate, keeping a `.bak` first.)

## Quick diagnostics

```bash
# Confirm the reader device (with no driver it stays "unclaimed" in ioreg)
ioreg -l | grep -i 'pci10ec,5227'

# Confirm neither kext loads
kextstat | grep -iE 'rtsx|cardreader'
```

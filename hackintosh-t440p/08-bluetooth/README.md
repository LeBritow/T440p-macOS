# Bluetooth — dead (hardware not supported)

**Status: 🔇 Bluetooth does not work — the radio is an Intel chip that no
Hackintosh driver supports.** Documented like the SD reader and the dead EHCI
USB port: accepted as dead. The chipset reported by macOS (`BCM_4350C2`) is a
**phantom report**, not the real hardware.

## TL;DR

- The BT radio belongs to the WiFi/BT combo card (the same one that drives the
  WiFi as `iwn-6030`). On USB it enumerates as **Intel `0x8087:0x07DA`**.
- `IntelBluetoothFirmware` (the Intel BT driver) supports a fixed list of Intel
  chips (7260/7265/8265/9260/9560/AX200/AX210...). **`0x07DA` is not in the
  list** → the kext never matches → the chip never gets firmware.
- `BrcmPatchRAM3`/`BlueToolFixup` are configured for a **Broadcom** card, but
  there is no Broadcom in this machine → nothing to patch.
- Result: controller without firmware (`Firmware Version: v0 c0`, `Address: NULL`,
  `State: Off`) and `bluetoothd` in a crash loop.

## Evidence

### The controller is Intel, not Broadcom

```
$ ioreg -p IOUSB -l          # the BT device on the XHCI root hub
  idVendor  = 32903          # 0x8087 = Intel
  idProduct = 2010           # 0x07DA = old Intel combo-card BT (6235/2230 era)
  "Bluetooth HCI"
```

### system_profiler shows the phantom report

```
Bluetooth Controller:
    Address: NULL
    State: Off
    Chipset: BCM_4350C2      # phantom — the controller can't be identified
    Firmware Version: v0 c0   # no firmware was ever uploaded
    Vendor ID: 0x004C (Apple)
```

When a BT controller enumerates without firmware it cannot identify itself, and
`system_profiler`/`IOBluetoothFamily` default to a Broadcom-style name. That is
the origin of the "BCM_4350C2" claim in the older docs.

### IntelBluetoothFirmware does not support 0x07DA

`IOKitPersonalities` in the deployed kext (2.4.0):

```
0x0026 0x0032 0x0035 0x0036 0x0038  0x0A2A (3165) 0x0AA7 (3168)
0x07DC (7260) 0x0A2B (8265) 0x0025 (9260) 0x0AAA (9560)
0x0029 (AX200) 0x0033 (AX210)
```

`0x07DA` is absent → no personality matches → the kext does not load
(`kextstat` shows no `com.zxystd.IntelBluetoothFirmware`).

### BrcmPatchRAM3 has nothing to match

`BrcmPatchRAM3` (2.7.0) is a USB Broadcom firmware uploader. No Broadcom BT is
present on USB → it doesn't load either (`kextstat` shows
`as.acidanthera.BlueToolFixup` loaded, but no `as.acidanthera.BrcmPatchRAM3`).

### bluetoothd crash loop

```
/Library/Logs/DiagnosticReports/ExcUserFault_bluetoothd-*.ips
```

`bluetoothd` restarts every few minutes with `EXC_GUARD` / `GUARD_TYPE_USER` —
it cannot initialize the controller and faults.

## Why it can't be fixed in software

- `0x07DA` is not supported by any maintained Intel BT kext.
- There is no Broadcom device for `BrcmPatchRAM3` to patch.
- No amount of config/kext work changes the chip's hardware.

## Options if Bluetooth is ever wanted

| Option | Result |
|--------|--------|
| **Broadcom `BCM94352HMB` (DW1560)** — half mini-PCIe | Native AirPort + BT via the `BrcmPatchRAM3`/`BlueToolFixup` already in the config. Best compatibility (Airdrop/Handoff). Needs purchase (~R$150-250) |
| **Intel 7260** — half mini-PCIe, cheap | BT works via the `IntelBluetoothFirmware` already in the config; WiFi stays on `AirportItlwm`. ~R$40-60 |
| Keep the current card | BT stays dead; document (this page) |

Either swap requires no config change — both are already supported by the kexts
present in `EFI/OC/Kexts/`.

## Reducing the bluetoothd crash loop (while BT is dead)

1. **BIOS:** `Config → Network → Bluetooth → Disabled` on the T440p removes the
   USB BT device at the source — `bluetoothd` stops crashing. This is the
   cleanest option.
2. Otherwise the crash loop is harmless log/CPU noise: `bluetoothd` restarts
   every few minutes and never initializes anything.

# Production `config.plist` (OpenCore 1.0.4)

This is the `config.plist` **in production** (faithful copy from the EFI). The
tables and notes below serve as a quick reference; the actual file is next to this
README.

> ⚠️ **SMBIOS:** the serial/MLB/UUID here are fake placeholders. If you use this
> config, **generate your own** (iMac/OpenCore configurator or `Mac-Serial-Generator`)
> — identical serials across machines can break iMessage/FaceTime.

## Kexts (Kernel:Add)

| # | Kext | Enabled | Purpose |
|---|------|:-------:|---------|
| 0 | RealtekCardReader | ❌ | SD reader (disabled — boot/wake panics) |
| 1 | ACPIBatteryManager | ✅ | Battery readout |
| 2 | AirportItlwm | ✅ | Intel Wi-Fi |
| 3 | CodecCommander | ✅ | Audio wake/headset |
| 4 | IntelBluetoothFirmware | ✅ | Intel BT |
| 5 | IntelMausi | ✅ | Intel Ethernet |
| 6 | Lilu | ✅ | Base (patching) |
| 7 | USBMap | ✅ | USB port mapping |
| 8 | VirtualSMC | ✅ | SMC |
| 9 | VoodooPS2Controller | ✅ | PS2 keyboard/trackpad |
| 10 | WhateverGreen | ✅ | GPU |
| 11 | YogaSMC | ✅ | Function keys / sensors |
| 16 | AppleALC | ✅ | Audio |
| 17 | CpuTscSync | ✅ | TSC |
| 18 | FeatureUnlock | ✅ | AirPlay / Face ID unlock |
| 19 | HibernationFixup | ✅ | Hibernation |
| 20 | SMCProcessor | ✅ | CPU sensor |
| 21 | SMCSuperIO | ✅ | Fan / Super I/O |
| 22 | BlueToolFixup | ✅ | Broadcom BT |
| 23–26 | VoodooRMI (+PlugIns) | ✅ | Synaptics trackpad |
| 27 | CPUFriend | ✅ | CPU power profile |
| 28 | RestrictEvents | ✅ | Hide/handle events |
| 29 | BrcmPatchRAM3 | ✅ | Broadcom BT firmware |
| 31 | Sinetek-rtsx | ❌ | SD alternative (disabled — shutdown bug) |

> Index 30: empty dict (harmless residue). OpenCore ignores it.
> Both SD kexts stay in the `kexts/` folder, only disabled. To re-enable, set
> `Enabled=true` and, if using Sinetek, test with `rtsx_sleep_wake_delay_ms=1000`.

## ACPI (15 SSDTs)

`SSDT-ADPT` (adapter), `SSDT-ALS0` (ambient light), `SSDT-BATX` (battery),
`SSDT-DEHCI` (disables EHCI), `SSDT-ECRW` (EC), `SSDT-HPET`, `SSDT-KBD`,
`SSDT-LED`, `SSDT-MCHC`, `SSDT-PLUG` (XCPM), `SSDT-PNLF` (backlight),
`SSDT-PWRB`, `SSDT-SMBUS`, `SSDT-THINK` (ThinkPad), `SSDT-USBX` (USB power).

## Drivers (UEFI)

`OpenRuntime`, `OpenHfsPlus` (HFS+), `OpenCanopy` (GUI), `OpenLinuxBoot`,
`AudioDxe`, `FirmwareSettingsEntry`, `ResetNvramEntry`, `Ext4Dxe`, `OpenNtfsDxe`.

## Boot args (NVRAM)

```
keepsyms=1 amfi_get_out_of_my_way=1 revpatch=sbvmm
```

## Key quirks

- **Kernel:** `XhciPortLimit=true`, `DisableIoMapper=true`, `AppleXcpmCfgLock=true`,
  `PanicNoKextDump=true`, `DisableLinkeditJettison=true`.
- **Booter:** `AvoidRuntimeDefrag=true`, `ProvideCustomSlide=true`,
  `EnableWriteUnprotector=true`, `SetupVirtualMap=true`.
- **UEFI:** `RequestBootVarRouting=true`, `IgnoreInvalidFlexRatio=true`.

## Boot

- `ShowPicker=false`, `Timeout=0` → direct boot. **Esc** at power-on reaches the picker.
- `PickerVariant=Acidanthera\GoldenGate` (OpenCanopy).
- `HideAuxiliary=true`, `PickerMode=External`.

# Production `config.plist` (OpenCore 1.0.7 — Sequoia 15.7.9)

This is the `config.plist` **in production** (faithful copy from the EFI). The
tables and notes below serve as a quick reference; the actual file is next to this
README.

> ⚠️ **SMBIOS:** the serial/MLB/UUID here are fake placeholders. If you use this
> config, **generate your own** (iMac/OpenCore configurator or `Mac-Serial-Generator`)
> — identical serials across machines can break iMessage/FaceTime.

## Kexts (Kernel:Add)

| # | Kext | Enabled | Purpose |
|---|------|:-------:|---------|
| 0 | ACPIBatteryManager | ✅ | Battery readout |
| 1 | AirportItlwm | ✅ | Intel Wi-Fi (Sonoma build, `MaxKernel 23.9.9`) |
| 2 | AMFIPass | ✅ | Bypass AMFI so HD 4600 works with the OCLP graphics patch |
| 3 | IOSkywalkFamily | ✅ | Sequoia WiFi support (`MinKernel 24.0.0`) |
| 4 | IO80211FamilyLegacy | ✅ | Sequoia WiFi support (`MinKernel 24.0.0`) |
| 5 | AirportItlwm_Sequoia | ✅ | Intel Wi-Fi, Sequoia build (`MinKernel 24.0.0`) |
| 6 | CodecCommander | ✅ | Audio wake/headset |
| 7 | IntelBluetoothFirmware | ✅ | Intel BT |
| 8 | IntelMausi | ✅ | Intel Ethernet |
| 9 | Lilu | ✅ | Base (patching) |
| 10 | USBMap | ✅ | USB port mapping |
| 11 | VirtualSMC | ✅ | SMC |
| 12 | VoodooPS2Controller | ✅ | PS2 keyboard/trackpad |
| 13 | WhateverGreen | ✅ | GPU |
| 14 | YogaSMC | ✅ | Function keys / sensors |
| 15 | VoodooPS2…/VoodooInput | ❌ | Disabled plug-in (residue) |
| 16 | VoodooPS2…/VoodooPS2Keyboard | ✅ | PS2 keyboard |
| 17 | VoodooPS2…/VoodooPS2Mouse | ✅ | PS2 mouse |
| 18 | VoodooPS2…/VoodooPS2Trackpad | ✅ | PS2 trackpad |
| 19 | AppleALC | ✅ | Audio |
| 20 | CpuTscSync | ✅ | TSC |
| 21 | FeatureUnlock | ✅ | AirPlay / Face ID unlock |
| 22 | HibernationFixup | ✅ | Hibernation |
| 23 | SMCProcessor | ✅ | CPU sensor |
| 24 | SMCSuperIO | ✅ | Fan / Super I/O |
| 25 | BlueToolFixup | ✅ | Broadcom BT |
| 26 | VoodooRMI (+RMII2C/RMISMBus/VoodooInput) | ✅ | Synaptics trackpad |
| 30 | CPUFriend | ✅ | CPU power profile |
| 31 | RestrictEvents | ✅ | Hide/handle events |
| 32 | BrcmPatchRAM3 | ✅ | Broadcom BT firmware |
| 33 | RealtekCardReader | ❌ | SD reader — **disabled** (`Enabled=false`); kept only for the Path A test (`-rtsxnopm`) |
| 34 | VoltageShift | ✅ | Undervolting (managed in its own repo: `t440p-undervolt-control`) |

> The SD reader / Bluetooth / Broadcom kexts are loaded-but-inert on this machine:
> `RealtekCardReader` (33) is **disabled** because its power management panics on
> wake (see `03-sd-card-reader/`); `IntelBluetoothFirmware` (7), `BlueToolFixup`
> (25) and `BrcmPatchRAM3` (32) load but have **nothing to drive** — the stock BT
> chip (`0x07DA`) is unsupported. Index 15 is a disabled `VoodooInput` plug-in
> inside `VoodooPS2Controller` — harmless residue.

## ACPI (15 SSDTs)

`SSDT-ADPT` (adapter), `SSDT-ALS0` (ambient light), `SSDT-BATX` (battery),
`SSDT-DEHCI` (disables EHCI), `SSDT-ECRW` (EC), `SSDT-HPET`, `SSDT-KBD`,
`SSDT-LED`, `SSDT-MCHC`, `SSDT-PLUG` (XCPM), `SSDT-PNLF` (backlight),
`SSDT-PWRB`, `SSDT-SMBUS`, `SSDT-THINK` (ThinkPad), `SSDT-USBX` (USB power).

## Kernel:Block

```
com.apple.iokit.IOSkywalkFamily  (Allow IOSkywalk downgrade for Sequoia)
```

Blocks the system's Skywalk kext so the downgraded `IOSkywalkFamily` (shipped in
the EFI) loads — required for WiFi on Sequoia.

## Drivers (UEFI)

`OpenRuntime`, `OpenHfsPlus` (HFS+), `OpenCanopy` (GUI), `AudioDxe`,
`FirmwareSettingsEntry`, `ResetNvramEntry`.

> `OpenLinuxBoot.efi`, `Ext4Dxe.efi` and `OpenNtfsDxe.efi` were **removed** — they
> only extend the filesystem probe surface and slow the boot (see `04-direct-boot/`).

## Boot args (NVRAM)

```
keepsyms=1 revpatch=sbvmm -amfipassbeta amfi_get_out_of_my_way=1
```

- `-amfipassbeta` — required by `AMFIPass` 1.4.0; lets the HD 4600 work with the
  OCLP graphics patch.
- `revpatch=sbvmm` — fixes Software Update / OS selection in the App Store.
- `keepsyms` — keeps symbols in panics.
- `csr-active-config = 0x80003` (nvram `%03%08%00%00`) — root volume patchable
  (needed for the OCLP post-install patch and `-amfipassbeta`).

## Key quirks

- **Kernel:** `XhciPortLimit=true`, `DisableIoMapper=true`, `AppleXcpmCfgLock=true`,
  `PanicNoKextDump=true`, `DisableLinkeditJettison=true`.
- **Booter:** `AvoidRuntimeDefrag=true`, `ProvideCustomSlide=true`,
  `EnableWriteUnprotector=true`, `SetupVirtualMap=true`.
- **UEFI:** `RequestBootVarRouting=true`, `IgnoreInvalidFlexRatio=true`.

## Boot

- `ShowPicker=false`, `Timeout=0` → **direct boot**; hold **`Esc`** at power-on
  for the picker (`PollAppleHotKeys=true`). Set `ShowPicker=true` + a `Timeout` to
  bring the menu back during installs.
- `PickerVariant=Acidanthera\GoldenGate` (OpenCanopy).
- `HideAuxiliary=true`, `PickerMode=External`.

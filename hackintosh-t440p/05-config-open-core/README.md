# Config.plist do OpenCore (1.0.4)

Este é o `config.plist` **em produção** (cópia fiel da EFI). A tabela e os detalhes
abaixo servem como referência rápida; o arquivo real está ao lado deste README.

> ⚠️ **SMBIOS:** o serial/MLB/UUID aqui são valores fake gerados. Se você for usar
> este config, **gere os seus próprios** (iMac/OpenCore configurator ou
> `Mac-Serial-Generator`) — serial idêntico em máquinas diferentes pode quebrar o
> iMessage/FaceTime.

## Kexts (Kernel:Add)

| # | Kext | Enabled | Função |
|---|------|:-------:|--------|
| 0 | RealtekCardReader | ❌ | Leitor SD (desativado — panic de boot/wake) |
| 1 | ACPIBatteryManager | ✅ | Leitura da bateria |
| 2 | AirportItlwm | ✅ | WiFi Intel |
| 3 | CodecCommander | ✅ | Wake/headset do áudio |
| 4 | IntelBluetoothFirmware | ✅ | BT Intel |
| 5 | IntelMausi | ✅ | Ethernet Intel |
| 6 | Lilu | ✅ | Base (patch) |
| 7 | USBMap | ✅ | Mapa de portas USB |
| 8 | VirtualSMC | ✅ | SMC |
| 9 | VoodooPS2Controller | ✅ | Teclado/trackpad PS2 |
| 10 | WhateverGreen | ✅ | GPU |
| 11 | YogaSMC | ✅ | Teclas de função/sensores |
| 16 | AppleALC | ✅ | Áudio |
| 17 | CpuTscSync | ✅ | TSC |
| 18 | FeatureUnlock | ✅ | AirPlay/Face ID unlock |
| 19 | HibernationFixup | ✅ | Hibernação |
| 20 | SMCProcessor | ✅ | Sensor CPU |
| 21 | SMCSuperIO | ✅ | Ventoinha/super I/O |
| 22 | BlueToolFixup | ✅ | BT Broadcom |
| 23–26 | VoodooRMI (+PlugIns) | ✅ | Trackpad Synaptics |
| 27 | CPUFriend | ✅ | Perfil de CPU |
| 28 | RestrictEvents | ✅ | Ocultar eventos |
| 29 | BrcmPatchRAM3 | ✅ | Firmware BT Broadcom |
| 31 | Sinetek-rtsx | ❌ | SD alternativo (desativado — bug shutdown) |

> Índice 30: dict vazio (resíduo inofensivo). O OpenCore ignora.
> Ambas as kexts de SD ficam na pasta `kexts/`, só desabilitadas — para reativar,
> mudar `Enabled=true` e (se for Sinetek) testar com `rtsx_sleep_wake_delay_ms=1000`.

## ACPI (15 SSDTs)

`SSDT-ADPT` (adapter), `SSDT-ALS0` (luz ambiente), `SSDT-BATX` (bateria),
`SSDT-DEHCI` (desliga EHCI), `SSDT-ECRW` (EC), `SSDT-HPET`, `SSDT-KBD`,
`SSDT-LED`, `SSDT-MCHC`, `SSDT-PLUG` (XCPM), `SSDT-PNLF` (brilho),
`SSDT-PWRB`, `SSDT-SMBUS`, `SSDT-THINK` (ThinkPad), `SSDT-USBX` (USB power).

## Drivers (UEFI)

`OpenRuntime`, `OpenHfsPlus` (HFS+), `OpenCanopy` (GUI), `OpenLinuxBoot`,
`AudioDxe`, `FirmwareSettingsEntry`, `ResetNvramEntry`, `Ext4Dxe`, `OpenNtfsDxe`.

## boot-args (NVRAM)

```
keepsyms=1 amfi_get_out_of_my_way=1 revpatch=sbvmm
```

## Quirks principais

- **Kernel:** `XhciPortLimit=true`, `DisableIoMapper=true`, `AppleXcpmCfgLock=true`,
  `PanicNoKextDump=true`, `DisableLinkeditJettison=true`.
- **Booter:** `AvoidRuntimeDefrag=true`, `ProvideCustomSlide=true`,
  `EnableWriteUnprotector=true`, `SetupVirtualMap=true`.
- **UEFI:** `RequestBootVarRouting=true`, `IgnoreInvalidFlexRatio=true`.

## Boot

- `ShowPicker=false`, `Timeout=0` → boot direto. Picker em **Esc** ao ligar.
- `PickerVariant=Acidanthera\GoldenGate` (OpenCanopy).
- `HideAuxiliary=true`, `PickerMode=External`.

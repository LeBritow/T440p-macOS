# Credits

This build would not exist without the open-source projects and volunteers below.
Every kext, driver and tool used is listed with its author(s). If your project is
used here and you are not credited, open an issue and it will be fixed.

## Projects

| Project | Author(s) | Used for |
|---------|-----------|----------|
| [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg) | Acidanthera | Bootloader (1.0.7) |
| [Lilu](https://github.com/acidanthera/Lilu) | Acidanthera | Base patching framework |
| [WhateverGreen](https://github.com/acidanthera/WhateverGreen) | Acidanthera | GPU (HD 4600) |
| [VirtualSMC](https://github.com/acidanthera/VirtualSMC) | Acidanthera | SMC emulation |
| [AppleALC](https://github.com/acidanthera/AppleALC) | Acidanthera | Audio (Realtek ALC) |
| [IntelMausi](https://github.com/acidanthera/IntelMausi) | Acidanthera | Ethernet (I217-V) |
| [CpuTscSync](https://github.com/acidanthera/CpuTscSync) | Acidanthera | TSC sync |
| [FeatureUnlock](https://github.com/acidanthera/FeatureUnlock) | Acidanthera | AirPlay to Mac / unlock features |
| [HibernationFixup](https://github.com/acidanthera/HibernationFixup) | Acidanthera | Hibernation |
| [CPUFriend](https://github.com/acidanthera/CPUFriend) | Acidanthera | CPU power profile |
| [RestrictEvents](https://github.com/acidanthera/RestrictEvents) | Acidanthera | Event hiding/handling |
| [BlueToolFixup](https://github.com/acidanthera/BrcmPatchRAM) | Acidanthera | Broadcom BT (loaded; **no Broadcom present — BT is dead**, see `08-bluetooth/`) |
| [BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) | Acidanthera | Broadcom BT firmware (kept for a future Broadcom card) |
| [AMFIPass](https://github.com/ic005k/OpenCore-Mod) | ic005k / community | Bypass AMFI + `-amfipassbeta` (lets the OCLP graphics patch work on Sequoia) |
| [AirportItlwm](https://github.com/OpenIntelWireless/itlwm) | OpenIntelWireless | Intel Wi-Fi (Sequoia build, native AirPort after OCLP patch) |
| [IOSkywalkFamily](https://github.com/OpenIntelWireless/itlwm) | OpenIntelWireless | Sequoia WiFi support (downgraded build, `Kernel.Block`) |
| [IO80211FamilyLegacy](https://github.com/OpenIntelWireless/itlwm) | OpenIntelWireless | Legacy IO80211 stack for Sequoia WiFi |
| [OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher) | Dortania | Post-install root patch → native AirPort **and** HD 4600 graphics (Sonoma) |
| [OCLP-Mod](https://github.com/laobamac/OCLP-Mod) | laobamac | OCLP fork **required on Sequoia** — the standard OCLP does not patch Sequoia properly |
| [IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware) | OpenIntelWireless | Intel BT — **no personality for the stock `0x07DA` radio** (see `08-bluetooth/`) |
| [VoodooPS2](https://github.com/acidanthera/VoodooPS2) | acidanthera / VoodooProjects | PS2 keyboard/trackpad |
| [VoodooRMI](https://github.com/VoodooProjects/VoodooRMI) | VoodooProjects | Synaptics trackpad (RMI I2C/SMBus) |
| [ACPIBatteryManager](https://github.com/RehabMan/OS-X-ACPI-Battery-Driver) | RehabMan | Battery readout |
| [CodecCommander (fork)](https://github.com/RehabMan/EAPD-Codec-Commander) | RehabMan | Audio wake/headset |
| [EAPD-Codec-Commander (original)](https://github.com/Dolnor/EAPD-Codec-Commander) | Dolnor (with the-darkvoid) | Original codec commander |
| CodecCommander (contributions) | Sniki (et al.) | Power-management fixes |
| [YogaSMC](https://github.com/zhen-zen/YogaSMC) | zhen-zen | Function keys / sensors (ThinkPad) |
| [USBMap](https://github.com/corpnewt/USBMap) | corpnewt | USB port mapping |
| [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) | corpnewt | SMBIOS generation |
| [RealtekCardReader](https://github.com/0xFireWolf/RealtekCardReader) | 0xFireWolf | SD reader (disabled — panics) |
| [Sinetek-rtsx](https://github.com/cholonam/Sinetek-rtsx) | cholonam | SD reader (disabled — shutdown bug) |
| [Stats](https://github.com/exelban/stats) | exelban | System monitoring (CPU/RAM/temps) |
| [Dortania / OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/) | Dortania | Canonical installation/reference docs |

## Base EFI

| Project | Author(s) | Used for |
|---------|-----------|----------|
| [t440p-hackintosh-efi-collection](https://github.com/Tulugaak/t440p-hackintosh-efi-collection) | Tulugaak | Base EFI this build started from (OpenCore 1.0.4) |
| ACPI patches (in the collection) | [valnoxy](https://github.com/valnoxy) | SSDTs (battery, power, ThinkPad, etc.) |

> The collection's Sonoma EFIs ship with **both** AirportItlwm builds (14.0–14.3.1
> and 14.4+); the SD reader is not supported by its author either. SMBIOS guidance
> (`MacBookPro16,1` for Sonoma, `MacBookPro14,1` for Ventura) matches what was used here.

## Special mentions

- **Acidanthera** also maintains the OpenCore documentation and the whole kext
  ecosystem that makes modern Hackintoshes possible — the biggest single
  contribution to this project.
- The **SD reader fix research** (`rtsx_sleep_wake_delay_ms=1000`) comes from the
  Sinetek-rtsx release notes, confirmed by users of the T440S/X240 (same RTS5227 chip).
- The **EHCI diagnosis** follows the conclusions of the community that the USB 2.0
  driver was removed by Apple in macOS 14 — documented for anyone facing the same.

## Tools used in this documentation

`macrecovery.py` (from OpenCorePkg, included under `scripts/`), `plutil` (built-in),
`ioreg`, `kextstat`, `stat`, `fsck_msdos`, OpenCore `Configurator`-style manual plist
editing, and the `timeout`/`date` utilities. GenSMBIOS was used to generate the
placeholder SMBIOS values.

---

*If you maintain one of these projects: thank you. This laptop runs macOS
completely thanks to your work.*

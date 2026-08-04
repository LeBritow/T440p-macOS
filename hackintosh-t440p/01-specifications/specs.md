# ThinkPad T440p — System Specifications

> Collected from the running system (`system_profiler`, `sysctl`, `nvram`).
> The SMBIOS is spoofed to `MacBookPro16,1`, which is what macOS reports.

## Hardware

| Component | Model | Notes |
|-----------|-------|-------|
| CPU | Intel Core i7-4700MQ @ 2.40 GHz | 4 cores / 8 threads (Haswell) |
| iGPU | Intel HD Graphics 4600 | 1536 MB dynamic VRAM, Metal 2 |
| Memory | 16 GB | |
| Storage | 240 GB SATA SSD | GUID partition, APFS (Container `disk1`) |
| Wi-Fi | Intel (802.11 a/b/g/n) | e.g. Centrino Wireless-N 7260 |
| Bluetooth | Broadcom BCM_4350C2 | Identified as Apple (0x004C) |
| Ethernet | Intel (I217-V) | |
| Audio | Realtek ALC (integrated) | `AppleALC` + `CodecCommander` |
| SD reader | Realtek RTS5227 | `pci10ec,5227` — left side |
| Keyboard / trackpad | PS2 + Synaptics RMI | `VoodooPS2` + `VoodooRMI` |
| Battery | 6-cell (973 cycles) | Condition: *Service Recommended* |

## USB architecture (relevant to the dead-port issue)

The Haswell chipset exposes **two USB controllers** in the DSDT:

- **XHCI** — `pci8086,8c31` / `pciclass,0c0330` — the USB 3.0 ports and most 2.0 ports.
- **EHCI** — `EHC1@1d0000` — legacy USB 2.0 ports (one of them is **dead** on macOS).

Ports mapped in the USBMap kext:

| USBMap port | Register | Physical name |
|-------------|----------|---------------|
| HS01 | 3 | Top Right |
| HS02 | 6 | Bottom Right |
| HS03 | 255 (BT) | Bluetooth |
| HS04 | — | Webcam |
| SS01 | 0x10 | Top Left USB 3.0 |
| SS02 | 0x11 | Bottom Left USB 3.0 |

Actual XHCI ports present at runtime (from `ioreg`): `HSP2@3`, `HSP5@6`, `HSPA@b`,
`HSPB@c`. Registers 1 and 2 **do not exist** on the XHCI controller.

## Software

| Item | Value |
|------|-------|
| macOS | 14.8.8 (Sonoma, build `23J620`) |
| OpenCore | REL-104-2025-03-04 (**1.0.4**) |
| SMBIOS | `MacBookPro16,1` |
| Boot args | `keepsyms=1 amfi_get_out_of_my_way=1 revpatch=sbvmm` |

## EFI layout

- EFI at `/Volumes/EFI/EFI/OC` (msdos/FAT32 partition `disk0s1`, 209 MB).
- Boot picker disabled (`ShowPicker=false`, `Timeout=0`) — boots straight to macOS.
- Hold **Esc** at power-on to reach the picker.

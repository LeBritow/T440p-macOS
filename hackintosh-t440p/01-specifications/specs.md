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
| Wi-Fi | Intel Centrino 6235 (802.11 a/b/g/n) | `AirportItlwm_Sequoia` |
| Bluetooth | Intel `0x8087:0x07DA` (combo-card radio) | **Unsupported, dead** — see [08-bluetooth/](../08-bluetooth/) |
| Ethernet | Intel (I217-V) | |
| Audio | Realtek ALC (integrated) | `AppleALC` + `CodecCommander` |
| SD reader | Realtek RTS5227 | `pci10ec,5227` — left side |
| Keyboard / trackpad | PS2 + Synaptics RMI | `VoodooPS2` + `VoodooRMI` |
| Battery | 6-cell (973 cycles) | Condition: *Service Recommended* |

## USB architecture (relevant to the dead-port issue)

The Haswell chipset exposes **two USB controllers** in the DSDT:

- **XHCI** — `pci8086,8c31` / `pciclass,0c0330` — the USB 3.0 ports and most 2.0 ports.
- **EHCI** — `EHC1@1d0000` — legacy USB 2.0 ports (one of them is **dead** on macOS).

Ports mapped in the USBMap kext (production):

| USBMap port | Register | Connector | Physical name |
|-------------|----------|-----------|---------------|
| HS01 | 6 | USB 2.0 | Top Right |
| HS02 | 3 | USB 2.0 | Bottom Right |
| HS03 | 11 | Internal | Bluetooth |
| HS04 | 12 | Internal | Webcam |
| HS05 | 1 | USB 2.0 | Top Left (added during investigation) |
| HS06 | 2 | USB 2.0 | Bottom Left (added during investigation) |
| SS01 | 0x10 | USB 3.0 | Top Left |
| SS02 | 0x11 | USB 3.0 | Bottom Left |

Actual XHCI ports present at runtime (from `ioreg`): `HSP2@3`, `HSP5@6`, `HSPA@b`,
`HSPB@c`. **HS05/HS06 (registers 1 and 2) were added to the USBMap during the
dead-port investigation — they do not exist on the XHCI controller**, which is how
the dead port was identified as EHCI (see `02-dead-usb-port/`).

## Software

| Item | Value |
|------|-------|
| macOS | 15.7.8 (Sequoia, build `24G824`) |
| OpenCore | REL-107-2025-06-26 (**1.0.7**) |
| SMBIOS | `MacBookPro16,1` |
| SIP / CSR | `csr-active-config = 0x80003` (nvram: `%03%08%00%00`) |
| Boot args | `keepsyms=1 revpatch=sbvmm -amfipassbeta amfi_get_out_of_my_way=1` |

## EFI layout

- EFI at `/Volumes/EFI/EFI/OC` (msdos/FAT32 partition `disk0s1`, 209 MB).
- Boot picker shown (`ShowPicker=true`, `Timeout=5`) — select **macOS** to boot.
- Snapshot of this EFI (placeholder SMBIOS): [`../efi-sequoia-15.7.8/`](../efi-sequoia-15.7.8/).

## Sequoia-specific kext set

The working Sequoia build (OC 1.0.7) loads 33 kexts. Key ones for Sequoia:

| Kext | Notes |
|------|-------|
| `AirportItlwm_Sequoia.kext` | Sequoia build of IntelWiFi — `MinKernel 24.0.0`; native AirPort after the OCLP post-install patch |
| `AirportItlwm.kext` | Sonoma build kept with `MaxKernel 23.9.9` (fallback, unused on Sequoia) |
| `IOSkywalkFamily.kext` / `IO80211FamilyLegacy.kext` | Required by the Sequoia WiFi kext (`MinKernel 24.0.0`) |
| `AMFIPass.kext` | 1.4.0 — needs `-amfipassbeta`; enables GPU acceleration on Haswell (which OCLP then patches) |
| `BrcmPatchRAM3.kext` | Broadcom firmware uploader (with `BlueToolFixup`) |
| `Kernel.Block` | `com.apple.iokit.IOSkywalkFamily` blocked so the downgraded kext loads on Sequoia |

Full reference: [`../05-open-core-config/`](../05-open-core-config/).

# Especificações — ThinkPad T440p Hackintosh

> Coletadas do próprio sistema rodando (`system_profiler`, `sysctl`, `nvram`).
> SMBIOS fake de `MacBookPro16,1` (o macOS enxerga a máquina como esse modelo).

## Hardware físico

| Componente  | Modelo | Observação |
|-------------|--------|------------|
| CPU         | Intel Core i7-4700MQ @ 2.40 GHz | 4 núcleos / 8 threads (Haswell) |
| GPU         | Intel HD Graphics 4600 | VRAM dinâmica 1536 MB, Metal 2 |
| Memória     | 16 GB | |
| Disco       | SSD SATA 240 GB | Particionado GUID, APFS (Container `disk1`) |
| WiFi        | Intel (802.11 a/b/g/n) | Ex.: Centrino Wireless-N 7260 |
| Bluetooth   | Broadcom BCM_4350C2 | Identificado como Apple (0x004C) |
| Ethernet    | Intel (I217-V) | |
| Áudio       | Realtek ALC (Integrado) | `AppleALC` + `CodecCommander` |
| Leitor SD   | Realtek RTS5227 | `pci10ec,5227` — lado esquerdo |
| Teclado/trackpad | PS2 + Synaptics RMI | `VoodooPS2` + `VoodooRMI` |
| Bateria     | 6-cell (973 ciclos) | Condição: *Service Recommended* |

## USB (importante para o problema da porta morta)

O chipset (8-series Haswell) tem **dois controladores USB** no DSDT:

- **XHCI** — `pci8086,8c31` / `pciclass,0c0330` — as portas USB 3.0 e a maioria das 2.0.
- **EHCI** — `EHC1@1d0000` — portas USB 2.0 legadas (uma fica **morta** no macOS).

Portas ativas mapeadas no USBMap (via `USBToolBox`/`USBMap`):

| Porta USBMap | Register | Nome físico |
|--------------|----------|-------------|
| HS01 | 3 | Top Right |
| HS02 | 6 | Bottom Right |
| HS03 | 255 (BT) | Bluetooth |
| HS04 | — | Webcam |
| SS01 | 0x10 | Top Left USB 3.0 |
| SS02 | 0x11 | Bottom Left USB 3.0 |

Portas reais do XHCI rodando (do `ioreg`): `HSP2@3`, `HSP5@6`, `HSPA@b`, `HSPB@c`.
As portas de register 1 e 2 **não existem** no XHCI.

## Software

| Item | Valor |
|------|-------|
| macOS | 14.8.8 (Sonoma, build `23J620`) |
| OpenCore | REL-104-2025-03-04 (**1.0.4**) |
| SMBIOS | `MacBookPro16,1` |
| boot-args | `keepsyms=1 amfi_get_out_of_my_way=1 revpatch=sbvmm` |

## Arquitetura do EFI

- EFI em `/Volumes/EFI/EFI/OC` (partição msdos/FAT32 `disk0s1`, 209 MB).
- Picker desativado (`ShowPicker=false`, `Timeout=0`) — boot direto ao logo da Apple.
- Se preciso do menu: segurar **Esc** no ligar.

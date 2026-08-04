# T440p Hackintosh — macOS 14.8.8 (Sonoma) via OpenCore

Hackintosh de um **Lenovo ThinkPad T440p** rodando **macOS 14.8.8 (Sonoma, build 23J620)**
com **OpenCore 1.0.4**. Documentação **real, verificada na máquina**, dos problemas
encontrados e suas soluções — para quem tem o mesmo notebook (ou chipset Haswell/8-series).

> ⚠️ **SMBIOS:** os dados de SMBIOS neste repo são **placeholders** (`AAAAAAAA...`).
> Gere os **seus** valores com GenSMBIOS antes de usar — serial público causa
> blacklist de iMessage/FaceTime.

## Estado atual da máquina

| Componente | Status |
|-----------|--------|
| Boot | Direto ao logo (picker desativado; **Esc** no ligar volta ao menu) |
| WiFi / BT / Ethernet / Áudio | ✅ Funcionando |
| Porta USB traseira esquerda | 🔌 **Morta** — é EHCI, driver removido no macOS 14 (sem solução) |
| Leitor de cartão SD (RTS5227) | 🔇 **Desativado** — as 2 kexts causavam panic de boot/wake/shutdown |
| Teclado ABNT2 (`?`→`/`) | ✅ Remapeado em userspace (ver `remap-teclado/`) |

## Especificações

ThinkPad **T440p** · Core **i7-4700MQ** · **HD 4600** (Metal 2) · **16 GB** RAM ·
SSD **240 GB** SATA/APFS · WiFi **Intel** · BT **Broadcom BCM_4350C2** ·
SMBIOS `MacBookPro16,1` · boot-args `keepsyms=1 amfi_get_out_of_my_way=1 revpatch=sbvmm`.

Detalhes: [`hackintosh-t440p/01-especificacoes/`](hackintosh-t440p/01-especificacoes/especificacoes.md)

## Problemas documentados (com diagnóstico e solução)

| Problema | Status | Onde |
|----------|--------|------|
| Porta USB traseira esquerda morta (EHCI, sem driver no Sonoma) | 🚫 Sem solução | [`02-porta-usb-morta/`](hackintosh-t440p/02-porta-usb-morta/) |
| Leitor SD (panic de boot/wake/shutdown) — saga completa + research de fix | 🔇 Desativado | [`03-leitor-sd/`](hackintosh-t440p/03-leitor-sd/) |
| Boot direto (ShowPicker=false) + conserto EFI `dirty` | ✅ | [`04-boot-direto/`](hackintosh-t440p/04-boot-direto/) |
| config.plist em produção + referência de kexts/quirks | ✅ | [`05-config-open-core/`](hackintosh-t440p/05-config-open-core/) |
| EFI completa que funcionava no Sonoma (snapshot) | ✅ | [`efi-sonoma-14.8.8/`](hackintosh-t440p/efi-sonoma-14.8.8/) |
| Teclado ABNT2 — `?`/`/`, `'`/`\`, Delete contextual, Cmd+Tab | ✅ | [`remap-teclado/`](remap-teclado/README.md) |

## Lições aprendidas (valem ouro)

1. **Sempre `config.plist.bak-<data>` antes de mexer no config.** Um backup salvou o
   boot quando o USBInjectAll travou a máquina.
2. **Kexts USB antigas (USBInjectAll 0.8.1) quebram o boot no Sonoma.** Evitar.
3. **Não brigue com EHCI no macOS 14** — driver removido pela Apple; até o caminho
   do OCLP panika. Porta USB 2.0 legada não tem solução.
4. **Leitor SD Realtek no Sonoma é casca de banana:** panic no boot, no wake e no
   shutdown. Nenhuma kext ficou estável → desativado.
5. **EFI FAT fica `dirty` com desligamento sujo** — se a EFI não montar:
   `sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1`.

## Estrutura

```
EFI/                     EFI (OpenCore) — placeholders de SMBIOS
scripts/                 Utilitários de download da recovery (macrecovery)
hackintosh-t440p/        Documentação completa deste projeto
  ├── 01-especificacoes/
  ├── 02-porta-usb-morta/
  ├── 03-leitor-sd/
  ├── 04-boot-direto/
  ├── 05-config-open-core/
  └── efi-sonoma-14.8.8/   snapshot do EFI funcional (Sonoma)
remap-teclado/           Remapeador do teclado ABNT2 (C + LaunchAgent)
```

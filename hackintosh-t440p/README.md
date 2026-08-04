# Hackintosh ThinkPad T440p — Problemas e Soluções

Documentação de **problemas reais resolvidos (e aceitos)** num ThinkPad T440p rodando
macOS **14.8.8 (Sonoma)** com **OpenCore 1.0.4** — para quem tem o mesmo notebook (ou
o mesmo chipset Haswell/8-series) e os mesmos sintomas.

## Resumo

| Problema | Status | Solução |
|----------|--------|---------|
| [Porta USB traseira esquerda morta](02-porta-usb-morta/) | 🚫 **Sem solução** | É **EHCI**; macOS 14 removeu o driver. Porta aceita como morta |
| [Leitor de cartão SD (RTS5227)](03-leitor-sd/) | 🔇 **Desativado** | As duas kexts panikavam (boot **e** wake). Ver research de fix no Sinetek |
| [Boot direto ao logo (sem menu)](04-boot-direto/) | ✅ Aplicado | `ShowPicker=false`, `Timeout=0`; menu com **Esc** |
| [EFI não monta (FAT dirty)](04-boot-direto/) | ✅ Conserto manual | `sudo fsck_msdos -y /dev/rdisk0s1` |
| Config.plist completo | — | [05-config-open-core/](05-config-open-core/) |

## Specs rápidas

ThinkPad **T440p** · Core **i7-4700MQ** · **HD 4600** (Metal 2) · **16 GB** RAM ·
SSD **240 GB** SATA/APFS · WiFi **Intel** · BT **Broadcom BCM_4350C2** ·
Leitor SD **Realtek RTS5227** · SMBIOS `MacBookPro16,1` · macOS 14.8.8 (23J620).

Detalhes completos: [01-especificacoes/](01-especificacoes/especificacoes.md)

## Lições aprendidas (vale ouro)

1. **Sempre `config.plist.bak-<data>` antes de mexer no config.** Foi o backup que
   salvou o boot quando o USBInjectAll travou a máquina.
2. **Kexts USB antigas (USBInjectAll 0.8.1) quebram o boot no Sonoma.** Evitar.
3. **Não vale a pena brigar com EHCI no macOS 14.** Driver removido pela Apple;
   até o caminho do OCLP panika. Aceita a porta morta e segue a vida.
4. **Leitor SD realtek no Sonoma é uma casca de banana:** RealtekCardReader panika
   no boot com cartão **e** no wake do sleep (mesmo sem cartão); Sinetek tem bug de
   shutdown. Desativamos as duas.
5. **EFI FAT fica `dirty` com desligamentos sujos** — se a EFI não montar, rodar o
   `fsck_msdos` manual (ver [04-boot-direto](04-boot-direto/)).

## Estrutura

```
hackintosh-t440p/
  01-especificacoes/      specs do notebook (coletadas do sistema)
  02-porta-usb-morta/     diagnóstico EHCI + SSDT-DEHCI.aml + tentativa USBInjectAll
  03-leitor-sd/           saga RealtekCardReader vs Sinetek-rtsx + protocolo
  04-boot-direto/         ShowPicker=false + conserto do EFI dirty
  05-config-open-core/    config.plist em produção + referência de kexts/quirks
```

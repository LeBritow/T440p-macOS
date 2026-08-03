# t440p-hackintosh-sonoma

Hackintosh de um **Lenovo ThinkPad T440p** com macOS usando **OpenCore**.

> Status: em construção. EFI disponível, porém os passos de instalação,
> configuração de BIOS e pós-instalação ainda precisam ser **verificados
> e documentados na máquina real**.

## Aviso

Os dados de SMBIOS no `Config.plist` são **placeholders** (`AAAAAAAA...`).
Gere os **seus** valores com GenSMBIOS antes de instalar — usar serial
público pode causar blacklist de iMessage/FaceTime.

## Estrutura

```
EFI/       EFI (OpenCore) — placeholders de SMBIOS
scripts/   Utilitários de download da recovery
```

## Pendência: verificar no T440p

- Opções de BIOS existentes (SATA/AHCI, Secure Boot, UEFI Only, etc.)
- Passos de preparo do pendrive
- Pós-instalação (OCLP para a Intel HD 4600)

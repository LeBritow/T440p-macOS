# t440p-hackintosh-sonoma

Hackintosh de um **Lenovo ThinkPad T440p** com **macOS Sonoma** usando **OpenCore**.

> **Aviso importante:** os dados de SMBIOS no `Config.plist` deste repositório são **placeholders** (`AAAAAAAA...`). Gere os **seus** valores com GenSMBIOS e preencha antes de instalar — usar serial público pode causar blacklist de iMessage/FaceTime.

## Hardware

| Componente | Modelo |
|---|---|
| CPU | Intel Core i7-4700MQ (Haswell) |
| GPU | Intel HD Graphics 4600 |
| RAM | 16 GB DDR3L |
| SSD | 256 GB SATA |
| Rede | Intel Wireless-AC 7260 (Wi-Fi + BT) |
| Áudio | Realtek ALC292 |

## Versões

| Item | Versão |
|---|---|
| macOS | Sonoma 14.x (último via Recovery) |
| OpenCore | 1.0.4 |
| SMBIOS | MacBookPro16,1 |
| OCLP | Pós-instalação (para a Intel HD 4600) |

## Pré-requisitos

- Windows como máquina de preparação
- Pendrive de **no mínimo 8 GB** (FAT32)
- Acesso ao repositório original: [Tulugaak/t440p-hackintosh-efi-collection](https://github.com/Tulugaak/t440p-hackintosh-efi-collection)

## BIOS (T440p)

Obrigatórios:

| Setting | Valor |
|---|---|
| Config → Serial ATA → Mode | `AHCI` |
| Security → Secure Boot | `Disabled` |
| Security → Security Chip (TPM) | `Disabled` |
| Startup → UEFI/Legacy Boot | `UEFI Only` |
| Startup → CSM Support | `No` |

Recomendados:

| Setting | Valor |
|---|---|
| Startup → Fast Boot | `Disabled` |
| Config → CPU → Hyper-Threading | `Enabled` |
| Security → Memory Protection → Execution Prevention | `Enabled` |
| Config → Power → Intel SpeedStep | `Enabled` |

> VT-d e CFG Lock **não** precisam ser desabilitados no BIOS: o `Config.plist` já usa `DisableIoMapper=true` e `AppleXcpmCfgLock=true`.

## Preparando o pendrive (Windows)

```powershell
# 1. Baixar a recovery do Sonoma (executa em Utilities/macrecovery.py)
python macrecovery.py -b Mac-42FD25EABCABB274 -m 00000000000000000 download

# 2. Formatar o pendrive como FAT32 (disco do pendrive, ex.: 1)
Get-Partition -DiskNumber 1 | Where-Object Type -eq Basic | Format-Volume -FileSystem FAT32 -NewFileSystemLabel INSTALL

# 3. Copiar para a raiz do pendrive
Copy-Item ".\com.apple.recovery.boot" "E:\" -Recurse
Copy-Item ".\EFI" "E:\" -Recurse
```

> Se o download cair, use `scripts/resume_download.py` (retoma com AssetToken + Range e verifica a imagem).

## Gerando seu SMBIOS (config.plist)

```powershell
# Baixe o OpenCore release e use o macserial incluído
macserial.exe -a MacBookPro16,1 -n 3
```

Edite em `EFI/OC/Config.plist` → `PlatformInfo → Generic`:

| Chave | Valor |
|---|---|
| `SystemProductName` | `MacBookPro16,1` |
| `SystemSerialNumber` | (seu serial) |
| `MLB` | (seu board serial) |
| `SystemUUID` | (seu UUID) |
| `ROM` | (seu MAC, base64 — ex.: do adaptador Ethernet cabeado) |

Valide o plist após editar:

```powershell
python -c "import plistlib; plistlib.load(open('Config.plist','rb'))"
```

## Pós-instalação

1. Instale o macOS normalmente.
2. Rode o **OpenCore Legacy Patcher (OCLP)** — necessário para a Intel HD 4600 no Sonoma.
3. Ajuste o `ROM` no `Config.plist` para o MAC real do T440p (opcional, mas recomendado para iMessage).

## Problemas conhecidos

- Leitor de cartão SD não funciona (limitação do Haswell/Apple).
- etc

## Créditos

- [Tulugaak](https://github.com/Tulugaak/t440p-hackintosh-efi-collection) — EFI base
- [acidanthera](https://github.com/acidanthera) — OpenCore e kexts
- [Dortania](https://dortania.github.io) — guias e `macrecovery.py`
- [OCLP](https://github.com/dortania/OpenCore-Legacy-Patcher) — patches pós-instalação

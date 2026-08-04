# Boot direto ao logo da Apple (picker desativado)

**Status: APLICADO.** O OpenCore pula o boot menu e vai direto ao macOS.

## O que foi mudado no `config.plist`

```
Misc → Boot → ShowPicker = false
Misc → Boot → Timeout    = 0
```

## Como voltar ao menu de boot

- **Segurar `Esc`** ao ligar/reiniciar.
- Ou, para reverter de vez: voltar `ShowPicker=true` e `Timeout` para alguns segundos.

## Problema recorrente: EFI "suja" (FAT dirty) não monta

Desligamentos sujos (a cada reboot que não passa por shutdown limpo) marcam a
partição EFI (FAT) como `dirty`, e aí o `diskutil mount disk0s1` falha:

```
Volume on disk0s1 failed to mount
If you think the volume is supported but damaged, try the "readOnly" option
```

### Conserto manual (usado sempre que precisar mexer no EFI)

```bash
sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1
```

> Não dá para `sudo` em sessão automatizada; o usuário roda isso no Terminal.

## Boa prática antes de mexer no config.plist

Sempre copiar um backup antes de editar:

```bash
cp config.plist config.plist.bak-$(date +%Y%m%d-%H%M%S)
```

Foi isso que salvou o sistema quando o USBInjectAll quebrou o boot — restauramos o
último backup bom e a máquina voltou a ligar.

# Porta USB morta (traseira esquerda) — Diagnóstico: EHCI, sem solução no Sonoma

**Status: SEM SOLUÇÃO.** A porta é controlada pelo **EHCI**, driver que o macOS 14 removeu. Aceito como limitação do hardware.

## O problema

- A porta USB **traseira esquerda** (abaixo do leitor SD) não funciona: pendrive não acende LED e não enumera.
- A porta **traseira direita** (Always-On, ícone de bateria) funciona normalmente.
- Leitor SD e a porta morta ficam do **mesmo lado** (esquerdo).

## Hipóteses testadas (em ordem)

### 1. A porta era XHCI mal mapeada? ❌
O `USBMap` só tinha 6 portas ativas (HSP2@3, HSP5@6, HSPA@b, HSPB@c). Adicionamos
`HS05` (reg `01000000`) e `HS06` (reg `02000000`) como "Top/Bottom Left USB 2.0".
**Resultado:** as portas 1 e 2 **não existem** no controlador XHCI (conferido no `ioreg`)
→ a porta morta **não é** XHCI.

### 2. A porta era EHCI e o driver foi removido? ✅ (conclusão)
- O DSDT define `EHC1@1d0000` (EHCI), mas no sistema rodando **só existe o XHCI** no `ioreg`.
- O macOS 14 **removeu o driver EHCI** (`IOUSBFamily`/AppleUSBEHCI não existe mais).
- O `SSDT-DEHCI.aml` desliga o EHCI via `_INI` (strings `EH1D`/`EH2D`/`Darwin`) —
  quem instalou o OpenCore já tinha desativado o controlador de propósito.

### 3. Tentativa com USBInjectAll — ⚠️ QUEBROU O BOOT
- Baixamos `USBInjectAll 0.8.1` (kext antiga, época Big Sur/Monterey).
- Ativamos no config + `USBMap` desativado + `XhciPortLimit=true`.
- **Resultado:** no reboot a máquina **não bootou** (ficou pendurada na inicialização).
- Solução: restaurar o `config.plist` do backup e apagar a kext.

## Conclusão

1. A porta morta é **EHCI** (USB 2.0 legado). No T440p ela fica na traseira esquerda.
2. O macOS 14 não tem driver EHCI → a porta é **fisicamente inacessível** no Sonoma.
3. O caminho do OCLP (injetar driver USB antigo) **também panika** no 14.1+ (mesmo motivo).
4. O `SSDT-DEHCI.aml` desliga o controlador no boot; mesmo desligando o SSDT não haveria driver.

**Lição aprendida:** não testar kexts USB antigas (USBInjectAll) no Sonoma sem antes
garantir um `config.plist.bak` e um pendrive bootável à mão — quebrou o boot e foi
preciso bootar de um pendrive de recovery para reverter.

## Comandos úteis (diagnóstico)

```bash
# O que o controlador enxerga (só XHCI roda)
ioreg -l -w0 | grep -E 'EHC1|pci8086,8c31|pciclass,0c0330'

# USB detalhado
system_profiler SPUSBDataType

# Portas do XHCI em uso
ioreg -p IODeviceTree -l | grep -E 'HSP|SSP'
```

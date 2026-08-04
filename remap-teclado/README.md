# Remapeamento do teclado ThinkPad T440p ABNT2 (Hackintosh)

**Status: FUNCIONANDO** — a tecla `?` digita `/` (e `?` com Shift), via remapeador em userspace.

## O problema
A tecla `?`/`/` do teclado ABNT2 não digita `/`. No ThinkPad ABNT2, essa tecla fica na **posição do Ctrl direito** e envia scan code `E0 1D` (Ctrl direito). O macOS recebe `keycode 62` (right-ctrl) — nunca `/`.

## Diagnóstico (provado por event tap)
| Tecla física              | Envia | Scan code | Conclusão |
|---------------------------|-------|-----------|-----------|
| Tecla `?` (posição Ctrl dir) | **62** (Ctrl dir) | **E0 1D** | Layout ABNT2 nativo ThinkPad (caso Oracle/VirtualBox #8745, patch Lenovo) |
| Backspace físico          | **51** | **0E** | Normal (a `?` NÃO é backspace) |
| `a`                       | 0 | 1E | Mapa do kext NÃO aplica |

## Caminhos testados e resultado

### 1. hidutil (`UserKeyMapping` 62→44) ❌ NÃO FUNCIONA
Aplicado ao vivo, mas a `?` continuou `kc=62`. O teclado ADB/PS2 deste Hackintosh não respeita o remap do IOHIDSystem.
Scripts em `03-conserto/`.

### 2. Custom PS2 Map do VoodooPS2 (plist + reboot) ❌ NÃO APLICA
- O plist TEM o mapa (`CLEAN TEST v2`) e o registro ioreg mostra ele carregado.
- `LogScanCodes=1` foi aplicado (prova que o config roda) — mas `a` continua `a`, e nenhum log aparece.
- Causa raiz não determinada; exigiria reboot a cada iteração. Abandonado.
- `_getConfigurationNode`/`makeConfigurationNode` (2.3.7): OEM ID do DSDT = `LENOVO` (via `RM,oem-id`), não casa com perfil do teclado → usa `Default`.

### 3. Remapeador em userspace (event tap + injeção de unicode) ✅ **FUNCIONA**
Intercepta `kc=62` (a tecla `?`), suprime, e injeta o caractere `/` (ou `?` com Shift) via `CGEventKeyboardSetUnicodeString`.
- **Por que injeção de unicode:** o layout ABNT2 mapeia keycodes de forma não-óbvia (`kc=44` = `;`, não `/`). Injeção de unicode é independente de layout — garantido.
- Permissão: precisa de **Acessibilidade** (uma vez, no binário).
- Não precisa de reboot, não mexe no EFI, não usa Karabiner.

## A solução em produção (`05-remap-usuario/`)
```
05-remap-usuario/
  remap-question.c     fonte em C (um binário, sem dependências)
  remap-question       binário compilado E ASSINADO
  com.gustavo.remap-question.plist   LaunchAgent (roda no login, KeepAlive)
  instalar.sh          copia plist + launchctl load
  remover.sh           launchctl unload + remove
```
Binário em execução agora (verifique):
```
launchctl list | grep remap-question
pgrep -fl remap-question
```

## O que o remapeador faz hoje
| Tecla física            | Antes | Depois (sem Shift) | Depois (com Shift) |
|-------------------------|-------|--------------------|--------------------|
| `?` (posição Ctrl dir)  | nada | `/` | `?` |
| `\|` (esquerda do Z)    | `'`  | `\` | `\|` |
| `'` (esquerda do 1)     | `\`  | `'` | `"` |
| `Alt` + `Tab`           | nada (Option+Tab) | **Cmd+Tab** (switcher de apps) | — |

**Delete (contextual):** a tecla Delete (kc=117, forward-delete):
- No **Finder** (janela ou Desktop) → vira `Cmd+Delete` = mover para a Lixeira (como no Windows).
- Em qualquer outro app → passa normal (apaga caractere à direita).

A troca `'↔\` é **por caractere** (detecta o que a tecla produziu), não por keycode —
funciona independente do keycode que cada tecla reporta. As duas últimas teclas não
precisam ser identificadas: o `'` só vem do kc=50, o `\` vem de um único outro kc.

## Detalhes técnicos importantes
- **Assinatura (codesign):** o binário é assinado com o certificado auto-assinado
  `RemapQuestion Local Signing` (criado via openssl, importado no login keychain).
  SEM isso, toda recompilação muda o cdhash e o macOS revoga a permissão de
  Acessibilidade. Com a assinatura fixa, recompilar não perde a permissão.
- **Anti-loop:** eventos injetados vão para `kCGSessionEventTap` (abaixo do nosso
  HID tap) e recebem o marcador `kCGEventSourceUserData = 0x524D5031`. O callback
  ignora eventos com esse marcador. Sem isso, injetar `'`/`\` recaía no próprio tap
  → loop infinito (documentado: primeiro bug real, causou flood no log).
- **Permissão de Acessibilidade:** concedida 1x no binário assinado (vale para sempre).

### Recompilar depois de mudar o código (receita)
```
clang -O2 -framework ApplicationServices -framework CoreFoundation -Wall -o remap-question remap-question.c
codesign --force --sign "RemapQuestion Local Signing" --identifier com.gustavo.remap-question remap-question
launchctl unload ~/Library/LaunchAgents/com.gustavo.remap-question.plist
launchctl load   ~/Library/LaunchAgents/com.gustavo.remap-question.plist
```
Logs: `/tmp/remap-question.err.log` (mostra cada swap: `swap kc=...`).

### Para instalar do zero (já feito nesta máquina)
1. Compilar + assinar (receita acima).
2. `./instalar.sh`
3. Adicionar o binário `remap-question` em **System Settings → Privacidade e Segurança → Acessibilidade** (uma única vez).
   > Caminho: `/Users/gustavobrito/Documents/Default Project/remap-teclado/05-remap-usuario/remap-question`

## Histórico de teclas (calibração ABNT2)
`kc=50→'`, `kc=44→;`, `kc=42→]`, `kc=41→ç`, `kc=35→~`, `kc=30→´`, `kc=39→~`(acento).
Nenhum kc 0–127 produz `/` ou `?` — por isso a `?` usa keycode (62) e as outras usam
caractere.

## Arquivos de diagnóstico
```
01-diagnostico/   coleta.sh + estado-completo.txt + info-plist-ATUAL.xml
02-testes/        kbtest.py + kbtest2.py + kbtest3.py (ao vivo) + logs
03-conserto/      hidutil aplicar/remover/verificar + instalador (morto)
04-mapa-voodoops2/ como-editar-plist.md (morto)
05-remap-usuario/ SOLUÇÃO FUNCIONANDO
```

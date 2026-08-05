# ThinkPad T440p ABNT2 Keyboard Remapping (Hackintosh)

**Status: WORKING (Sequoia 15.7.8).** The `?` key types `/` (and `?` with Shift),
via a userspace remapper. The LaunchAgent does **not** survive a fresh macOS
install — after the Sequoia reinstall it was re-installed from `05-remap-usuario/`
(see "Installing from scratch").

## The problem

The `?`/`/` key on the ABNT2 keyboard does not type `/`. On the ThinkPad ABNT2,
this key sits at the **right-Ctrl position** and sends scan code `E0 1D`
(right Ctrl). macOS receives `keycode 62` (right-ctrl) — never `/`.

## Diagnosis (proven by event tap)

| Physical key | Sends | Scan code | Conclusion |
|--------------|-------|-----------|------------|
| `?` (right-Ctrl position) | **62** (right Ctrl) | **E0 1D** | Native ThinkPad ABNT2 layout (Oracle/VirtualBox #8745, Lenovo patch) |
| Physical Backspace | **51** | **0E** | Normal (the `?` is NOT backspace) |
| `a` | 0 | 1E | Kext mapping is not applied |

## Approaches tested and results

### 1. hidutil (`UserKeyMapping` 62→44) ❌ DOES NOT WORK
Applied live, but the `?` still reported `kc=62`. The ADB/PS2 keyboard on this
Hackintosh does not honor the IOHIDSystem remap. Scripts in `03-conserto/`.

### 2. Custom PS2 Map in VoodooPS2 (plist + reboot) ❌ NOT APPLIED
- The plist HAS the map (`CLEAN TEST v2`) and ioreg shows it loaded.
- `LogScanCodes=1` was applied (proving the config runs) — but `a` stays `a` and no
  log appears.
- Root cause not determined; required a reboot per iteration. Abandoned.
- `_getConfigurationNode`/`makeConfigurationNode` (2.3.7): the DSDT OEM ID is
  `LENOVO` (via `RM,oem-id`), which does not match the keyboard profile → uses `Default`.

### 3. Userspace remapper (event tap + Unicode injection) ✅ **WORKS**
Intercepts `kc=62` (the `?` key), suppresses it, and injects `/` (or `?` with Shift)
via `CGEventKeyboardSetUnicodeString`.
- **Why Unicode injection:** the ABNT2 layout maps keycodes non-obviously
  (`kc=44` = `;`, not `/`). Unicode injection is layout-independent — guaranteed.
- Permission: needs **Accessibility** (once, on the binary).
- No reboot required, does not touch the EFI, does not use Karabiner.

## The production solution (`05-remap-usuario/`)

```
05-remap-usuario/
  remap-question.c     C source (single binary, no dependencies)
  remap-question       compiled AND SIGNED binary (what the LaunchAgent runs)
  remap-question.py    minimal Python reference (`?`/`/` only)
  com.gustavo.remap-question.plist   LaunchAgent (runs at login, KeepAlive)
  instalar.sh          creates ~/Library/LaunchAgents + copies plist + launchctl load
  remover.sh           launchctl unload + remove
```

The binary is running now (check with):
```
launchctl list | grep remap-question
pgrep -fl remap-question
```

## What the remapper does today

| Physical key | Before | After (no Shift) | After (with Shift) |
|--------------|--------|------------------|--------------------|
| `?` (right-Ctrl position) | nothing | `/` | `?` |
| `\|` (left of Z) | `'` | `\` | `\|` |
| `'` (left of 1) | `\` | `'` | `"` |
| `Alt` + `Tab` | nothing (Option+Tab) | **Cmd+Tab** (app switcher) | — |

**Delete (contextual):** the Delete key (kc=117, forward-delete):
- In **Finder** (window or Desktop) → becomes `Cmd+Delete` = move to Trash (like Windows).
- In any other app → passes through (deletes the character to the right).

The `'↔\` swap is **per character** (detects what the key produced), not per keycode —
it works regardless of which keycode each key reports. The last two keys do not
need to be identified: `'` only comes from kc=50, and `\` comes from a single other kc.

## Important technical details

- **Signing (codesign):** the binary is ad-hoc signed (`codesign -s -`) with
  identifier `com.gustavo.remap-question`. The original self-signed certificate
  `RemapQuestion Local Signing` is **no longer in the keychain** (was lost along
  the way). Because macOS keys Accessibility on the **cdhash**, every recompile
  revokes the permission and the binary must be **re-added** to Acessibilidade once.
- **Anti-loop:** injected events go to `kCGSessionEventTap` (below our HID tap) and
  receive the marker `kCGEventSourceUserData = 0x524D5031`. The callback ignores
  events with this marker. Without this, injecting `'`/`\` would re-enter our own
  tap → infinite loop (documented: first real bug, flooded the log).
- **Accessibility permission:** granted once per binary build. After a recompile
  the cdhash changes → macOS revokes it → grant again (one time).
- **Keyup (Sequoia fix, 2026-08-05):** the char-swap path originally posted **only
  the keydown** of the replacement character and swallowed the keyup. On Sequoia
  the app then showed the **original** character (`'` for the `\`-labeled key). The
  fix mirrors the `?`/`/` path: post the replacement keydown **and** keyup
  (`post_char(repl, type == kCGEventKeyDown)`), swallowing both. This is why a
  recompile + re-grant was needed.

### Recompile after changing the code (recipe)

```
clang -O2 -framework ApplicationServices -framework CoreFoundation -Wall -o remap-question remap-question.c
codesign --force -s - --identifier com.gustavo.remap-question remap-question
launchctl unload ~/Library/LaunchAgents/com.gustavo.remap-question.plist
launchctl load   ~/Library/LaunchAgents/com.gustavo.remap-question.plist
# then re-add the binary to Acessibilidade (cdhash changed)
```
Logs: `/tmp/remap-question.err.log` (shows each swap: `swap kc=... <down|up> '<c>' -> '<c>'`).

### Installing from scratch (redone after the Sequoia fresh install)

The folder is **portable** — you can keep it anywhere (`instalar.sh` auto-detects
its own location and rewrites the plist path at install time):

1. Copy the `05-remap-usuario/` folder anywhere you like (e.g.
   `~/remap-teclado/05-remap-usuario/`).
2. `./instalar.sh` — creates `~/Library/LaunchAgents`, copies the plist, rewrites
   the `ProgramArguments` path to the folder's real location and runs
   `launchctl load`.
3. Add the `remap-question` binary to **System Settings → Privacy & Security →
   Accessibility** (once).
   > Repo path: `keyboard-remap/05-remap-usuario/remap-question`
   > Until granted, the agent restarts in a loop and logs
   > `event tap falhou (sem Acessibilidade)` to `/tmp/remap-question.err.log`.

> The old `.py` in this folder is a minimal reference implementation (`?`/`/` only).
> The production remapper is the C binary, which also does `'↔\`, `"↔|`,
> Alt-Tab→Cmd-Tab and the contextual Delete.

## Key history (ABNT2 calibration)

`kc=50→'`, `kc=44→;`, `kc=42→]`, `kc=41→ç`, `kc=35→~`, `kc=30→´`,
`kc=39→~`(accent). No kc 0–127 produces `/` or `?` — hence the `?` uses the keycode
(62) and the others use the character.

## Diagnostic files

```
01-diagnostico/       coleta.sh + estado-completo.txt + info-plist-ATUAL.xml
02-testes/            kbtest.py + kbtest2.py + kbtest3.py (live) + logs
03-conserto/          hidutil apply/remove/verify + installer (dead)
04-mapa-voodoops2/    how-to-edit-plist.md (dead)
05-remap-usuario/     WORKING SOLUTION
```

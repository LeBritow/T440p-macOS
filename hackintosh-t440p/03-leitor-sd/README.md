# Leitor de cartão SD — Realtek RTS5227

**Status: DESATIVADO (decisão do usuário).** Nenhuma das duas kexts ficou em produção —
o preço era instabilidade de boot/sleep/wake. Leitor SD fica morto; sleep/wake estável.

## O problema

- Leitor SD embutido = **Realtek RTS5227** (`pci10ec,5227`), lado esquerdo.
- Duas kexts concorrentes, **cada uma com um (ou mais) defeito grave**:

| Driver | Leitor funciona? | Defeitos |
|--------|------------------|----------|
| **RealtekCardReader 0.9.8** (`science.firewolf.rtsx`) | Sim | 1. **Panic no boot** com cartão no slot; 2. **Panic no wake do sleep** (mesmo SEM cartão) |
| **Sinetek-rtsx 9.0** | Sim | Bug de **desligamento/reinício** (tela de fundo trava no shutdown) |

## A sequência real

1. **RealtekCardReader 0.9.8** escolhido ("funcionou perfeitamente") com protocolo:
   sem cartão no boot, inserir só depois, ejetar antes de desligar.
2. **Novo sintoma:** em um ciclo normal de sleep/wake **sem cartão no slot**, a máquina
   panikou ao acordar:

```
panic: Wake transition timed out after 180 seconds while calling power state change
callbacks. Suspected bundle: science.firewolf.rtsx.
RealtekCardReaderController::prepareToWakeUp → onSDCardInsertedSync → setPowerState
```

   Ou seja: o power management do driver é bugado nesse hardware **independente de cartão**.

3. **Decisão:** desativar **as duas kexts** e abrir mão do leitor SD, em troca de
   boot + sleep/wake 100% estáveis.

## Pesquisa feita (se alguém quiser tentar de novo no futuro)

O **Sinetek-rtsx tem correção documentada exatamente para o RTS5227**:

> *"RTS5227 — Seems to work fine with sleep disabled. Adding boot parameter
> `rtsx_sleep_wake_delay_ms=1000` may help with sleep/wake."*

Testado por usuários em **T440S/X240** (mesmo chip `0x522710EC`), que confirmaram o
leitor funcionando após wake com esse boot-arg. Se um dia a prioridade inverter,
esse é o caminho a testar (Sinetek + `rtsx_sleep_wake_delay_ms=1000` nos boot-args).

O **RealtekCardReader** não tem boot-arg de sleep/wake (o `rtsxdcib` é só atrasar
init no boot) — por isso a desativação total venceu.

## Estado no config.plist

- `RealtekCardReader.kext` → **Enabled = false**
- `Sinetek-rtsx.kext` → **Enabled = false**

(As kexts continuam na pasta `kexts/`, só desabilitadas — fácil de reverter.)

## Diagnóstico rápido

```bash
# Confirma o device do leitor (sem driver, fica "unclaimed" no ioreg)
ioreg -l | grep -i 'pci10ec,5227'

# Confirma que nenhuma das kexts carrega
kextstat | grep -iE 'rtsx|cardreader'
```

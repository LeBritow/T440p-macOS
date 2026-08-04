# Pós-instalação, manutenção e roadmap

Coisas que fizemos/alinhamos **depois** de deixar o sistema estável — TRIM, monitoramento,
manutenção do EFI e o plano de upgrade para o Sequoia.

## TRIM no SSD (recomendado)

SSD não-Apple no macOS vem com TRIM desligado (`system_profiler SPSerialATADataType` → `No`).
Ativar evita degradação de desempenho com o passar do tempo:

```bash
sudo trimforce enable    # digite "y" duas vezes — reinicia sozinho
```

- O quirk `ThirdPartyDrives` do OpenCore **é ignorado no Sonoma+** (só valia até 10.15).
  No Sonoma o único caminho é o `trimforce`.
- Conferir depois: `system_profiler SPSerialATADataType | grep TRIM` → `Yes`.
- Nesta máquina foi ativado e o sistema ficou mais responsivo.

## Monitoramento (CPU / RAM / temps / fan)

App recomendado: **[Stats](https://github.com/exelban/stats)** (gratuito, open source).

- Mostra CPU, memória, disco, rede, **temperaturas**, **fan** e bateria na barra de menus.
- Funciona bem em Hackintosh porque o `VirtualSMC` + `SMCProcessor` + `SMCSuperIO`
  expõem os **sensores físicos reais** (CPU via MSR, fan via Super I/O).
- **Exceção:** uso/temp de GPU não aparece de forma confiável na HD 4600 (não é exposta via SMC).
- Instalação sem brew: baixar o `.dmg` da release e arrastar para o /Applications.

Alternativas: iStat Menus (pago), MenuMeters (free), Intel Power Gadget (freq/temp da CPU).

## Manutenção da partição EFI (FAT `dirty`)

Desligamentos sujos marcam a EFI como `dirty` e ela para de montar:

```bash
sudo fsck_msdos -y /dev/rdisk0s1 && sudo diskutil mount disk0s1
```

Regra de ouro: **sempre** `cp config.plist config.plist.bak-$(date +%Y%m%d-%H%M%S)`
antes de mexer no config.

## Roadmap: upgrade para macOS Sequoia (15)

Motivação: iMovie e apps atuais exigem macOS 15; o T440p (HD 4600 Haswell) é suportado.

> Ainda **não executado** — planejado, com os passos seguros definidos:

1. **Backup Time Machine** antes de tudo (rede de segurança para voltar ao estado atual).
2. **Atualizar OpenCore + kexts** rodando ainda no Sonoma, e testar boot:
   - `AirportItlwm` → build do **Sequoia (2.4.x)** — a 2.3.0 é do Sonoma e mata o WiFi.
   - `Lilu`, `WhateverGreen`, `AppleALC` → versões mais recentes.
   - `OpenCore` 1.0.4 → mais recente disponível.
3. **OTA**: Configurações → Atualização de Software (SMBIOS `MacBookPro16,1` +
   boot-arg `revpatch=sbvmm` já permitem OTA).
4. **Pós-upgrade**: conferir WiFi/áudio/USB/bateria; reinstalar Stats se necessário.

Voltar para o Sonoma é possível (restaurar EFI antigo + TM restore), então o upgrade
não "queima a ponte".

## Portas e hardware — resumo prático

| Item | Situação |
|------|----------|
| USB traseira **direita** (Always-On) | ✅ Funciona |
| USB **3.0 esquerda** (top/bottom) | ✅ Funciona |
| USB traseira **esquerda** (abaixo do SD) | 🔌 Morta — EHCI sem driver no Sonoma |
| Leitor de cartão **SD** (RTS5227) | 🔇 Desativado (kexts panikavam boot/wake/shutdown) |
| WiFi / BT / Áudio / Ethernet / Bateria | ✅ Funcionando |
| Boot | Direto ao logo; **Esc** no ligar = menu |

## Backup

`~/Documents/backup/` contém o EFI com SMBIOS real, o projeto do teclado e o guia de
restauro — **copiar para um HD externo** (a pasta por inteiro).

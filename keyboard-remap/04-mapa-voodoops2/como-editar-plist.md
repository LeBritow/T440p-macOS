# Como editar o Info.plist do VoodooPS2Keyboard

O kext carregado mora na particao EFI:
```
/Volumes/EFI/EFI/OC/Kexts/VoodooPS2Controller.kext
└── Contents
    └── PlugIns
        └── VoodooPS2Keyboard.kext
            └── Contents
                └── Info.plist     <-- edite este arquivo
```

## Abrindo com editor visual (recomendado)
- **ProperTree** (gratuito): `brew install --cask propertree` ou baixe em github.com/corpnewt/ProperTree. Rode `ProperTree.command` e abra o plist.
- **PlistEdit Pro**: pago, da Mac App Store.
- VS Code com o plugin **Binary Plist Viewer** tambem da (arquivos .plist compilados viram XML).

> Dica: no Finder, `Ctrl+clique` no kext → "Mostrar Conteudo do Pacote" para navegar.

## Onde fica o mapa
No plist, va em:
```
IOKitPersonalities → ApplePS2Keyboard → Platform Profile → Default → Custom PS2 Map
```
Cada item do array e uma string `scanfrom=scanto` em hex:
```
<string>e01d=35</string>     ; Ctrl direito (E0 1D) -> tecla "/" (0x35)
```
- `;` comeca comentario (a chave `;` comeca comentario na LENHA; o `;` no MEIO da linha e usado como separador de comentario tambem, ex. `e01d=35;vira slash`).
- Scan normal: 2 hex (ex. `1e` = letra A, `35` = tecla `/`).
- Scan estendido: `e0` + 2 hex (ex. `e01d` = Ctrl direito).

## O que significa cada scan code (Set 1)
| Tecla              | Scan  | Tecla            | Scan  |
|--------------------|-------|------------------|-------|
| A                  | 1e    | Backspace        | 0e    |
| Ctrl esquerdo      | 1d    | Ctrl direito     | e01d  |
| `/` (ABNT2 nativo) | 35    | `?` (Shift+35)   | -     |
| Shift direito      | 36    | Barra espaco     | 39    |
| Enter              | 1c    | Tab              | 0f    |

Tabela completa: `VoodooPS2Keyboard/ApplePS2ToADBMap.h` no repositorio acidanthera/VoodooPS2.

## Aplicando
1. Edite, salve.
2. **Reinicie** (o kext e prelinkado no boot pelo OpenCore). NAO ha recarga a quente.

## O IMPORTANTE (descoberto no diagnostico)
- A tecla `?` do teu teclado **esta na posicao do Ctrl direito** e envia o scan **E0 1D** (layout ABNT2 nativo do ThinkPad). O Backspace fisico envia **0E**. Sao scan codes DIFERENTES — da para separar.
- Porem: **ate agora o mapa do VoodooPS2 nao foi aplicado no runtime** (teste `a`→`1` falhou), apesar de o plist carregar. O motivo ainda nao foi confirmado (suspeita: problema de parsing/prelink, ou o plist nao sendo lido de onde pensamos).
- Solucao independente do kext: **hidutil** (macOS nativo) — ver `../03-conserto/`.

## MAPA SUGERIDO (se quisermos usar o VoodooPS2)
No `Custom PS2 Map` do Default, o item que resolve a `?`:
```
<string>e01d=35</string>   ; Ctrl direito -> "/" (Shift+"?" funcionara com shift)
```
Isso transforma a tecla `?` (que hoje e Ctrl direito) na tecla `/`. O Backspace (0e) nao e afetado. Voce perde o Ctrl direito (mas o esquerdo continua).

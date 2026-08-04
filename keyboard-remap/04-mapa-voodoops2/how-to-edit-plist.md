# How to edit the VoodooPS2Keyboard Info.plist

The loaded kext lives on the EFI partition:
```
/Volumes/EFI/EFI/OC/Kexts/VoodooPS2Controller.kext
└── Contents
    └── PlugIns
        └── VoodooPS2Keyboard.kext
            └── Contents
                └── Info.plist     <-- edit this file
```

## Opening with a visual editor (recommended)
- **ProperTree** (free): `brew install --cask propertree` or download from
  github.com/corpnewt/ProperTree. Run `ProperTree.command` and open the plist.
- **PlistEdit Pro**: paid, from the Mac App Store.
- VS Code with the **Binary Plist Viewer** plugin also works (compiled `.plist`
  files are shown as XML).

> Tip: in Finder, `Ctrl+click` the kext → "Show Package Contents" to navigate.

## Where the map lives
In the plist, go to:
```
IOKitPersonalities → ApplePS2Keyboard → Platform Profile → Default → Custom PS2 Map
```
Each array item is a `scanfrom=scanto` string in hex:
```
<string>e01d=35</string>     ; right Ctrl (E0 1D) -> "/" key (0x35)
```
- `;` starts a comment (the `;` at the START of a value is a comment; a `;` in the
  MIDDLE is a comment separator too, e.g. `e01d=35;becomes slash`).
- Normal scan: 2 hex digits (e.g. `1e` = letter A, `35` = `/` key).
- Extended scan: `e0` + 2 hex digits (e.g. `e01d` = right Ctrl).

## Scan code reference (Set 1)
| Key               | Scan  | Key             | Scan  |
|-------------------|-------|-----------------|-------|
| A                 | 1e    | Backspace       | 0e    |
| Left Ctrl         | 1d    | Right Ctrl      | e01d  |
| `/` (native ABNT2)| 35    | `?` (Shift+35)  | -     |
| Right Shift       | 36    | Space           | 39    |
| Enter             | 1c    | Tab             | 0f    |

Full table: `VoodooPS2Keyboard/ApplePS2ToADBMap.h` in the acidanthera/VoodooPS2 repo.

## Applying the changes
1. Edit and save.
2. **Reboot** (the kext is prelinked by OpenCore at boot — there is NO hot reload).

## THE IMPORTANT PART (discovered during diagnosis)
- The `?` key on this keyboard **sits at the right-Ctrl position** and sends the
  **E0 1D** scan (native ThinkPad ABNT2 layout). The physical Backspace sends **0E**.
  They are DIFFERENT scan codes — they can be told apart.
- However: **the VoodooPS2 map was never applied at runtime** (the `a`→`1` test
  failed) even though the plist loads. The reason was not confirmed (suspicion:
  parsing/prelink issue, or the plist not being read where we expected).
- Kext-independent solution: **hidutil** (native macOS) — see `../03-conserto/`.

## SUGGESTED MAP (if we ever use VoodooPS2 again)
In the `Default` → `Custom PS2 Map`, the entry that fixes `?`:
```
<string>e01d=35</string>   ; right Ctrl -> "/" (Shift+"?" still gives "?")
```
This turns the `?` key (currently right Ctrl) into `/`. Backspace (0e) is
unaffected. You lose right Ctrl (left Ctrl still works).

> **Status: dead end.** The kext-level map was abandoned because it never applied
> at runtime. The working solution is the userspace remapper in `../05-remap-usuario/`.

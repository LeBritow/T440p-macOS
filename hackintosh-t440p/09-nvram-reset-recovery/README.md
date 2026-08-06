# NVRAM reset — macOS drive vanished from the picker + recovery via OpenShell

**Status: SOLVED — documented because this was hard to find.** This happened to
me on the T440p (Sequoia, OCLP) after changing the SMBIOS and doing a
**Reset NVRAM** from the OpenCore picker. The recovery trick (booting `boot.efi`
directly from the EFI Shell) is what saved the machine, and finding it took a
while — so this page exists.

## The trigger and the symptoms

1. I changed the SMBIOS in `config.plist` and did **Reset NVRAM** from the picker
   (I knew it was routine — I was still surprised when the boot fell apart).
2. After the reset the **main macOS volume vanished from the boot picker**. Only
   auxiliary entries (and possibly Recovery) remained.
3. Booting the **Recovery** partition failed with
   `OCB: loadimage failed buffer too small` — a memory-allocation error that
   shows up on Haswell when OpenCore tries to load the large Recovery DMG into
   fragmented low RAM.

## Why this happens

Modern macOS (Big Sur and newer) does not boot from the root partition directly:
it boots from a **sealed APFS snapshot**, and the pointer to the exact snapshot
(the *blessed path*) is stored in **NVRAM**. A Reset NVRAM wipes that pointer, so
OpenCore re-scans the drive without a valid boot selection and, depending on the
security filters in place, the volume shows as *hidden/not bootable*.

It is **not** permanent damage: the blessed path can be recreated (see
"Post-boot repairs" below) and NVRAM is re-populated from `config.plist` on every
boot.

## The solution: boot `boot.efi` directly from the UEFI Shell

Editing `config.plist` (e.g. `SecureBootModel`/`MinDate`/`MinVersion`, `ScanPolicy`)
was not needed — the shell bypass skips the picker entirely and launches Apple's
bootloader manually.

### Step-by-step

1. From the OpenCore picker, press **Spacebar** to reveal hidden entries and
   launch **OpenShell.efi**. (With direct boot enabled, hold `Esc` at power-on to
   reach the picker first.)
2. Probe the mapped filesystems until you find the **Preboot** partition — the
   actual boot engine no longer lives on the system volume. Run `map -b` or just
   `ls FS0:` … `FS3:` … until you find the partition that contains a long
   **UUID folder** (e.g. `ECDDB7D0-211D-46B7-…`). On my machine it was `FS4:`.
3. Enter the Preboot partition and the UUID folder, then `CoreServices`:
   ```bash
   FS4:
   cd EC[press TAB to autocomplete the UUID]
   cd System\Library\CoreServices
   ```
4. Run the Apple bootloader directly:
   ```bash
   boot.efi
   ```
   This bypasses OpenCore's picker restrictions, loads the kernel and extensions,
   and boots straight into macOS Sequoia.

## Post-boot repairs (make it permanent)

Once back in macOS:

1. **Re-bless the volume** so the snapshot path is written back to NVRAM:
   *System Settings → General → Startup Disk → select Macintosh HD → authenticate.*
2. **If needed**, re-run the **OCLP Post-Install Root Patch** and/or
   **Build and Install OpenCore** (the reset clears a few OCLP NVRAM variables;
   re-installing regenerates a clean, compliant setup).
3. Verify NVRAM was re-populated from `config.plist` (on my machine it came back
   exactly as configured): `csr-active-config = %03%08%00%00`, the `boot-args`
   intact, `prev-lang:kbd = pt-BR:128`.

## Key take-aways

- **Reset NVRAM is safe and routine** — but expect the boot selection to be
  wiped. It is recoverable and always re-populates from the config on the next
  boots.
- The **shell `boot.efi` trick is your emergency boot**: it does not depend on
  the picker, NVRAM bless records or OpenCore's volume filtering.
- Keep `config.plist.bak-<date>` backups (see `06-post-install/`) — they make
  every scare reversible.

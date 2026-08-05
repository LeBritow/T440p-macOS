# Contributing

Thanks for stopping by. This repo documents a **real, daily-driven** T440p
Hackintosh — issues are **hardware-verified**, not guessed. If you have the same
laptop (or a similar Haswell / Intel 8-series machine), your experience is valuable.

## Where to contribute

| You want to... | Do this |
|----------------|---------|
| Report a bug / symptom | Open an **issue** |
| Share a solution or idea | Open an **issue** or a **discussion** |
| Fix a typo or add documentation | Open a **pull request** |
| Help on another macOS version | Open a **discussion** or an **issue** |

> **Discussions** are enabled — use them for ideas, general questions and "hey,
> this worked for me" reports that don't fit an issue.

## Reporting an issue

Before opening an issue, search the existing ones. When you report, include:

- **Exact symptom** — what happens, when (boot / sleep / wake / shutdown / app).
- **macOS version** and **build** (e.g. `15.7.8 (24G824)`).
- **OpenCore version** and which `config.plist` (production vs snapshot).
- **SMBIOS** model used (e.g. `MacBookPro16,1`).
- **Kexts involved** (names + versions from the config).
- **Steps to reproduce** and anything you already tried.

Panic screenshots are welcome. A **`kextstat`** and **`ioreg`** excerpt often says
more than ten paragraphs.

## Pull requests

- Match the existing style: **English**, formal, tables when comparing things.
- Never commit **real SMBIOS values** — use the placeholders
  (`AAAAAAAA...`) as the repo does. Public serials risk iMessage blacklisting.
- Keep `config.plist` in `05-open-core-config/` in sync with the EFI snapshots.
- Document **why** (the reasoning), not just what was changed.

## Scope

- This is a **documentation-first** repo. Code contributions are welcome
  (`keyboard-remap/`, `scripts/`) but documentation quality matters most here.
- We document both **solutions** and **accepted dead-ends** (e.g. the EHCI USB
  port, the SD reader) — that honesty is the point.

#!/usr/bin/env python3
import Quartz
import sys
import time


def main():
    print("kbtest: capturando eventos de teclado...", flush=True)
    print("Se o mapa estiver APLICADO, estas teclas digitam digitos:", flush=True)
    print("  'a' -> '1' (keycode 18)  |  Ctrl-esq -> '2' (19)", flush=True)
    print("  Ctrl-dir -> '3' (20)     |  '?' -> '4' (21)", flush=True)
    print("Keycodes p/ comparar: a=0, 1=18, 2=19, 3=20, 4=21,", flush=True)
    print("  ctrl-esq=59, ctrl-dir=62", flush=True)
    print("-" * 60, flush=True)

    def cb(proxy, etype, event, refcon):
        kc = Quartz.CGEventGetIntegerValueField(event, Quartz.kCGKeyboardEventKeycode)
        fl = Quartz.CGEventGetFlags(event)
        chars = Quartz.CGEventKeyboardGetUnicodeString(event, 16, None, None)
        if etype == Quartz.kCGEventKeyDown:
            kind = "DOWN"
        elif etype == Quartz.kCGEventKeyUp:
            kind = "UP"
        elif etype == Quartz.kCGEventFlagsChanged:
            kind = "FLAG"
        else:
            kind = "EVT"
        fs = []
        if fl & Quartz.kCGEventFlagMaskControl:
            fs.append("CTRL")
        if fl & Quartz.kCGEventFlagMaskShift:
            fs.append("SHIFT")
        if fl & Quartz.kCGEventFlagMaskCommand:
            fs.append("CMD")
        if fl & Quartz.kCGEventFlagMaskAlternate:
            fs.append("OPT")
        print(f"{kind:4s} kc={kc:3d}(0x{kc:02x}) flags={','.join(fs) or '-'} chars={chars!r}", flush=True)
        return event

    mask = (Quartz.CGEventMaskBit(Quartz.kCGEventKeyDown) |
            Quartz.CGEventMaskBit(Quartz.kCGEventKeyUp) |
            Quartz.CGEventMaskBit(Quartz.kCGEventFlagsChanged))
    tap = Quartz.CGEventTapCreate(Quartz.kCGHIDEventTap, Quartz.kCGHeadInsertEventTap,
                                  Quartz.kCGEventTapOptionDefault, mask, cb, None)
    if not tap:
        print("ERRO: nao foi possivel criar o event tap.", file=sys.stderr, flush=True)
        print("Conceda Acessibilidade ao Terminal e rode de novo.", file=sys.stderr, flush=True)
        sys.exit(1)
    Quartz.CGEventTapEnable(tap, True)
    src = Quartz.CFMachPortCreateRunLoopSource(None, tap, 0)
    Quartz.CFRunLoopAddSource(Quartz.CFRunLoopGetCurrent(), src, Quartz.kCFRunLoopDefaultMode)
    print("PRONTO. Aperte agora, cada uma 2-3x: 'a', Ctrl-esq, Ctrl-dir, '?'", flush=True)
    end = time.time() + 90
    while time.time() < end:
        Quartz.CFRunLoopRunInMode(Quartz.kCFRunLoopDefaultMode, 0.2, False)
    print("-" * 60, flush=True)
    print("fim.", flush=True)


if __name__ == "__main__":
    main()

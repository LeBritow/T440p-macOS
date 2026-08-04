#!/usr/bin/env python3
import Quartz
import sys
import os

SRC = 62  # tecla '?' fisica -> reporta como right-ctrl (kc=62)
LOG = os.environ.get("REMAP_LOG", "/tmp/remap-question.log")


def log(msg):
    try:
        with open(LOG, "a") as f:
            f.write(msg + "\n")
    except Exception:
        pass


def post(ch, down):
    ev = Quartz.CGEventCreateKeyboardEvent(None, 0, down)
    if ev:
        Quartz.CGEventKeyboardSetUnicodeString(ev, 1, ch)
        Quartz.CGEventPost(Quartz.kCGHIDEventTap, ev)


def cb(proxy, etype, event, refcon):
    kc = Quartz.CGEventGetIntegerValueField(event, Quartz.kCGKeyboardEventKeycode)
    if kc != SRC:
        return event

    shift = bool(Quartz.CGEventGetFlags(event) & Quartz.kCGEventFlagMaskShift)
    ch = "?" if shift else "/"

    if etype == Quartz.kCGEventFlagsChanged:
        pressed = bool(Quartz.CGEventGetFlags(event) & Quartz.kCGEventFlagMaskControl)
        log(f"flagsChanged kc={kc} -> {ch} {'DOWN' if pressed else 'UP'}")
        post(ch, pressed)
        return None

    down = etype == Quartz.kCGEventKeyDown
    log(f"key kc={kc} -> {ch} {'DOWN' if down else 'UP'}")
    post(ch, down)
    return None


def main():
    if os.path.exists(LOG):
        try:
            os.remove(LOG)
        except Exception:
            pass
    mask = (Quartz.CGEventMaskBit(Quartz.kCGEventKeyDown) |
            Quartz.CGEventMaskBit(Quartz.kCGEventKeyUp) |
            Quartz.CGEventMaskBit(Quartz.kCGEventFlagsChanged))
    tap = Quartz.CGEventTapCreate(Quartz.kCGHIDEventTap, Quartz.kCGHeadInsertEventTap,
                                  Quartz.kCGEventTapOptionDefault, mask, cb, None)
    if not tap:
        log("ERRO: event tap falhou (sem permissao de Acessibilidade?)")
        sys.exit(1)
    Quartz.CGEventTapEnable(tap, True)
    src = Quartz.CFMachPortCreateRunLoopSource(None, tap, 0)
    Quartz.CFRunLoopAddSource(Quartz.CFRunLoopGetCurrent(), src, Quartz.kCFRunLoopDefaultMode)
    log("remap-question iniciado")
    try:
        while True:
            Quartz.CFRunLoopRunInMode(Quartz.kCFRunLoopDefaultMode, 0.5, False)
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()

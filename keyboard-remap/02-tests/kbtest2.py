#!/usr/bin/env python3
import Quartz
import sys
import time

SECS = float(sys.argv[1]) if len(sys.argv) > 1 else 45


def main():
    print("kbtest2: FOCUSED TEST - '?' vs Backspace", flush=True)
    print("The '?' key must be at the RIGHT-CTRL position.", flush=True)
    print("Keycodes: '?'=62(right ctrl)  Backspace=51  Left Ctrl=59", flush=True)
    print("If the VoodooPS2 map worked: '?'=3(20), 'a'=1(18).", flush=True)
    print("-" * 60, flush=True)

    def cb(proxy, etype, event, refcon):
        kc = Quartz.CGEventGetIntegerValueField(event, Quartz.kCGKeyboardEventKeycode)
        fl = Quartz.CGEventGetFlags(event)
        chars = Quartz.CGEventKeyboardGetUnicodeString(event, 16, None, None)
        kind = ("DOWN" if etype == Quartz.kCGEventKeyDown else
                "UP" if etype == Quartz.kCGEventKeyUp else
                "FLAG" if etype == Quartz.kCGEventFlagsChanged else "EVT")
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
        print("ERROR: event tap failed. Grant Accessibility to the terminal.", file=sys.stderr, flush=True)
        sys.exit(1)
    Quartz.CGEventTapEnable(tap, True)
    src = Quartz.CFMachPortCreateRunLoopSource(None, tap, 0)
    Quartz.CFRunLoopAddSource(Quartz.CFRunLoopGetCurrent(), src, Quartz.kCFRunLoopDefaultMode)
    print(f"READY for {SECS:.0f}s. Press in ORDER, 3x each:", flush=True)
    print("  1) the '?' key  (right Ctrl position)", flush=True)
    print("  2) the physical Backspace key (large, above Enter)", flush=True)
    print("  (do not type anything else)", flush=True)
    end = time.time() + SECS
    while time.time() < end:
        Quartz.CFRunLoopRunInMode(Quartz.kCFRunLoopDefaultMode, 0.2, False)
    print("-" * 60, flush=True)
    print("done.", flush=True)


if __name__ == "__main__":
    main()
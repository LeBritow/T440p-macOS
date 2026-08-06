#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>

#define SRC_KEY 62
#define VK_CMD 55
#define VK_TAB 48
#define VK_DELETE_FWD 117
#define MY_MARKER 0x524D5031 /* "RMP1" - eventos que o proprio remap injeta */

static bool del_consumed = false;
static bool alt_down = false;
static bool cmd_held = false;
static CFMachPortRef g_tap = NULL;
static bool g_locked_logged = false;

static const char *tname(CGEventType t)
{
    switch (t)
    {
    case kCGEventKeyDown: return "down";
    case kCGEventKeyUp: return "up";
    case kCGEventFlagsChanged: return "flags";
    default: return "?";
    }
}

static bool is_swap_key(CGKeyCode kc)
{
    return kc == 10 || kc == 50;
}

static bool screen_is_locked(void)
{
    CFArrayRef list = CGWindowListCopyWindowInfo(
        kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    if (!list)
        return false;
    bool locked = false;
    CFIndex n = CFArrayGetCount(list);
    for (CFIndex i = 0; i < n; i++)
    {
        CFDictionaryRef info = CFArrayGetValueAtIndex(list, i);
        if (CFGetTypeID(info) != CFDictionaryGetTypeID())
            continue;
        CFNumberRef layer = CFDictionaryGetValue(info, kCGWindowLayer);
        if (layer && CFGetTypeID(layer) == CFNumberGetTypeID())
        {
            int lv = 0;
            CFNumberGetValue(layer, kCFNumberIntType, &lv);
            if (lv != 0)
                continue;
        }
        CFStringRef owner = CFDictionaryGetValue(info, kCGWindowOwnerName);
        if (!owner)
            continue;
        if (CFStringCompare(owner, CFSTR("loginwindow"), 0) == kCFCompareEqualTo)
            locked = true;
        break;
    }
    CFRelease(list);
    return locked;
}

static bool locked_cache = false;
static time_t locked_checked_at = 0;

static bool is_locked(void)
{
    time_t now = time(NULL);
    if (now == locked_checked_at)
        return locked_cache;
    locked_checked_at = now;
    locked_cache = screen_is_locked();
    return locked_cache;
}

static bool frontmost_is_finder(void)
{
    CFArrayRef list = CGWindowListCopyWindowInfo(
        kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    if (!list)
        return false;
    bool res = false;
    CFIndex n = CFArrayGetCount(list);
    for (CFIndex i = 0; i < n; i++)
    {
        CFDictionaryRef info = CFArrayGetValueAtIndex(list, i);
        if (CFGetTypeID(info) != CFDictionaryGetTypeID())
            continue;
        CFNumberRef layer = CFDictionaryGetValue(info, kCGWindowLayer);
        if (layer && CFGetTypeID(layer) == CFNumberGetTypeID())
        {
            int lv = 0;
            CFNumberGetValue(layer, kCFNumberIntType, &lv);
            if (lv != 0)
                continue;
        }
        CFStringRef owner = CFDictionaryGetValue(info, kCGWindowOwnerName);
        if (!owner || CFStringCompare(owner, CFSTR("Window Server"), 0) == kCFCompareEqualTo)
            continue;
        res = (CFStringCompare(owner, CFSTR("Finder"), 0) == kCFCompareEqualTo);
        break;
    }
    CFRelease(list);
    return res;
}

static void post_char(UniChar u, bool down)
{
    CGEventRef ev = CGEventCreateKeyboardEvent(NULL, 0, down);
    if (!ev)
        return;
    CGEventSetIntegerValueField(ev, kCGEventSourceUserData, MY_MARKER);
    CGEventKeyboardSetUnicodeString(ev, 1, &u);
    CGEventPost(kCGSessionEventTap, ev);
    CFRelease(ev);
}

static void post_key_flags(CGKeyCode kc, bool down, CGEventFlags flags)
{
    CGEventRef ev = CGEventCreateKeyboardEvent(NULL, kc, down);
    if (!ev)
        return;
    CGEventSetIntegerValueField(ev, kCGEventSourceUserData, MY_MARKER);
    CGEventSetFlags(ev, flags);
    CGEventPost(kCGSessionEventTap, ev);
    CFRelease(ev);
}

static void post_key(CGKeyCode kc, bool down)
{
    post_key_flags(kc, down, 0);
}

static bool swap_char(UniChar in, UniChar *out)
{
    switch (in)
    {
    case 0x27: *out = 0x5C; return true; /* '  -> \ */
    case 0x22: *out = 0x7C; return true; /* "  -> | */
    case 0x5C: *out = 0x27; return true; /* \  -> ' */
    case 0x7C: *out = 0x22; return true; /* |  -> " */
    default: return false;
    }
}

static CGEventRef tap_cb(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    (void)proxy; (void)refcon;
    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput)
    {
        fprintf(stderr, "remap: tap desabilitado (%s), reabilitando\n",
                type == kCGEventTapDisabledByTimeout ? "timeout" : "secure-input");
        CGEventTapEnable(g_tap, true);
        return NULL;
    }
    if (!event)
        return NULL;
    if (is_locked())
    {
        if (!g_locked_logged)
        {
            fprintf(stderr, "remap: pausado (tela bloqueada)\n");
            g_locked_logged = true;
        }
        alt_down = false;
        cmd_held = false;
        return event;
    }
    if (g_locked_logged)
    {
        fprintf(stderr, "remap: ativo (tela desbloqueada)\n");
        g_locked_logged = false;
    }
    CGKeyCode kc = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    if (CGEventGetIntegerValueField(event, kCGEventSourceUserData) == MY_MARKER)
    {
        if (is_swap_key(kc) || kc == 62)
            fprintf(stderr, "marker  kc=%3d %s\n", (int)kc, tname(type));
        return event;
    }
    CGEventFlags fl = CGEventGetFlags(event);

    if (type == kCGEventFlagsChanged && (kc == 58 || kc == 61))
    {
        bool pressed = (fl & kCGEventFlagMaskAlternate) != 0;
        if (pressed)
        {
            alt_down = true;
        }
        else
        {
            alt_down = false;
            if (cmd_held)
            {
                post_key(VK_CMD, false);
                cmd_held = false;
            }
        }
        return event;
    }

    if (kc == VK_TAB && alt_down)
    {
        if (type == kCGEventKeyDown)
        {
            if (!cmd_held)
            {
                post_key(VK_CMD, true);
                cmd_held = true;
            }
            post_key_flags(VK_TAB, true, fl & (kCGEventFlagMaskShift | kCGEventFlagMaskCommand));
            post_key_flags(VK_TAB, false, fl & (kCGEventFlagMaskShift | kCGEventFlagMaskCommand));
        }
        return NULL;
    }

    if (kc == VK_DELETE_FWD)
    {
        if (type == kCGEventKeyDown && frontmost_is_finder())
        {
            post_key(VK_CMD, true);
            post_key(VK_DELETE_FWD, true);
            post_key(VK_DELETE_FWD, false);
            post_key(VK_CMD, false);
            del_consumed = true;
            return NULL;
        }
        if (type == kCGEventKeyUp && del_consumed)
        {
            del_consumed = false;
            return NULL;
        }
        return event;
    }

    if (kc == SRC_KEY)
    {
        const char *ch = (fl & kCGEventFlagMaskShift) ? "?" : "/";
        if (type == kCGEventFlagsChanged)
        {
            bool pressed = (fl & kCGEventFlagMaskControl) != 0;
            post_char(ch[0], pressed);
            return NULL;
        }
        post_char(ch[0], type == kCGEventKeyDown);
        return NULL;
    }

    UniChar uc[8];
    UniCharCount n = 0;
    CGEventKeyboardGetUnicodeString(event, 8, &n, uc);
    if (is_swap_key(kc) && n != 1)
        fprintf(stderr, "nonswap kc=%3d %s n=%lu\n", (int)kc, tname(type), (unsigned long)n);
    if (n == 1)
    {
        UniChar repl;
        if (swap_char(uc[0], &repl))
        {
            fprintf(stderr, "swap kc=%3d %s '%c' -> '%c'\n", (int)kc, tname(type), (int)uc[0], (int)repl);
            post_char(repl, type == kCGEventKeyDown);
            return NULL;
        }
    }
    return event;
}

static void health_check(CFRunLoopTimerRef t, void *info)
{
    (void)t; (void)info;
    if (g_tap && !CGEventTapIsEnabled(g_tap))
    {
        fprintf(stderr, "remap: health-check achou tap desabilitado, reabilitando\n");
        CGEventTapEnable(g_tap, true);
    }
}

int main(void)
{
    CGEventMask mask = (1 << kCGEventKeyDown) | (1 << kCGEventKeyUp) | (1 << kCGEventFlagsChanged);
    CFMachPortRef tap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap,
                                         kCGEventTapOptionDefault, mask, tap_cb, NULL);
    if (!tap)
    {
        fprintf(stderr, "remap-question: event tap falhou (sem Acessibilidade)\n");
        return 1;
    }
    g_tap = tap;
    CGEventTapEnable(tap, true);
    CFRunLoopSourceRef src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), src, kCFRunLoopDefaultMode);
    CFRelease(src);

    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                                                   CFAbsoluteTimeGetCurrent() + 5.0, 5.0, 0, 0,
                                                   health_check, NULL);
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopDefaultMode);
    CFRelease(timer);

    fprintf(stderr, "remap-question: rodando ('?'->/, '->\\, \\->', Alt-Tab, Delete-ctx)\n");
    CFRunLoopRun();
    return 0;
}

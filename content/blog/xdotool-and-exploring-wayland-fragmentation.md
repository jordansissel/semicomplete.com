---
title: "Exploring the Fragmentation of Wayland, an xdotool adventure"
date: 2025-11-15
---

In 2007, I was spending a my norther-hemisphere summer experimenting with UI automation. Born of those efforts, xdotool came into being when [I separated it from another project](https://github.com/jordansissel/xdotool/commit/ccae4e3b75551608dde6ba3b9e2aa0264f7a4ac5). The goal was modest - write some scripts that execute common keyboard, mouse, and window management tasks.

The first commit had only a few basic commands - basic mouse and keyboard actions, plus a few window management actions like movement, focus, and searching. Xdotool sprouted new features as time rolled on. Today, the project is 18 years old, and still going!

Time's forward progress also brought external changes: Wayland came along hoping to replace X11, and later Ubuntu tried to take a bite by launching Mir. Noise about Wayland, both good and bad, floated around for years before major distros began shipping it. It wasn't until 2016 when [Fedora became the first distribution to ship it at all](https://en.wikipedia.org/wiki/Wayland_(protocol)#Desktop_Linux_distributions) and even then, it was only for GNOME. It would be another five years before Fedora shipped [KDE support for Wayland](https://fedoraproject.org/wiki/Releases/34/ChangeSet#Wayland_by_Default_for_KDE_Plasma_Desktop). Ubuntu defaulted to Wayland it in 2017, almost a decade after Wayland began, but switched back to X11 on the next release because screen sharing and remote desktop weren't available.

Screen sharing and remote desktop. Features that have existed for decades on other systems, that we all knew would be needed? They weren't available and distros were shipping a default Wayland experience without them. It was a long time before you could join a Zoom call and share your screen. Awkward.

All this to say, Wayland has been a long, bumpy road.

Back to xdotool: xdotool relies on a few X11 features that have existed since before I even started using Linux:

* Standard X11 operations - Searching for windows by their title, moving windows, resizing them, closing, etc.
* XTest - A means to "test" things on X11 without requiring user action. This provides a way to perform mouse and keyboard actions from your code. You can type, you can move the mouse, you can click.
* EWMH - "Extended Window Manager Hints" - A specification for how to communicate with the window manager. This allows xdotool to switch virtual desktops, move windows to other desktops, find processes that own a window, etc.

All of the above is old, stable, and well supported.

Wayland comes along and eliminates *everything* xdotool can do. Some of that elimination is given excuses that it is "for security" with little found to acknowledge what is being elided and why. It's fine, I guess... but we ended up with linux distros shipping without significant features that, have, over time, been somewhat addressed. For example, I can share my screen on video calls, now. 

So what happened to all of the features elided in the name of security?

Fragmentation is what happened. Buckle up. Almost 10 years into Fedora's first Wayland release and those elided features are still missing or have multiple implementation proposals with very few maintainers agreeing on what to support. I miss EWMH.

Do you want to send keystrokes and mouse actions? 

* GNOME 48:
  * Xwayland can send keystrokes to the compositor using XTEST. That's kinda nice, but every few minutes get a popup with almost zero context stating "Allow remote interaction" with a toggle switch. It's confusing, because sending keystrokes from a local command does not feel like "remote interaction"
  * You can write code that uses XDG Portal's RemoteDesktop session to request access and then use libei to send keystrokes and mouse actions. Documentation is sparse as this is still quite new. However, it still prompts you as above and there appears no permanent way to grant permission, despite the portal api documenting such an option.
* KDE
  * Xwayland performs similarly when XTEST is used. This time, it pops up "Remote control requested. transient requested access to remotely control: input devices" -- It's confusingly written with hardly any context especially since these popups are new.
* Some other compositors support wayland protocol extensions which permit things like [virtual keyboard input](https://wayland.app/protocols/virtual-keyboard-unstable-v1). Fragmentation continues as there are many protocol extension proposals which add virtual text input, keyboard actions, and mouse/pointer actions. Which ones work, or don't, depend entirely on what window manager / compositor you are using.

Outside of Wayland, Linux has uinput which allows a program to create, and use, a virtual keyboard and mouse, but it requires root permissions. Further, a keyboard device sends key codes, not symbols, which makes for another layer of difficulty. In order to send the key symbol 'a' we need to know what keycode (or key sequence) sends that symbol. In order to do that, you need the keyboard mapping. There are several ways to do this, and it's not clear which one (Wayland's wl_keyboard, X11's XkbGetMap via Xwayland, or XDG RemoteDesktop's ConnectToEIS which allows you to fetch the keyboard mapping with libei but will cause the confusing Remote Desktop access prompt).

Window management is also quite weird. Wayland appears to have no built-in protocol for one program (like xdotool) asking a window to do anything - be moved, resized, maximized, or closed.

* GNOME offers window management only through GNOME Shell Extensions. Javascript apps you install in GNOME and have access to a GNOME-specific Javascript API. Invoking any of these from a shell command isn't possible without doing some wild maneuvers: GNOME Javascript allows you to access DBus, and you can write code that moves a window ande expose that method over DBus. I'm not the first to consider this, as there are a few published extensions that already do this, such as [Focused Window D-Bus](https://extensions.gnome.org/extension/5592/focused-window-d-bus/). GNOME has a DBus method for executing javascript (org.gnome.Shell.Eval), but it's disabled by default.
* KDE has a similar concept offered by GNOME, but completely incompatible. Luckily, I suppose, KDE also has a DBus method for invoking javascript and, at time of writing, it is *enabled* by default. A KDE+Wayland-specific derivative of xdotool, [kdotool](https://github.com/jinliu/kdotool) does exactly this to provide a command-line tool which allows you to manage your windows.
* Outside of KDE and GNOME, you might find luck with some third-party Wayland protocol extensions. If your compositor is based on [wlroots](https://github.com/swaywm/wlroots), it'll likely be usable with [wlrctl](https://git.sr.ht/~brocellous/wlrctl), a command line tool similar to xdotool and wmctrl. Wlrctl only works if your compositor supports specific, non-default wayland protocols, such as [wlr-foreign-toplevel-management](https://wayland.app/protocols/wlr-foreign-toplevel-management-unstable-v1).

If we contrast the above with xdotool, today, on X11, perhaps my confusion and wonder become more clear -- xdotool works with almost any window manager in X11 - typing, window movement, window search, etc. On Wayland, each compositor will need it's own unique implementation as shown above with kdotool which only works on Wayland+KDE, not GNOME or anything else.

The fragmentation is perhaps a natural outcome of Wayland promising to focus on the smallest replacement for X11, and that smallness elides a great deal of functionality. The missing features are actually still necessary, like screen sharing, and with no apparent central leadership or community, the outcome feels predictable. 

Of third-party Wayland protocols, there are just *so many* input-related protocols: input method v1, input method v2, text input v3, KDE fake input, and virtual keyboard. And that's just wayland protocols -- the KDE and GNOME XDG RemoteDesktop thingy isn't even wayland-related at all:

The weirdest thing I've learned, here, is the newer XTEST support in Xwayland. The component chain is really wild:

1. An X11 client sends a key event using XTEST (normal)
1. XWayland receives it and initiates Remote Desktop XDG Portal session to ... your own system (???)
1. XDG Portal uses DBus in an odd way, with many [method calls receiving responses via signals](https://flatpak.github.io/xdg-desktop-portal/docs/requests.html) because DBus isn't designed for long asynchronous methods.
1. Once the Remote Desktop portal session is setup, Xwayland [asks for a *file descriptor*](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.RemoteDesktop.html#org-freedesktop-portal-remotedesktop-connecttoeis) to talk an libei server (emulated input server).
1. After that, libei is used to send events, query the keyboard map, etc.
1. You can ask libei for the keyboard mapping (keycodes to keysyms, etc), [you get *another* file descriptor](https://libinput.pages.freedesktop.org/libei/interfaces/ei_keyboard/index.html#ei_keyboardkeymap) and process that with yet another library, libxkbcommon.

If [Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law) applies to this, then I *really* want to learn more of the system  (of people) that builds this kind of Rube-Goldberg device. Looking back, Wayland folks sent virtual input into the "never, because security!" dumpster bin, so is *this* the path that routes around those nay-sayers? Wild. 

(With respect, the documentation for libei is pretty nice, and I find the C code easy to read - I have no complaints there!)

I'm not alone in finding it very slow on the path to Wayland. Synergy only delivered [experimental support for Wayland](https://symless.com/synergy/download/release-notes/9) a year ago, 8 years after Fedora first defaulted to Wayland, and it only happened after GNOME and friends implemented this weird XDG Portal Remote Desktop thing plus libei which seemed to have landed in Xwayland around 2023-ish.

As I learned about libei and XDG Portal recently, I wrote some test code to send some keyboard events. Writing my own software, running on my own machine, GNOME still prompted me "Allow remote interaction?" with seemingly no way to permanently allow my own requests. I'm not the only one confused by GNOME and [KDE making such prompts](https://github.com/jordansissel/xdotool/issues/489).

Meanwhile, on X11, xdotool runs correctly and without restrictions... The fragmentation is upsetting for me, as the xdotool maintainer, because I *want* to make this work but am at a loss for how to proceed with all the fragmentation. I don't mind what the protocol is, but I sure would love to have *any* protocol that does what I need. Is it worth it to continue?


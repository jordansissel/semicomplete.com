+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2015-04-24T21:46:35-07:00"
title = " xdotool  -  fake keyboard/mouse input, window management, and more \n"
# Marked a draft because frankly my old writing may not be worth surfacing again.
# I made bad word choices and had some strong-and-closed opinions years ago.
# We learn over time, eh? :)
type = "projects"
categories = [ "projects" ]
+++

# What is xdotool? 

This tool lets you simulate keyboard input and mouse activity, move and
resize windows, etc. It does this using X11's XTEST extension and other
Xlib functions.

Additionally, you can search for windows and move, resize, hide, and modify
window properties like the title. If your window manager supports it, you
can use xdotool to switch desktops, move windows between desktops, and
change the number of
desktops.
  
# Mailing List

The xdotool users mailing list is: <a href="mailto:xdotool-users@googlegroups.com">xdotool-users@googlegroups.com</a>

I'll be announcing new versions on this mailing list. Additionally, if you
want help or want to contribute patches to xdotool, the mailing list is a
good place to go.

If you want to file a bug, you can do that on the [issue tracker](https://github.com/jordansissel/xdotool/issues).

# Prerequisites

* xlib (pkg-config xlib) - Standard Xlib library
* xtst (pkg-config xtest) - XTEST library

# Installing

Platform | Install Method 
---------|-----
Debian and Ubuntu | apt-get install xdotool 
FreeBSD | pkg install xdotool 
Fedora | dnf install xdotool 
OSX | brew install xdotool 
OpenSUSE | zypper install xdotool 
Source Code | [on GitHub](https://github.com/jordansissel/xdotool/releases) 

# Building From Source

* `make all install`
* `make test` (optional, requires ruby and Xvfb)

If the build fails, it might be because you don't have the required
libraries and header files installed. You will need to set install them,
and if you don't have pkg-config for x11 and xtst, set DEFAULT_LIBS and
DEFAULT_INC (see the Makefile) correctly.

If all else fails, please email the mailing list or file a bug.

# Using xdotool

Basic usage is: `xdotool <cmd> [args]`.

See `man xdotool` for more detailed usage.

# Examples

## Example: focus the firefox url bar

```
WID=`xdotool search "Mozilla Firefox" | head -1`
xdotool windowactivate --sync $WID
xdotool key --clearmodifiers ctrl+l

# As of version 2.20100623, you can do this simpler version of above:
xdotool search "Mozilla Firefox" windowactivate --sync key --clearmodifiers ctrl+l
```

## Example: Resize all visible gnome-terminal windows

```
WIDS=`xdotool search --onlyvisible --name "gnome-terminal"`
for id in $WIDS; do
  xdotool windowsize $id 500 500
done

# As of version 2.20100623, you can do this simpler version of above:
xdotool search --onlyvisible --classname "gnome-terminal" windowsize %@ 500
500
```
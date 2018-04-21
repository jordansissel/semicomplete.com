+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2010-10-14T23:49:21-07:00"
title = " keynav  -  retire your mouse. \n"
type = "projects"
categories = [ "projects" ]
+++

Keynav is a piece of an on-going experiment to
make pointer-driven interfaces easier and faster for users to operate. It
lets you move the pointer quickly to most points on the screen with only a
few key strokes.

Note that I said pointer, not mouse. The mouse simply drives the pointer.
We can drive the pointer with other devices too. keynav turns your keyboard
into an fast pointer mover.

# What does it do?

You select a piece of the screen. The screen is initially wholely selected.
One move will cut that region by half. A move is a direction: up, down,
left, and right.

Once you're done moving, you simply indicate (with a key stroke) that you
want to move. Boom, cursor moves.

# Why it is fast?

keynav is geared towards selecting a piece of the screen very quickly.

Recall from above that you are selecting a region by cutting the previous
region by half. This gives us logarithmic scaling. High resolution screens
incur about the same number of moves to select an area as smaller screens do.

For example, to select <i>any</i> pixel on a screen with resolution
1920x1200 it would take 21 moves. 21 moves is horrible. There is a bright side!

How often do you really want to click on a single specific pixel on your screen using your mouse? Never, right? Well, maybe almost never. Most of the time you want to:

* Raise a window and give it focus: 80x80 pixel target (worst: 9 moves)
* Click on an "OK" button: 60x25 pixels (worst: 11 moves)
* Click on a text widget to activate it: 80x25 or larger

# Mailing list

The keynav users mailing list is: keynav-users@googlegroups.com

I'll be announcing new versions on this mailing list. Additionally, if you
want help or want to contribute patches to keynav, the mailing list is a
good place to go.

# Supported Platforms

keynav is currently written in C and only works in X11 (Unix graphics
environment).

Known working:

* FreeBSD + Xorg 6.9.0
* FreeBSD + Xorg 7.2.0
* Ubuntu Dapper + Xorg 7.0.0
* Ubuntu Feisty + Xorg 7.2.0
* Ubuntu Hardy + Xorg 7.2.0
* Cygwin + Xorg 6.8.x
* Fedora 9

# Download it!

<a href="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/semicomplete/keynav-0.20110708.0.tar.gz">keynav-0.20110708.0.tar.gz</a><p></p>

Looking for an older version? Try the
<a href="http://code.google.com/p/semicomplete/downloads/list?q=label:keynav">keynav releases archive</a>

# Dependencies

* glib \>= 2.0
* libxdo (from xdotool) (or, if you build static, libX11 libXtst and libXext)
* Xinerama (comes with xorg) 
* XSHAPE (comes with xorg)

# Build instructions

`make keynav`

The above should be all you need to do. Keynav comes with xdotool (required
library) and will build static if libxdo.so is not found on your system.

* Debian users can install this package via apt-get install keynav
* FreeBSD users can install this from ports in x11/keynav

# How to use it

Run keynav, and activate it by pressing Control+Semicolon. You should see a
thin frame on the screen with a cross in it. 

The following is the default configuration:

* h : select the left half of the region
* j : select the bottom half of the region
* k : select the top half of the region
* l : select the right half of the region
* shift+h : move the region left
* shift+j : move the region down
* shift+k : move the region top
* shift+l : move the region right
* semicolon : Move the mouse to the center of the selected region
* spacebar : Move the mouse and left-click
* escape : Cancel the move

* Configuration file

Your config file must live in ~/.keynavrc. Such as /home/jls/.keynavrc

The config file format consists of a keysequence followed by a
comma-separated list of commands. For example:

```
space warp,click 1,end
```

This would move the mouse, click left mouse button, and finish (close the
keynav selector) when you hit spacebar while keynav was active. A sample
config file comes with the distribution as 'keynavrc'.

The following is a list of key modifiers: shift, ctrl, alt, or any valid X
Keysym, such as Shift_L, etc.

# Documentation

You can find the documentation for keynav as `keynav.pod` in the source, or by [viewing it online](https://github.com/jordansissel/keynav/blob/master/keynav.pod)
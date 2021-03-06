+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2010-05-11T01:59:47-07:00"
title = "Headless wrapper for ephemeral X servers\n"
type = "old"
categories = [ "old" ]
tags = ["xorg", "x11", "headless", "automation", "webdriver", "xdotool"]
aliases = [
    "/blog/geekery/headless-wrapper-for-ephemeral-xservers.html"
]
+++

For various projects I'm doing right now, I need an easy way to automatically
run code in an X server that may not necessarily be the active display. This code
may even run on servers in production that don't have video cards or monitors
attached.

For some history on this, check out <a
href="/blog/geekery/xvfb-firefox.html">this post on xvfb and firefox</a>. You
can solve the problem in that post by simply launching firefox with the tool
below, and your X server will exit when firefox exits.

To solve my need for automated headless Xserver shenanigans, I wrote a script
that will wrap execution with a temporary X server of your choosing. For
xdotool tests I generally use Xephyr and Xvfb.

What's so special about this script? It picks an unused display number
reliably and runs your command with that set as DISPLAY. This is a major win
because you don't have to pre-allocate X servers (headless or otherwise) before
you start your programs. ephemeral-x.sh will pick the first unused display,
just as binding a socket to port 0 will pick an unused port. Finally, when your process
exits, the xserver and windowmanagers are killed. Example usage:

```
% ./ephemeral-x.sh firefox
Trying :0

Fatal server error:
Server is already active for display 0
        If this server is no longer running, remove /tmp/.X0-lock
        and start again.

Trying :1
Xvfb looks healthy. Moving on.
Using display: :1
Running: firefox
```

It does health checks to make sure the X server is actually up and running
before continuing.

You can also specify a window manager to run:

```
% ./ephemeral-x.sh -w openbox-session firefox
...
Trying :1
Xvfb looks healthy. Moving on.
Using display: :1
Starting window manager: openbox-session
Waiting for window manager 'openbox-session' to be healthy.
... startup messages from openbox ...
openbox-session looks healthy. Moving on.
Running: firefox
```

The default X server is Xvfb. You can use Xvnc, Xephyr, or any X server. Here
we run Xephyr with some options:

```
% sh ephemeral-x.sh -x "Xephyr -ac -screen 1280x720x24" -w openbox-session firefox www.google.com
...
Xephyr looks healthy. Moving on.
Using display: :1
Starting window manager: openbox-session
Waiting for window manager 'openbox-session' to be healthy.
...
openbox-session looks healthy. Moving on.
Running: firefox www.google.com
```

Screenshot of what this looks like is here: 
[xephyr-ephemeral-x-example.png](/files/blogposts/20100511/xephyr-ephemeral-x-example.png)

I use this script to run my xdotool tests. Additionally, parallelizing test
execution can often lead to faster tests. Wrapping each test run with
ephemeral-x.sh ensure that each test suite runs in a clean environment,
untainted by any previous test, allowing me to run all test suites in parallel.
Prior to writing this script, I would run each test suite in serial on the same
X server instance.

I use a similar technique at work to start ephemeral X servers for running
WebDriver tests in hadoop. Each mapper starts its own X server, safely, and
kills it when it is completed. This is implemented in java, instead of shell,
since the mappers all launch from java and mapreduce launch differently than a
standard command would in your shell.

* Code lives here: [ephemeral-x.sh](https://github.com/jordansissel/xdotool/blob/master/t/ephemeral-x.sh)
* [xdotool tests](https://github.com/jordansissel/xdotool/blob/master/t)


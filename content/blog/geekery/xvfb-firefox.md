+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2006-04-08T03:53:00-07:00"
title = "Xvfb + Firefox\n"
type = "old"
categories = [ "old" ]
tags = ["web", "firefox", "X11", "ideas"]
aliases = [
  "/blog/geekery/xvfb-firefox.html"
]
+++

<a href="http://www.ejohn.org">Resig</a> has a bunch of unit tests he does to make sure <a href="http://www.jquery.com">jQuery</a> works properly on whatever browser. Manually running and checking unit test results is annoying and time consuming. Let's automate this.

##  Update (May 2010): 

See 
<a href="/blog/geekery/headless-wrapper-for-ephemeral-xservers.html">this
post</a> for more details on automating xserver startup without having to worry
about display numbers (:1, :2, etc).

---

Combine something simple like Firefox and Xvfb (X Virtual Frame Buffer), and you've got a simple way to run Firefox without a visible display.

Let's start Xvfb:

```
startx -- `which Xvfb` :1 -screen 0 1024x768x24

# Or with Xvnc (also headless)
startx -- `which Xvnc` :1 -geometry 1024x768x24

# Or with Xephyr (nested X server, requires X)
startx -- `which Xephyr` :1 -screen 1024x768x24

```


This starts Xvfb running on :1 with a screen size of 1024x768 and 24bits/pixel color depth. Now, let's run firefox:

```
DISPLAY=:1 firefox

# Or, if you run csh or tcsh
env DISPLAY=:1 firefox
```

Seems simple enough. What now? We want to tell firefox to go to google.com, perhaps.

```
DISPLAY=:1 firefox-remote http://www.google.com/
```

Now, let's take a screenshot (requires ImageMagick's import command):

```
DISPLAY=:1 import -window root googledotcom.png
```

Lets see what that looks like: <a href="http://www.semicomplete.com/images/googledotcom.png">googledotcom.png</a>

While this isn't complicated, we could very easily automate lots of magic using
something like the Selenium extension, all without requiring the use of a
visual display (Monitor). Hopefully I'll find time to work on something cool
using this soon.

Problems with screen scraping and other website interaction automation is that
it almost always needs to be done without a browser. For instance, all of my
screen scraping adventures have been using Perl. Browsers already know how to
speak to the web, so why reinvent the wheel?

Firefox has lots of javascript-magic extensions such as <a
href="http://greasemonkey.mozdev.org/">greasemonkey</a> and <a
href="http://www.openqa.org/selenium/">Selenium</a> to let you execute
browser-side javascript and activity automatically. Combine these together with
Xvfb, and you can automate lots of things behind the scenes.

Tie this back to unit tests. Instead of simply displaying results of unit tests,
have the page also report the results to a cgi script on the webserver. This
will let you automatically test websites using a web browser and have it
automatically report the results back to a server.

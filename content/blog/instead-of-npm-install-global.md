---
title: "Instead of `npm install -g`..."
date: 2022-12-09
---

We have some Sonos speakers at home, and I'd like my kids to be able to choose music when/where they like. The iOS Sonos app is somewhat labyrinthian, so I think, can I make a simple version of this? I figured a simple-ish web interface with buttons for their favorite albums and playlists. Could be fun?

With my eager eyes set on a goal to make a silly web app, I began reading through the [Ionic+Vue tutorial](https://ionicframework.com/docs/vue/your-first-app). Then I got very delayed by a small side quest. Hello! With ADHD, side quests are my entire life. :)

The Ionic tutorial provide the command to install the ionic command-line tool, nice! I am offered this:

> `npm install -g @ionic/cli@latest native-run cordova-res`

Immediately after this line, it has a long warning that reads:

> The -g option means install globally. When packages are installed globally, EACCES permission errors can occur.
>
> Consider setting up npm to operate globally without elevated permissions. See [Resolving Permission Errors](https://ionicframework.com/docs/developing/tips#resolving-permission-errors) for more information.

At this point, I'm barely done reading one page of text, and already, it's telling us that a command will fail! Not only that, it's saying I need to go embark on a side quest on a *different page*. This particular side quest has multiple choices, and of the choices, all will have side effects that impact things outside of my project, even non-ionic projects! Wild! What a challenge!

This scenario is hardly unique to any particular technology project, but I want to share how I think this is a problem, how we end up with documentation like this, and maybe how to solve it.

# Bad Habits

We (software developers) have a history of writing tooling that is bad specifically in that it often does not meet the expectations of the users and it also can mislead them. The experienced among us will have memorized ways to travel through the confusing or difficult parts of the system, and that memorization makes things feel normal. We forget how hard the system actually is to navigate.

I'm following a tutorial. I'm copy-pasting the commands. I shouldn't be failing!

And yet, here we are.

And I'm here, having a bad time, because instead of learning Ionic and Vue, my first step takes me deep in the historical entanglement of weird software issues.

If a new user has a bad time, it's a bug.

The fact that we have to call this out in our documentation? It's bad! "This is the recommended install technique, and we know it doesn't work most of the time"

I applaud this *being* documented, but I do not applaud this being necessary.

I've used a little bit of Node.js for a decade, and this error feels so common! The documentation says "Install with `npm install -g ...`" which then fails.

Workarounds are offered, for example, to use a node version manager \[screaming intensifies\] or `chown` some directories to be owned by you instead of root. They don't feel like good workarounds. Ruby has this problem too (bundler, rvm), as does Python (virtualenv, venv, etc). It's hardly unique to any particular system.

I hope we can move forward to a better position for ourselves as developers and for others as developers and users.

# A workaround, I suppose

Since `npm install` defaults (I think? always?) to installing to `node_modules` in the current directory, we can install ionic like this, almost exactly the way the docs suggest, except we omit `-g`:

```
% npm install @ionic/cli@latest native-run cordova-res
```

Now, the `ionic` command line tool will be in a path like `node_modules/<name>/bin/ionic` and in this case, it's `node_modules/@ionic/cli/bin/ionic`. We can run it:

```
% ./node_modules/@ionic/cli/bin/ionic version
6.20.4
```

It might not *feel* good to write this full path in the documentation, but I do feel it's better (and with zero side quests!) than the offered `npm install -g`-plus-caveats approach.

If we want to type less, we can add an npm script to our package.json:

```
{
  "scripts": {
    "ionic": "node_modules/@ionic/cli/bin/ionic"
  }
}
```

And now, we can run ionic via npm:

```
% npm run ionic version

> ionic
> node_modules/@ionic/cli/bin/ionic version

6.20.4
```

Feels better? I think? 

Zero side quests. No pitfalls to document. Hopefully it's a more successful path to travel?

# Why do we do this

I feel like we (developers, sysadmins, etc) get comfortable with tools such that we no longer notice the things which, to a newbie, are obvious miseries and confusions. The frustrating parts of our common tools start to feel normal.  We'll call it a "learning curve" and laugh at how steep the walls are.

When this happens, we forget the frustration and confusion that is baked into the tool or system.

I certainly am guilty of this habit of ignoring sharp edges that I've simply become accustomed to dodging them. It's this exact phemonenon which causes me to highly value newbies. Newbies have a special sensitivity to the rough edges, confusing aspects, and incomplete parts. This is a super power, and to squander it is a tragedy.

# Let's improve things.

Over my 20+ years in open source, I've run into countless scenarios where I am the new user. I bump into something confusing or frustrating. I think, "Maybe I'll ask for help or report that this is frustrating?" The next thing happens with predictability -- Community folk or maintainers, who have already internally normalized and forgotten about the frustrating aspects, will shape their answers to point blame at me for the failure. I am using a thing for the wrong purpose, or for the wrong reason, or if I just read the documentation one more time it'll all become clear, or that it works for them and can't fathom why it doesn't work for me.

That's why I keep telling folks: **If a new user has a bad time, it's a bug.**

I've had this exact phrase as a guide in Logstash and fpm, and I know that it's helped reduce frictions. This phrase is an invitation to a newbie that, before they can even ask a question or report a problem, a bad time is a bug, with that implicit acceptance that bugs are something we endeavour to resolve and improve. It matters.

If you assume this mindset and broadcast an invitation -- that the stumbling of a new user is a sign of something that needs improvement -- you open yourself to a world of opportunities to improve onboarding for new folks as well as reducing day-to-day frustrations that a system causes to even those who are fluent in a given system.

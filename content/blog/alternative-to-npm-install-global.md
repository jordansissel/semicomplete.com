---
title: "Alternative to `npm install -g`"
date: 2022-12-09
---

# Alternative to `npm install -g`

I was reading through the [Ionic+Vue tutorial](https://ionicframework.com/docs/vue/your-first-app) with eager eyes set on a goal of making a silly webapp. I still have that goal, but I took a small side quest.

The docs explain that you'll need to install the Ionic command-line tool, and offers this:

> `npm install -g @ionic/cli@latest native-run cordova-res`

Immediately after this line, it has a warning that reads:

> The -g option means install globally. When packages are installed globally, EACCES permission errors can occur.
>
> Consider setting up npm to operate globally without elevated permissions. See [Resolving Permission Errors](https://ionicframework.com/docs/developing/tips#resolving-permission-errors) for more information.

We're barely done reading one page of text in the docs and already it's telling us that a command will fail and to begin a side quest to go solve that command, that they told us to use that they also say will fail.

# Bad Habits

We (software developers) have a history of writing tooling that is bad specifically in that it often does not meet the expectations of the users and it also can mislead them.

I'm following a tutorial. I'm copy-pasting the commands. I shouldn't be failing!

And yet, here we are.

And I'm here, having a bad time, because I'm now on a side quest 10 seconds into this new game.

If a new user has a bad time, it's a bug.

The fact that we have to call this out in our documentation? It's bad! "This is the recommended install technique, and we know it doesn't work most of the time"

I applaud this *being* documented, but I do not applaud this being necessary.

I've used a little bit of Node.js for a decade, and this error feels so common! The documentation says "Install with `npm install -g ...`" which then fails.

Workarounds are offered, for example, to use a node version manager \[screaming intensifies\] or `chown` some directories to be owned by you instead of root. They don't feel like good workarounds. Ruby has this problem too (bundler, rvm), as does Python (virtualenv, venv, etc). It's hardly unique to any particular system.

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

Feels better? I think? Zero side quests. No warning of failures to document? Could be cool.

# Why do we do this

I feel like we (developers, sysadmins, etc) get comfortable with tools such that we no longer notice the things which, to a newbie, are obvious miseries and confusions.

I certainly am guilty of this habit of ignoring sharp edges that we've simply become accustomed to dodging.

That's why I keep telling folks: **If a new user has a bad time, it's a bug.**

If you assume this mindset and broadcast an invitation -- that the stumbling of a new user is a sign of something that needs improvement -- you open yourself to a world of opportunities to improve onboarding for new folks as well as reducing day-to-day frustrations that a system causes to even those who are fluent in a given system.

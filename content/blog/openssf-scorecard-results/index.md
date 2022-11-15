+++
title= "OpenSSF Scorecard evaluates my projects"
date= 2022-09-22T21:00:00-07:00
tags= ["infosec", "open source"]
draft= true
+++

Like so many things in business, it feels inevitable that we reduce everything to some numerical value through a kind of lossy information compression. Revenue, margins, etc. Risk gets quantized. Vulnerabilities get quantized. Once it's a quantity, there becomes an urge to monitor it, optimize it, and game it. At the speed of business these days(1), who has time to evaluate a vulnerability's impact on your operations when we can simply say "If it's got a score of 8 or higher, we take immediate action!"

In infosec lately, it's hard to not notice the focus by major corporations and security vendors on the "software supply chain" and this area is no more resistant than any other to being turned into a numbers game.

Let's take a look at OpenSSF's Scorecard which aims to quantize risk of a software project.
I will be using their scorecard software tool to evaluate my own projects specifically from the viewpoint of myself as a mostly-solo project maintainer.

In this evaluation, I used image id `621e8cfa2d59` from gcr.io/openssf/scorecard which at this time is 9 days old. I ran the following command to evaluate each repository:

```
docker run -e GITHUB_AUTH_TOKEN=... gcr.io/openssf/scorecard:stable --repo=github.com/jordansissel/<repo-name>
```

Here are the overall scores for each project:

* [eventmachine-tail](https://github.com/jordansissel/eventmachine-tail):  4.4 / 10
* [fex](https://github.com/jordansissel/fex):  4.5 / 10
* [fingerpoken](https://github.com/jordansissel/fingerpoken):  4.5 / 10
* [fpm](https://github.com/jordansissel/fpm):  5.4 / 10
* [keynav](https://github.com/jordansissel/keynav):  4.8 / 10
* [pleaserun](https://github.com/jordansissel/pleaserun):  4.7 / 10
* [ruby-arr-pm](https://github.com/jordansissel/ruby-arr-pm):  5.2 / 10
* [ruby-cabin](https://github.com/jordansissel/ruby-cabin):  4.6 / 10
* [ruby-flores](https://github.com/jordansissel/ruby-flores):  4.6 / 10
* [ruby-ftw](https://github.com/jordansissel/ruby-ftw):  4.2 / 10
* [ruby-grok](https://github.com/jordansissel/ruby-grok):  4.4 / 10
* [ruby-insist](https://github.com/jordansissel/ruby-insist):  4.5 / 10
* [ruby-stud](https://github.com/jordansissel/ruby-stud):  4.5 / 10
* [xdotool](https://github.com/jordansissel/xdotool):  5.2 / 10

The most common complaints by this tool are as follows:

## [Inactivity in past 90 days](https://github.com/ossf/scorecard/blob/2231d1f722454c6c9aa6ad77377d2936803216ff/docs/checks.md#maintained)

Does this correlate to risk? I'm guessing there's papers supporting this assumption, but I haven't read them at this time.

I'm not sure that modification rates are strongly correlated to risk especially for small projects which may aim to solve a problem, do so, and then become stable with low rates of change.

Inactivity is certainly something that feels easy to measure, but is it the right metric? Do we wish we were measuring response times instead?

## [Static Application Security Testing tool is not run](https://github.com/ossf/scorecard/blob/2231d1f722454c6c9aa6ad77377d2936803216ff/docs/checks.md#sast)

Ok, I had to look up what "static application security testing" means in this context because I wasn't sure what it meant. Static code analysis? Ahh, makes sense now.

The scorecard docs mention it can check for CodeQL, LGTM, and SonarCloud.

I glanced at CodeQL and honestly couldn't even figure out how I would use it on my own projects. Some kind of query language for finding vulnerabilities? But you have to write your own queries? This feels much more like a tool a dedicated product security team would use -- writing queries based on infosec policy and handing the tooling to the develper team? Hard to tell exactly.

I looked at LGTM, and the top of the website says "LGTM.com will be shut down in December 2022", so I suppose that's as far as I need to go on that tool.

SonarCloud has a free tier that says "your IDE and programming language covered", but the fool(?) that I am, I still use vim, and vim is not listed.

* [Branch protection not enabled](https://github.com/ossf/scorecard/blob/2231d1f722454c6c9aa6ad77377d2936803216ff/docs/checks.md#branch-protection)
* [No CII "Best Practices" badge detected](https://github.com/ossf/scorecard/blob/2231d1f722454c6c9aa6ad77377d2936803216ff/docs/checks.md#cii-best-practices)
* [No dependency update tool detected](https://github.com/ossf/scorecard/blob/2231d1f722454c6c9aa6ad77377d2936803216ff/docs/checks.md#dependency-update-tool)
* [Project is not fuzzed](https://github.com/ossf/scorecard/blob/2231d1f722454c6c9aa6ad77377d2936803216ff/docs/checks.md#fuzzing)
* [Security policy file not](https://github.com/ossf/scorecard/blob/2231d1f722454c6c9aa6ad77377d2936803216ff/docs/checks.md#security-policy)

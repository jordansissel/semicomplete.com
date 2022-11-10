+++
title= "GitHub: Finding changes since last release"
date= 2022-11-09T21:00:00-07:00
tags= ["project management", "github"]
+++

# Time for release!

It's an exciting time. Or, it should be. I want to do a release of fpm! However, there's some preparation I need to do before I can publish.

I need to make sure the changelog file is updated and accurate, and that means I need to know all of the changes made since the previous release. I don't mean the code changes, though. I mean what behaviors were changed? Who contributed to the change? Is a given change related to one or more open issues?

## Doing it by hand

For years, I've managed the fpm changelog by hand. I would use `git log` to show me all git commits from the previous release until now. For today, I would use `git log v1.14.2..main` to show me all git commits between the v1.14.2 release and main.

Now, a "git commit" isn't necessarily a meaningful unit of change. A pull request on GitHub may contain many commits! Further, a single git commit often has no reference to the issue it may have been solving, nor do they have a reference to the pull request that they are a part of.

So, I slowly travel the git history and take notes. After that's done, I will cross-reference with GitHub issues and PRs (pull requests) to improve those notes. In any given change, I will try to document a few things:

* what behavior has changed (a new capability? a bug fix?)
* what github issue and PR numbers are related to the change
* who contributed to the change

The "who" is important to me, and my definition of "contribute" is different than what GitHub uses. This will become important in the next section.

To me, a contributor is anyone who participated in the issue or PR. 

* Did you file the issue? That's a contribution. 
* Did you find the issue and comment on it? That's a contribution. 
* Did you send a code or documentation change that resolves the issue? That's a contribution.
* Did you test the change? That's a contribution.

## Let GitHub generate it?

## Write a script

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

In 2021, GitHub announced a way to [automatically generate release notes](https://github.blog/2021-10-04-beta-github-releases-improving-release-experience/). From the GitHub blog:

> Throughout the year, we spoke with maintainers about what they wanted to see improved in the release process. Without hesitation, every maintainer said the same thing, “Release notes.”

Also? Without hesistation, I would say "release notes" is high on my list of
things I'd love help with.

GitHub has documentation about [automating release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes) if you'd like to learn more.

The defaults seem pretty reasonable with two major sections, "What's changed" and "New contributors". The "What's changed" seems to be all PRs merged into the release branch ("main" in my case) since the previous release which, by default, GitHub uses  the "previous tag" which in most cases is likely the correct choice. "New contributors" is a nice way to welcome and highlight first-timer contributors.

An example "What's changed" looks like this:

```
* Call ERB.new correctly depending on the RUBY_VERSION by @jordansissel in https://github.com/jordansissel/fpm/pull/1897
```

This format seems to be, roughly: The PR title, the person who opened the PR, and a link to the PR. In cases of single-commit PRs, the PR title defaults to the first line of the git commit message.

Unfortunately, this doesn't make for a good changelog entry. For tools like fpm, the changelog should focus on the users, not developers. Developer-centric language is quite common in places developers might visit -- like git commit messages.

A significant part of fpm's release notes process is to represent every change in a language familiar and useful to the target audience, fpm's users. In many cases, individual changelog entries are quite long. Far longer than the you'd see in a git commit message's first line, in many cases, because Git and its ecosystem put strong pressure on having the first line of the commit be treated similar to an email subject line -- it should be very short.

This means that if we use GitHub's default release notes, I would have to edit every PR to replace the title with a user-centric language describing the change, impact, etc, which probably wouldn't even fit in a PR title.

Futher, GitHub's automatic release notes only credits the PR author, and, in a way, erases the contributions of everyone else who helped make that change happen.

Lastly, I try to include links to all related issues, not just the PR, and GitHub doesn't link to any of these in the generated notes.

I did like that automatic release notes can [be configured to](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes#configuring-automatically-generated-release-notes) generate sections (like breaking changes) depending on your PR labelling 

GitHub's *close* to something that works really well, but where it misses, for me:
* To GitHub, contributors are only people who make commits to git. This is incorrect.
* Git commit messages are not substitutes for user-focused writing
* It doesn't list related issues in the changelog

## What next?

With the idea that I might have to roll my own, or at least, I'd like to explore what rolling my own release notes tooling might cost me (in time and energy)... I've written a script that uses the GitHub API to fetch all pull requests merged since the previous release.

It's in ruby and uses the [octokit](https://github.com/octokit/octokit.rb) library. To start, I wanted to know all pull requests merged since the last release.

I wasn't able to figure out how to query a tag in GitHub's api. I was specifically looking for the date related to the tag (that is, the commit pointed to by the tag, what date it was committed). GitHub has a "get tags" API but you have to provide a git sha which isn't a predictable thing like a version number.

0. First step is local to my git repo. I need the timestamp of the git tag's commit. I do this with the `git` command line:

```
% git show -s --pretty=%cI v1.14.2
2022-03-31T00:09:25-07:00
```

In ruby, we can use the Time class to parse this format and get us a Time object.

```
after_date = Time.parse("2022-03-31T00:09:25-07:00")
```

1. First, we need to setup the octokit client.

```
client = Octokit::Client.new
client.access_token = ... # your github auth token
client.login
```

Note: Octokit has a feature called "autopaginate" where it will fetch all records for a given query. In this scenario, I do not enable auto-pagination because I don't need *all* pull requests, just the most recent ones matching my criteria -- ones merged since the last release. Running with auto-pagination is much slower especially when I don't need all that data.

2. Now we can list pull requests

List all pull requests which are closed; sorted by "updated" date, descending. 

```
result = client.pulls(repository, state: "closed", sort: "updated", direc    tion: "desc")
```

The `result` is an array of a weird class called "Sawyer::Resource". We can treat it as a hash. The actual content of this result seems undocumented by octokit, but we can read the GitHub API docs for the API call for [listing pull requests](https://docs.github.com/en/rest/pulls/pulls#list-pull-requests) which GitHub calls, slightly confusingly, the "pulls" api

3. Only show merged pull requests

GitHub "state" for a pull request is only "closed" or "open", there is no "merged" state, unfortunately. However, we're in luck that the pull request object has a "merged\_at" field which contains an ISO8601 timestamp for when it was merged.

```

done = false
while !done
  result.each do |pr|
    # Only look at merged PRs
    next unless pr.merged_at.to_i > 0

    if pr.merged_at > after_date
      puts "#{pr.html_url}    # #{pr.merged_at}"
    else
      done = true
      break
    end
  end

  break if done

  result = client.get(client.last_response.rels[:next].href)
end
```

It's not fancy, but it'll do. The rough steps were:

* Make sure the PR is merged. Not all closed PRs are merged.
* Check if the PR was merged after the previous release date
* If we aren't done, query the next page of results

4. Run it!

```
https://github.com/jordansissel/fpm/pull/1909    # 2022-11-10 06:43:35 UTC
https://github.com/jordansissel/fpm/pull/1946    # 2022-10-26 21:48:13 UTC
https://github.com/jordansissel/fpm/pull/1950    # 2022-11-03 04:49:17 UTC
https://github.com/jordansissel/fpm/pull/1948    # 2022-10-31 22:17:48 UTC
... [ output shortened for brevity ] ...
```

This printed out a url and timestamp for each PR. Nice.

## Next steps

At a minimum, this exploration helped me bypass the `git log ...` process which I very much did not enjoy. Using either GitHub's generator or my script, I now have a list of all relevant PRs for the project release.

I'll probably continue to do the changelog by hand, but at least it'll be less work! In the meantime, I'll look around for more tools which could help me automate some of this.

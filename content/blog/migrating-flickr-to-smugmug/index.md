+++
date = "2022-05-10T22:55:00-07:00"
title = "Moving from Flickr to SmugMug"
type = "old"
categories = [ "hacks", "photography" ]
tags = ["smugmug", "flickr", "json", "photography"]
+++

[ This post is a work in progress as I work towards solutions ] 

I received an email from Flickr on May 9.

> Subject: Your Flickr account is in violation of our free account limits.
>
> You have more than 50 non-public photos on your free account. 

They gave me 8 days to resolve it -- with the threat of deleting photos.
It's been a long time since I've used Flickr, but I don't want to lose the content I had uploaded.

It was difficult to even find out what photos, if any, were non-public.
I found a total count on Flickr's photo organizer and the number was in the thousands.
I didn't want to make thousands of decisions today. 

I would probably have payed for Flickr.
It's cheap and a nice service.
However, I've been using SmugMug already for two years for all my bug photos, and maybe it'll be worth moving my photos to SmugMug?
I don't know, but I wanted to try.

What do I want?
I want all my photos, photo data (image title, descriptions, etc), albums, etc, and to put them into the same organization in SmugMug.

First, I asked Flickr for [*all* of my data](https://www.flickrhelp.com/hc/en-us/articles/4404079675156-Downloading-content-from-Flickr).
This process took a few hours, and once done, showed 18 .zip files to download.
18 felt like a lot of files to download manually, and I was sure I would make errors, so I script my way to victory.

At the time of writing, Flickr posts the .zip file links in my account settings page.
From this page, I use my browser's Developer Tools console to list all the download links:

```
>> Array.from(document.querySelectorAll("a")).filter(el => el.textContent.includes("Download zip file") && el.href.includes("downloads.flickr.com")).join(" ")
```

This prints all the "Download zip file" link URLs to the console, separated by spaces.
I then pasted this list into a terminal for `wget` to download each one.
It just *happened* to work because Flickr does not use any authentication on these links, so anonymous access via wget downloads them happily.

After downloading, I had  18 `.zip` files.
One file was for my account information and included albums data.
The account information is many different files and all of them are in JSON format.
The other 17 files were all photos and videos.

I am thinking that I will need to create albums on SmugMug with the same structure as on Flickr and with the same photos. For each photo, It should have the same title and description as was on Flickr.

Some quick research found that SmugMug has a [published API](https://smugmug.atlassian.net/wiki/spaces/API/overview), but maybe I don't have to write any code.
I found a [command-line tool, smugcli](https://github.com/graveljp/smugcli) which seems promising. It could let me create galleries on SmugMug and upload photos as needed. 

Maybe I can accomplish this with a bit of json parsing and smugcli?

To be continued... ?

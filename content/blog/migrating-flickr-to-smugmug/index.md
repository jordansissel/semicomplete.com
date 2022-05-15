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

Here's what I ended up doing:

1. Login to Flickr and request [my data](https://www.flickrhelp.com/hc/en-us/articles/4404079675156-Downloading-content-from-Flickr).
2. Wait a while for Flickr to process this. You'll get an email when it's done.
3. Download all the files! 
4. Create one directory per Flickr album and sorting photos into their correct albums. To do this, I wrote a script.

Note about the files downloaded:

* "Account files" include your profile, comments, and album data. This also contains photo title, description, and other information as one file per photo.
* "Photos and videos" links will be a .zip file each containing some of your photos+videos. You'll want to download all of the zip files.

----

## Downloading My Photos and Albums

I want all my photos, photo data (image title, descriptions, etc), albums, etc, and to put them into the same organization in SmugMug.

First, I asked Flickr for [*all* of my data](https://www.flickrhelp.com/hc/en-us/articles/4404079675156-Downloading-content-from-Flickr).
This process took a few hours, and once done, showed 18 .zip files to download.
18 felt like a lot of files to download manually, and I was sure I would make a mistake and miss one, so I script my way to victory.

At the time of writing, Flickr posts the .zip file links in my account settings page.
From this page, I use my browser's Developer Tools console to list all the download links:

```
>> Array.from(document.querySelectorAll("a")).filter(el => el.textContent.includes("Download zip file") && el.href.includes("downloads.flickr.com")).join(" ")
```

This prints all the "Download zip file" link URLs to the console, separated by spaces.
I copied this list and wrote `wget ` into my shell and pasted the URL list.
It just *happened* to work because Flickr does not(*) use any authentication on these links, so anonymous access via wget downloads them happily.

(*) At time of writing, May 2022

After downloading, I had  18 `.zip` files.
One file was for my account information and included albums data.
The account information is many different files and all of them are in JSON format.
The other 17 files were all photos and videos.

## Sorting into Albums

After unpacking the zip files, I started looking at the contents. 

I couldn't find any documentation about the JSON files provided by Flickr.
I found a few Flickr forum posts where folks asked about the data inside these zip files, how to process them, etc.
After reading a few forum threads, I assumed I was on my own.
It was time to make some guesses about the structure!
Some guesses were easy, like a file called "albums.json" which contains album information :)

The structure of the "albums.json" file is basically `{ "albums": [ ... ] }` with one entry in the albums list for each album. For me, the interesting fields were "id", "title", "description", and "photos". The "photos" entry is a list of photo IDs as strings.

I thought, this would be easy! I assumed that for each photo ID there would be an obviously-named photo file like "ID.jpg", but it wasn't simple.
I found it was kind of difficult to predict the filename of the photo.

I had hoped that the file named `photo_ID.json` would tell me the exact filename, but nope! For example, for a photo with ID "23604932919", the photo metadata is in a predictable file named `photo_23604932919.json` but the photo itself is a file named `making-a-toddler-play-board_23604932919_o.jpg` -- and no, the photo file name doesn't appear anywhere in the json file.

After some trial and error, I made this method for finding a given photo file with a given ID:

1. The photo ID from the album list could be zero "0" which isn't a valid photo ID. There's nothing else to do but skip this photo entry.
2. The photo file could be a filename matching these wildcards `*ID_o.jpg`, `*ID.mov`, `*ID_o.png`, `*ID.m2ts`, `*ID.mp4`, or `*ID.avi`
3. Otherwise, we have to open `photo_ID.json` and read the "original" field which is a URL to the photo location on flickr.
4. The URL might point to a placeholder representing a [video processing failure](https://combo.staticflickr.com/pw/images/en-us/video-failure/k.png) which means you don't have any photo or video included for this photo ID. Something failed on Flickr's side.
5. If the URL points to a real photo, the last part of the URL will be the filename in your photos zip files. For example, if the url was `https://live.staticflickr.com/123/12345678901_0ab23f2345_o.jpg`, then the real filename in the photos zip is going to be `12345678901_0ab23f2345_o.jpg`

This whole discovery process was kind of fun, actually.
It reminded me of early web scraping tasks where there was basically no documentation about relationships between pages and content, and you had to make guesses and have somewhat complex checks in order to navigate.


I wrote a small script to process the albums and copy photos and photo metadata into one directory per album to take into account all of these weird scenarios.

## Uploading to SmugMug

I am thinking that I will need to create albums on SmugMug with the same structure as on Flickr and with the same photos. For each photo, It should have the same title and description as was on Flickr.

Some quick research found that SmugMug has a [published API](https://smugmug.atlassian.net/wiki/spaces/API/overview), but maybe I don't have to write any code.
I found a [command-line tool, smugcli](https://github.com/graveljp/smugcli) which seems promising. It could let me create galleries on SmugMug and upload photos as needed. 

Maybe I can accomplish this with a bit of json parsing and smugcli?

To be continued... ?

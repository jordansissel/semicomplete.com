+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2010-05-19T00:13:15-07:00"
title = " fex  -  flexible token-field extraction \n"
type = "projects"
categories = [ "projects" ]
+++


# What is fex?
Fex is a powerful field extraction tool. Fex provides a very concise
language for tokenizeing strings and extracting fields.

The basic usage model is that you provide a series of delimiter and field
selection pairs. Tokens can be any character, while field selections have a
specific syntax.

# Download

Releases are available on [GitHub](https://github.com/jordansissel/fex/releases).

# Sometimes simpler than cut and awk

cut(1) from GNU coreutils (on Linux) does not support negative offsets, so
you cannot ask cut to only show you the Nth field from the end.
Additionally, to cut by multiple fields, you end up having to write
`cut ... | cut ... | cut  ...`


awk lets you select negative offsets using the NF variable. Get the 2nd to
last field with $(NF - 1). However, cutting multiple times still requires
multiple awk invocations or using awk's split() function multiple times.

# Field selection

There are a few ways to specify field selections.
* Just a number, picks the Nth field.
* Comma-separated list inside curly braces selects individual fields: {1,3,7}
* Colon-delimited range, inside curly braces: {N:M}. Examples: {1:3}, {1:}, or {:3}. If no M is specified, {N:}, then the range is from N to the end. If no N is specified, {:M}, then N is assumed to be 1 (start of the string). If no N or M is specified, {:}, it behaves as selecting the entire string
* You can combine any of these together, such as this syntax: {1,4:7} picks field 1 and 4 through 7 inclusive

Notes:
* Negative numbers treated as a negative offset against the end of the string
* The number '0' is special and means the entire string, as is {:}
* Fields selected in multiple will be joined by the original field separator. That is, selecting /{1,4,7} will result in fields 1, 4, and 7 output with a '/' delimiter in between.


# Tokenizing behavior

The default behavior is to ignore empty fields. That is, a string
"foo...bar" would only have two fields when split by "." rather than four.
If you want fex to not ignore empty fields, you should prefix your field
selection with "?"

Greedy (default)

```
% echo "foo.....bar..baz.fizz" | fex .2
bar
```

Nongreedy

```
% echo "foo.....bar..baz.fizz" | fex '.{?6}'
bar
```

# Command line arguments

You can specify multiple, independent field selectors on the command line.
Each argument is treated as a standalone field selector. Selectors are
split by spaces on output (though I am open to changing this).

For example, output the IP and URL from an apache request log:

```
echo '208.36.144.8 - - [22/Aug/2007:23:39:05 -0400] "GET /svnweb/logwatch/tags/?pathrev=420 HTTP/1.0" 200 3595' \
| fex 1 '"2 2'

208.36.144.8 /svnweb/logwatch/tags/?pathrev=420 
```

# Usage Examples

## Simple splitting

With input text: `/usr/local/bin/firefox`

Command | Result
----|---
`fex /1` | "usr"
`fex /{2:3}` | "local/bin"
`fex /{1,-1}` | "usr/firefox"
`fex /-1` | "firefox"
`fex /{:}` | "/usr/local/bin/firefox/
`fex /0` | "/usr/local/bin/firefox/

## Greedy vs nongreedy splitting

Input text: `a:b::c:::d`

Command | Result
---|---
`fex :{1:3}` | "a:b:c"
`fex :{?1:3}` | "a:b:"
`fex :{3}` | "c"
`fex :{?3}` | "" (empty result)

# Real world uses

## Parse IP and URL from apache logs

```
% fex 1 '"2 2' &lt; /b/logs/access| head
65.57.245.11 /
65.57.245.11 /icons/blank.gif
65.57.245.11 /icons/folder.gif
65.57.245.11 /favicon.ico
65.57.245.11 /semicomplete/
65.57.245.11 /style.css
65.57.245.11 /images/semicomplete.png
65.57.245.11 /
65.57.245.11 /style.css
65.57.245.11 /images/semicomplete.png
```

## Show paths from strace

Show files found with strace:

```
% strace -e trace=file cat /etc/motd |&amp; fex '"2'
/bin/cat
/etc/ld.so.nohwcap
/etc/ld.so.preload
/etc/ld.so.cache
/etc/ld.so.nohwcap
/lib/libc.so.6
/etc/motd
```

## Show home directory root paths

Here's a simple example, to find which root directories contain home directories:

```
% fex ':-2/1' &lt; /etc/passwd | sort | uniq -c
      3 bin
      1 dev
      4 home
      2 nonexistent
      1 root
      2 usr
     14 var
```

The string '0:-2/1' means:

* : - split by colons
* -2 - take the 2nd to last token, "/root"
* / - split that by "/"
* 1 - take the 1st token, "root"

The output is essentially the root directory for everyone's home directories.
Doing this in awk, cut, perl, or any other tool would be much more typing.

You can also specify multiple field extractions on a single invocation:

```
# Take the first and 2nd to last token split by colon
% fex :1 :-2 &lt; /etc/passwd
root /root
daemon /usr/sbin
bin /bin

# Alternatively, {x,y,z,...} syntax selects multiple tokens
# note that the output is joined by colons.
# Again, this is a feature unavailable in xapply's subfield extraction
% fex ':{1,-2}' &lt; /etc/passwd
root:/root
daemon:/usr/sbin
bin:/bin
```
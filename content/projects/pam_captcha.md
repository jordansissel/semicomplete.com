+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2010-07-16T00:13:21-07:00"
title = " pam_captcha  -  A Visual text-based CAPTCHA challenge module for PAM \n"
draft = true
type = "projects"
categories = [ "projects" ]
+++

# pam_captcha

Version 1.5 (July 2010)

Released under the BSD license. 

If you use or make changes to pam_captcha, shoot me an email or something. I
always like to hear how people use my software :) And no, you don't have to
do it. Nor do you have to send me patches, though patches are appreciated.

Requirements:

- Figlet
- OpenPAM or Linux-PAM (Linux and FreeBSD known to work)

Notes: 

- I have tested this in FreeBSD and Linux. It works there.
- It will not build under Solaris 9, and I have no intentions of
    fixing that at this time

Installation Instructions

- Just type 'make' (assuming you downloaded the Makefile too)
- Copy pam_captcha.so to your pam module dir.
  - FreeBSD: /usr/lib
  - Ubuntu: /lib/security
  - Others: Find other files named 'pam_*.so'

  - Place this entry in your pam config for whatever service you want. It
    needs to go at the top of your pam auth stack (first entry?):
 
```
auth       requisite     pam_captcha.so    [options]
```


Available options: math, dda, randomstring
Example:

- Enable 'math' and 'randomstring' captchas:

`    auth       requisite     pam_captcha.so    math randomstring`

'requisite' is absolutely necessary here. This keyword means that if a user
fails pam_captcha, the whole auth chain is marked as failure.  This ensure
that users must pass the captcha challenge before being permitted to attempt
any other kind of pam authentication, such as a standard login. 'required'
can work here too but will not break the chain. I like requisite because you
cannot even attempt to authenticate via password if you don't pass the
captcha.

IMPORTANT SSHD_CONFIG NOTE!
> To prevent brute-force scripts from bypassing the pam stack, you MUST
> disable 'password' authentication in your sshd. Disable 'password' auth
> and enable 'keyboard-interactive' instead.
>
> To do this, put the following in your sshd_config
> PasswordAuthentication no
> ChallengeResponseAuthentication yes

If you use ssh keys to login to your server, you will not be bothered by
pam_captcha becuase publickey authentication does not invoke PAM.

# Download

[Download pam_captcha-1.5](http://semicomplete.googlecode.com/files/pam_captcha-1.5.tar.gz)

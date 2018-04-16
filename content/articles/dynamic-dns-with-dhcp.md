+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2006-04-17T02:42:39-07:00"
title = "Dynamic DNS and DHCP - Easy to do, and you'll thank yourself later\n"
type = "article"
categories = [ "article" ]
+++

# Preface
This article will cover how to setup dns with dynamic updates aswell as
configuring your dhcp server to push updates to it aswell.
    
I assume you already know how to setup plain old dns aswell as plain old
dhcp. This is not an introduction to either of those. I used BIND 9 and 
ISC DHCPD v3 for this article.

If there's anything this article doesn't cover with respect to what you
are looking for, leave a comment and I'll do what I can.

# What is Dynamic DNS?

Dynamic DNS is the means by which to push new records into your dns
server while it is running, without having to edit any zone files. It is
quite often coupled with dhcp to provide dynamic network services that
have hostnames follow the appropriate machines around.

# Dynamic DNS

Setting up dynamic dns is pretty straight forward. To do it securely, you
need to first create a secret key. This secret key will be used to
authenticate our dns update clients with the dns server. Luckily for us,
there's a tool that'll do that for us.

# Create a dnssec key

That tool is called `dnssec-keygen`. Don't feel like reading
the manpage? Fine. `dnssec-keygen` is a tool to create dnssec
keys, much like ssh-keygen creates ssh keys. Pick a name for your key,
it can be any name. I usually name it appropriately. For this example, I
will call our key <i>dhcpupdate</i>.

Create the key as such:

```
% dnssec-keygen -a hmac-md5 -b 128 -n USER dhcpupdate
Kdhcpupdate.+157+14638
```

This will create a 128bit HMAC-MD5 keyfile called <i>dhcpupdate</i>.

The output is the file prefix. If you do `ls Kdhcpupdate*`
you will see two files. The .key file is most useful, in my opinion.
Looking at the .key file:

<pre>
dhcpupdate. IN KEY 0 3 157 N8Hk2RUFO84bEVl3uGTD2A==
</pre>

No, that is not the key I use. No, you shouldn't use that key for your
server ;) 

The last token in that file is the key (<i>N8Hk...</i>). Keep that
secret.  Forever.

# named.conf changes

The updates to named.conf are pretty straightforward. For every zone you
want to allow dynamic updates (for this specific key), you need to add
an `allow-update` section. First, you'll want to add a
`key` section. The following goes in the global portion of
your `named.conf`:

```
key dhcpupdate {
algorithm hmac-md5;
secret "YOURKEYGOESHERE";
# example:
# secret "N8Hk2RUFO84bEVl3uGTD2A==";
};
```

Simple enough. Just remember that it goes in quotes!

Next, we need to add `allow-update` entries to all zones we
would like to update. Let's say I have two zones:

* home
* 0.168.192.in-addr.arpa

In my named.conf, I'll want to add the following to those zone
declarations:

```
allow-update { key dhcpupdate; };
```

For example:

```
zone "home" {
    type master;
    file "master/db-home"
    allow-update { key dhcpupdate; };
};

zone "0.168.192.in-addr.arpa" {
    type master;
    file "master/db-home_rev";
    allow-update { key dhcpupdate; };
};
```

That's all we have to do. Restart named and you should be able to push
updates dynamically to the dns server. 

# Testing with nsupdate

nsupdate is the tool we'll be using to test if we have setup the server
correctly. nsupdate takes commands like nslookup does, if run without
arguments:

```
% nsupdate
>
```

The following commands are good to know:

* `server [server address]` Sets the target server for who to send updates
* `key [keyname] [secret]` Tell nsupdate what your key is 
* `zone [zonename]` Explicitly choose a zone to send updates for. If unspecified, nsupdate will guess. 
* `update [...]` Request an update to record 
* `send` Send updates 
* `show` Show updates that haven't been sent 

`update` will not update the dns server automatically. It will queue the update request until you tell nsupdate to `send`.

For this example, my dns server is `dns.home`:

```
% nsupdate
> server dns.home
> key dhcpupdate N8Hk2RUFO84bEVl3uGTD2A==
> zone home
> update add 50.0.168.192.in-addr.arpa 600 IN PTR happynode.home.
> send
> update add happynode.home. 600 IN A 192.168.0.50
> send
```

If all goes well, there will be nothing printed after you type
`send`. Let's check that we've added it!

```
% host happynode.home
happynode.home has address 192.168.0.50
% host 192.168.0.50
50.0.168.192.in-addr.arpa domain name pointer happynode.home.
```

You can delete entries from dns with (for example):

```
update delete happynode.home
```

However, if something went wrong:

`update failed: NOTZONE` 

The above message means you didn't specify a hostname the dns server has zone information for. Make sure you're using a full domain name. That is, do not use <i>happynode</i>. Use <i>happynode.home.</i>

```
; TSIG error with server: tsig indicates error<br>
update failed: NOTAUTH(BADSIG)
```

The above message means you are providing the wrong key, or the server is refusing your key for another reason.

```
update failed: SERVFAIL
```

The number one cause for this error (for me) is permissions in the directory of your zonefile. Dynamic updates will create a journal file as: `/etc/namedb/home/home.jnl` (or wherever your zonefile is). If the user named is running as cannot create files in `/etc/namedb/home` then it will fail. This error should show up as 'permission denied' errors in the logs with a reference to what file it is trying to create. 

Worst case, run named with a high debug level. Also, don't reload
named, restart named when debugging. Reloading doesn't reinitialize
some things.

# DHCPD

A few minor changes are necesary to your dhcpd.conf (isc dhcp3 server). First, in the global portion:

```
ddns-update-style interim;

# If you have fixed-address entries you want to use dynamic dns
update-static-leases on;
```

Furthermore, you need to tell dhcpd.conf about the dnssec key and zone information. The following still goes in your dhcpd.conf:

```
key dhcpupdate {
    algorithm hmac-md5
    secret N8Hk2RUFO84bEVl3uGTD2A==;
}

zone 0.168.192.in-addr.arpa {
    primary dns.home;
    key dhcpupdate;
}

zone 10.168.192.in-addr.arpa {
    primary dns.home;
    key dhcpupdate;
}

zone home {
    primary dns;
    key dhcpupdate;
}
```

*NOTE!* Notice that the secret is entered WITHOUT QUOTES. Doing so with quotes is a syntax error. If you see errors about invalid base64 characters, this is likely the reason.

The `primary` values are the primary dns server entries so dhcpd knows where to send updates. In this case, my primary dns is `dns.home`. Yours will obviously vary, as your key should vary.

Next, I'll show you a few different examples.

## Sample entry without fixed-address (roamer)

```
host happylaptop {
    hardware ethernet 00:0a:39:22:da:39;
    option host-name "happylaptop";
    option domain-name "home";
    ddns-hostname "happylaptop";
    ddns-domain-name "home";
}
```

When `happylaptop` requests an address via dhcp, the dhcp server will tell the dns server. Specifically, it will push forward (A) and reverse (PTR) lookup entries. Excellent. Now I can access my laptop from the network without having to lookup, find, or discover it's IP address, becuase I can simply point at `happylaptop.home` and it resolves to my laptop, wherever it is.

## Sample entry set with 'group'

```
group {
    option domain-name "home";
    ddns-domainname "home";

    host happylaptop {
        hardware ethernet 00:0a:39:22:da:39;
        option host-name "happylaptop";
        ddns-hostname "happylaptop";
    }

    host dellstation  {
        hardware ethernet 00:b1:48:2a:ad:9c;
        option host-name "dellstation";
        ddns-hostname "dellstation";
    }
}
```

## Sample fixed-address

```
host jukebox {
    hardware ethernet 01:d0:06:b8:68:34;
    fixed-address 192.168.0.5;
    ddns-hostname "jukebox";
    ddns-domain-name "home";
    option host-name "jukebox";
    option domain-name "home";
}
```

That should be a decent set of examples.

# dhcpd.conf caveats

1. The option, `use-host-decl-names` does **NOTHING** (it seems?) to aid in automatic specification of `ddns-hostname`. This is weird. If you find otherwise, let me know.
2. You must specify ddns-hostname and ddns-domainame. dhcpd will not "figure it
out" if you just specify host-name and domain-name.
3. I don't know how to get dynamic-generated roamer addresses working, if it's possible. That is, I want to specify a range of roamers in 192.168.0.160/27, and want dhcpd to autogenerate dns names for those based on a given pattern. Possible? Perhaps not.
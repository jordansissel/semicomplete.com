---
title: "systemd journal forwarding"
date: 2026-11-13T15:00:00-08:00
tags: ["systemd", "journald"]
---

I've been working on software to make it faster to do local system reimaging. In order to make it easier to troubleshoot problems, I wanted to have local logs forwarded to another system.

As I am currently relying on cloud-init images, most of the system logs are already going to systemd's journal, but how can I forward the journal to a remote system? Systemd already provides a tool, `systemd-journal-upload`. However, Fedora pushes this program into a separate package and also does not include it in their Cloud images. 

I want logs available as early as possible in the boot cycle, and that means I can't wait until after installing any necessary packages.

On systemd, the usual data flow will be as follows:
* A client exports its logs with `systemd-journal-upload`.
* And server receives exported logs with `systemd-journal-remote`.

Journalctl offers an output format called `export` which emits the same format that the receiver (systemd-journal-remote) expects, however, that receiver expects data uploaded over http.

## DIY forwarding systemd journal

`systemd-journal-upload` is not available, so I found a simple workaround: pipe `journalctl` to `curl`. Some caveats: systemd-journal-remote rejects requests with incorrect `Content-Type`. Exporting a local systemd journal to a remote receiver, then, can be done like this:

```shell
journalctl --boot --lines=all -fo export | curl -v -T - -H "Content-Type: application/vnd.fdo.journal" -X POST http://REMOTE_HOST/upload'
```

Notably, for journalctl:
* `--boot` and `--lines=all` tells journalctl to send every log since boot.
* `-f` tells journalctl to follow the journal watching for future log messages
* `-o export` changes the output to the export foramt

And, for curl:
* `-T -` tells curl to upload from stdin
* `-X POST` sets POST as the http method (the default for `-T` uploads is PUT which is rejected by systemd-journal-remote)
* The path `/upload` is required and others are rejected by systemd-journal-remote.

Putting that together, you'll get journalctl reading, from boot and onward, all journal messages and shipping that to a remote receiver.

## Integrating with cloud-init

cloud-config's "bootcmd" list runs very early in cloud-init. You can see your distro's actual order in `/etc/cloud/cloud.config`. On Fedora 44's Cloud image, `bootcmd` is the second module run and is a perfect place to launch the forwarder.

The forwarder shouldn't block cloud-init, though, so I decided to run it as a systemd service using `systemd-run`:

```shell
{
  "bootcmd": [
    "systemd-run -u journal-forwarding --system sh -c 'journalctl --boot --lines=all -fo export | curl -v -T - -H \"Content-Type: application/vnd.fdo.journal\" -X POST http://REMOTE_HOST/upload'",
	],
	...
}
```

(Yes, I use JSON for my cloud-config files)

Like magic, cloud-init begins shipping the systemd journal almost instantly after systemd starts.

## Reading the logs

On my receiver system, I run `systemd-journal-remote` and save logs somewhere in /tmp/z, for lack of a better place to dump these things:

```
/usr/lib/systemd/systemd-journal-remote --listen-http=0.0.0.0:29146 -o /tmp/z/
```

And to read them, you pass the `-W /tmp/z` flag to journalctl. As an example, if a machine fails cloud-init, I can read the entire boot log by doing:

```shell
journalctl -D /tmp/z -b | less
```


The `-b` flag shows all logs from the most recent boot of journal files in `/tmp/z`.


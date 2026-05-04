---
title: "Debian 13 boot loop on qemu"
date: 2026-05-03
---

Everything was going nicely until Debian 13 was stuck in a boot loop. Qemu repeated the following, endlessly blinking in my terminal:

```
Booting `Debian GNU/Linux'

Loading Linux 6.12.85+deb13-amd64 ...
```

Why?

I'm developing a tool to help me build desktop VM images to help me debug weird issues specific to certain Linux distributions. For this project, I'm starting with  each linux distro's cloud image and booting it in a virtual machine using qemu-kvm.

Instead of learning each distro's bespoke installation tooling, I'm relying on cloud-init to configure my vm disk images. For the most part, this is going pretty well! The main benefit of cloud-init is that it is basically the same across all Linux distros, though it isn't without problems (but what is?). For example, some distros have different module orders and stages; Fedora calls the [set passwords](https://docs.cloud-init.io/en/latest/reference/modules.html#set-passwords) module during the "init" stage, while Debian puts it in the "config" stage. Some modules are vendor-specific, such as [landscape](https://docs.cloud-init.io/en/latest/reference/modules.html#landscape), and those are easy to avoid. For custom commands, it could be anyone's guess for when these will be executed - `bootcmd`, `runcmd`, and `scripts_per_once` - and fortunately, it seems like distros are consistent here, even if it is confusing.

Today's experiment added Debian support. Debian 12 installed and booted happily into GNOME and KDE.

Installing Debian 13 succeeded (cloud-init's first run). However, the first boot of this fresh install failed in a fun way: A boot loop, repeating  that 'Booting Debian GNU/Linux' over and over in a crash loop.

No other error messages. Qemu didn't offer any useful reports, either.

Some quick internet research suggested this was a UEFI-related problem. The fix is to attach a UEFI firmware from OVMF using the following qemu flag:

```
-pflash /usr/share/OVMF/OVMF_CODE.fd
```

This path was provided by the `edk2-ovmf` package on my Fedora 42 workstation.

After finding this flag, I stopped further research, because my Debian 13 images were now working. Interestingly, this flag was not necessary for Fedora 43, Ubuntu Noble, and Resolute. I can confirm that this flag doesn't break anything, so I'm leaving it enabled until I find it causes problems.

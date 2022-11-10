---
title: "xboxproxy: LAN games with distant friends"
date: 2022-11-04T23:00:00-07:00
tags: []
draft: true
---

outline:

* Friends graduating, still want to play Halo together.
* Sniff network to learn how xbox discovery protocol works
* libpcap to capture packets, forward over udp to known receiver
* keep track of which proxies are known
* forward all broadcast and multicast to known proxies over udp
* receiving over udp, dump it on the network

---
layout: post
lang: en
read_time: true
show_date: true
title: "Practical Network Debugging Tools for a Linux Server"
date: 2025-11-19
description: Notes on using ping, traceroute, curl, dig, and ss to narrow down service and network failures.
tags: [devops, networking, dns, troubleshooting, ubuntu]
author: Juwon
permalink: /en/NetworkingTools.html
---

## Why these tools matter

When a site does not open, guessing wastes time. Basic network tools help narrow the failure from "the service is broken" into a smaller question: DNS, routing, firewall, port binding, HTTP response, or application behavior.

## Tool checklist

`ping` checks basic reachability, but it is not proof that a web service is healthy. Many systems block ICMP.

`traceroute` shows the route packets take across networks. It is useful when traffic dies before reaching the server.

`curl` tests the actual HTTP layer:

```bash
curl -I https://example.com
```

This can confirm status code, redirects, TLS behavior, and whether Nginx is responding.

`dig` checks DNS:

```bash
dig example.com
```

This answers whether the domain resolves to the expected address.

`ss` checks listening ports on the server:

```bash
ss -lntp
```

This shows whether a process is actually listening on ports such as `80`, `443`, or an internal app port.

## Debugging order

The useful order is:

1. Does DNS point to the right place?
2. Does the server accept traffic on the expected port?
3. Does Nginx respond?
4. Does Nginx reach the backend?
5. Does the app return the expected response?

This gives every incident a path instead of a panic.

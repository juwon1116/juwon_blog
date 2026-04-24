---
layout: post
lang: en
read_time: true
show_date: true
title: "Understanding Firewalls with AWS Security Groups and UFW"
date: 2025-11-21
description: A practical explanation of how AWS Security Groups and Ubuntu UFW divide responsibility around an EC2 web server.
tags: [devops, networking, firewall, aws, ubuntu]
author: Juwon
permalink: /en/Firewalld.html
---

## Two firewall layers

On an EC2 server, traffic is usually controlled by at least two layers:

- AWS Security Group at the cloud network boundary.
- UFW on the Ubuntu instance.

Both can block traffic, but they operate at different places.

## Security Group

A Security Group decides which traffic is allowed to reach the instance from the AWS side.

Common web server rules:

- `22/tcp` only from a trusted IP for SSH.
- `80/tcp` from anywhere for HTTP.
- `443/tcp` from anywhere for HTTPS.

If a port is blocked here, the request never reaches Ubuntu.

## UFW

UFW is the host-level firewall. It controls what the operating system allows after traffic reaches the instance.

This gives a second boundary:

```bash
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

UFW is useful because it keeps host policy visible even when cloud rules change.

## Debugging rule

When traffic fails, check from outside to inside:

1. DNS points to the instance.
2. Security Group allows the port.
3. UFW allows the port.
4. A process is listening on the port.
5. The application responds correctly.

That order prevents confusing a firewall issue with an application issue.

---
layout: post
lang: en
read_time: true
show_date: true
title: "First Notes on Django Performance Monitoring"
date: 2025-11-19
description: A first monitoring checklist for watching CPU, memory, response behavior, and service stability on a Django server.
tags: [devops, monitoring, performance, django, ubuntu]
author: Juwon
permalink: /en/PerformMoni.html
---

## What performance monitoring means here

Process monitoring answers whether a service is alive. Performance monitoring asks a different question: how well is it behaving while it is alive?

For this first pass, I focused on a small set of signals that are easy to observe on an Ubuntu server.

## CPU usage

CPU shows whether the server is under pressure from active work. `htop` is a useful first view because it makes spikes, load, and process-level usage easy to scan.

```bash
sudo apt-get install htop
htop
```

High CPU is not always bad. The question is whether the usage matches expected traffic and whether it stays high after the request load drops.

## Memory usage

Memory matters for Django because workers, database clients, and background processes can grow over time. The key check is whether memory rises and returns to a stable range or keeps climbing.

Useful commands:

```bash
free -h
ps aux --sort=-%mem | head
```

## Response checks

A service can look healthy at the process level but still respond slowly. `curl` gives a quick HTTP-level view:

```bash
curl -I https://example.com
```

For deeper work, response time, error rate, and logs need to be collected over time.

## Takeaway

The first monitoring habit is to separate server pressure from application behavior. CPU and memory explain what the machine is feeling. HTTP checks and logs explain what users are experiencing.

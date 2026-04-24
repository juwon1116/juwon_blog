---
layout: post
lang: en
read_time: true
show_date: true
title: "Text Processing with Nginx Logs"
date: 2025-11-21
description: A terminal-focused note on using Linux text pipelines to inspect Nginx access logs.
tags: [devops, linux, nginx, logs, text-processing]
author: Juwon
permalink: /en/Text_Manipulation.html
---

## Why text processing is a DevOps skill

Server work produces text everywhere: logs, command output, config files, status pages, and error messages.

Being able to cut, filter, sort, and count that text directly in the terminal is a practical debugging skill.

## Example goal

The sample task was to find the top requester IPs in an Nginx access log.

Nginx access logs usually contain one request per line with fields such as:

- client IP
- timestamp
- HTTP method and path
- status code
- response size

## Pipeline shape

A common pipeline is:

```bash
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head
```

Each stage does one job:

- `awk` extracts the IP field.
- `sort` groups equal values together.
- `uniq -c` counts repeated values.
- `sort -nr` orders by count.
- `head` keeps the largest entries.

## Why this is useful

This kind of command gives a fast signal before setting up a larger log platform. It can show noisy IPs, unexpected traffic patterns, or whether one client is producing most requests.

The bigger lesson is the pipeline mindset: small tools connected together often answer operational questions quickly.

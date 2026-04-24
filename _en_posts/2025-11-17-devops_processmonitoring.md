---
layout: post
lang: en
read_time: true
show_date: true
title: "Monitoring a Django Process with systemd and cron"
date: 2025-11-17
description: A practice note on running a Django process under systemd and checking it regularly with a cron-driven script.
tags: [devops, django, systemd, monitoring, cron]
author: Juwon
permalink: /en/devops_processmonitoring.html
---

## Goal

The goal was to stop treating a Django development server as a manually started process and instead make it observable from the operating system.

The practice setup had three parts:

- Register the Django command as a `systemd` service.
- Write a status-check script.
- Run the check on a schedule with `cron`.

For production, Django should normally run behind Gunicorn or Uvicorn with a reverse proxy. This exercise was about learning process supervision and monitoring mechanics.

## systemd service

The important idea is that `systemd` owns the process lifecycle. It can start the service at boot, restart it on failure, and expose status through one consistent command:

```bash
systemctl status quizai.service
```

That is better than remembering which terminal session started the server.

## Health check script

The check script looked at whether the process was running and whether the expected port responded. This split is useful:

- A process can exist but not serve traffic.
- A port can fail even when the service looks active.

Both checks matter when debugging a web service.

## cron schedule

`cron` made the check repeat automatically. The result was a small monitoring loop:

```text
cron
  -> status script
  -> systemd/service check
  -> log result
```

The main lesson was that monitoring starts with boring checks. Before dashboards and alert systems, the process needs a clear owner, a health signal, and a repeatable check path.

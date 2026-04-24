---
layout: post
lang: en
read_time: true
show_date: true
title: "Monitoring Lab: Prometheus, Grafana, and Alertmanager"
date: 2026-01-16 23:59:00 +0900
description: An end-to-end local monitoring lab with Prometheus scraping metrics, Grafana dashboards, and Alertmanager email notifications.
tags: [devops, prometheus, grafana, alertmanager, monitoring]
author: Juwon
github: JuWunpark/juwon_blog
permalink: /en/prometheus.html
---

## Goal

This lab built a local monitoring stack on macOS with Docker Compose.

The target workflow was:

```text
node-exporter
  -> Prometheus scrape
  -> alert rules
  -> Alertmanager
  -> Gmail SMTP notification
  -> Grafana dashboard
```

## Components

`node-exporter` exposed machine metrics such as CPU, memory, and network values.

Prometheus scraped those metrics and evaluated alert rules.

Alertmanager handled routing and delivery for alerts.

Grafana provided dashboards for visual inspection.

## What made it useful

The important part was building the full loop, not only starting containers.

A monitoring stack is only useful when each link is verified:

- the exporter exposes metrics
- Prometheus scrapes successfully
- rules evaluate as expected
- Alertmanager receives fired alerts
- email delivery works
- Grafana reads Prometheus data

## Takeaway

End-to-end monitoring needs proof at every stage. A dashboard alone is not monitoring, and an alert rule alone is not notification. The system works only when collection, evaluation, routing, and delivery are all tested together.

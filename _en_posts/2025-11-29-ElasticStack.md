---
layout: post
lang: en
read_time: true
show_date: true
title: "Building Nginx Log Monitoring with the Elastic Stack"
date: 2025-11-29
description: A monitoring setup using Filebeat, Elasticsearch, and Kibana to inspect Nginx logs from an EC2 server.
tags: [devops, elasticsearch, kibana, filebeat, nginx]
author: Juwon
permalink: /en/ElasticStack.html
---

## Goal

The goal was to see Nginx traffic and errors in a dashboard instead of checking raw log files manually.

The pipeline was:

```text
Nginx logs
  -> Filebeat
  -> Elasticsearch
  -> Kibana
```

## Architecture

The EC2 server ran Nginx and Filebeat. Elasticsearch and Kibana were tested through Docker containers. Access to Kibana happened from a Mac browser through an SSH tunnel to `localhost:5601`.

This kept the dashboard reachable during testing without exposing Kibana publicly.

## Why separate logs

The useful requirement was separating blog traffic from other service traffic. That meant Nginx needed distinct access logs, and Filebeat needed to ship the right files.

Once the logs reached Elasticsearch, Kibana could visualize:

- request volume
- status code patterns
- error spikes
- active paths
- source IP patterns

## Takeaway

Raw logs are still the source of truth, but dashboards make patterns visible faster. The important design choice is to keep log sources named and separated before they enter the pipeline.

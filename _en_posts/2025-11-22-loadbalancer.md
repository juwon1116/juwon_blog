---
layout: post
lang: en
read_time: true
show_date: true
title: "Load Balancing Django with Nginx Upstream and Multiple Gunicorn Instances"
date: 2025-11-22
description: A deployment note on splitting Django traffic across two Gunicorn ports through Nginx upstream.
tags: [devops, nginx, django, load-balancing, ubuntu]
author: Juwon
permalink: /en/loadbalancer.html
---

## Goal

The original deployment had one Nginx process forwarding traffic to one Gunicorn-backed Django process on `127.0.0.1:8000`.

The practice goal was to run two backend instances and let Nginx distribute requests:

```text
Nginx
  -> Gunicorn on 127.0.0.1:8000
  -> Gunicorn on 127.0.0.1:8001
```

## Nginx upstream

The key Nginx concept is `upstream`:

```nginx
upstream django_backend {
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
}

location / {
    proxy_pass http://django_backend;
}
```

This keeps the public server block simple while allowing multiple private backend targets.

## What needs to match

The backend processes must be started separately and listen on different ports. Nginx must point to those ports, and both processes must serve the same application version.

Useful checks:

```bash
ss -lntp
curl http://127.0.0.1:8000
curl http://127.0.0.1:8001
sudo nginx -t
```

## Takeaway

Load balancing is not only about scaling traffic. It also forces the deployment to define process boundaries, health checks, and how Nginx should behave if one backend is unavailable.

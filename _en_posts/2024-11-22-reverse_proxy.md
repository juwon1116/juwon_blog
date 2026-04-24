---
layout: post
lang: en
read_time: true
show_date: true
title: "Reverse Proxy and the Basic Nginx Deployment Shape"
date: 2024-11-22
description: A practical note on how Nginx sits in front of Django and Gunicorn as a reverse proxy.
tags: [devops, nginx, django, reverse-proxy, ubuntu]
author: Juwon
permalink: /en/reverse_proxy.html
---

## What a reverse proxy does

A reverse proxy receives the browser request first, then forwards it to the application server that actually handles the work.

The deployment shape is simple:

```text
Browser
  -> Nginx
  -> Gunicorn / Django
```

From the browser's point of view, Nginx is the only visible server. The Django process, the Gunicorn port, and the number of backend processes stay hidden behind it.

## Why Nginx belongs in front

Nginx handles the parts that should not be Django's job:

- Accept public HTTP and HTTPS traffic.
- Serve static files directly.
- Forward dynamic requests to Gunicorn.
- Keep backend ports private.
- Apply request size, timeout, and host rules at the edge.

That separation matters because a Django app server is built to run application code, not to be the public traffic gate.

## The core configuration idea

The important line is the proxy target:

```nginx
location / {
    proxy_pass http://127.0.0.1:8000;
}
```

This says: public users connect to Nginx, but dynamic requests are passed to a local backend process. The backend can listen on `127.0.0.1`, which keeps it unavailable from the outside internet.

## What I took from this setup

The useful mental model is that Nginx is not just a "web server" in front of Django. It is the boundary between public traffic and private application processes.

Once that boundary is clear, later topics such as SSL termination, load balancing, static file serving, and upstream health checks become easier to reason about.

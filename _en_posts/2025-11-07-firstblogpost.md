---
layout: post
lang: en
read_time: true
show_date: true
title: "Building Auto Deployment for a Jekyll Blog with GitHub Actions and Nginx"
date: 2025-11-07 23:59:00 +0900
description: How I wired a Jekyll blog to deploy automatically to an Ubuntu EC2 server after every push to main.
img: posts/20251107/jekyll.jpg
tags: [devops, jekyll, github-actions, nginx, rbenv]
author: Juwon
github: JuWunpark/juwon_blog
permalink: /en/firstblogpost.html
---

## Goal

I wanted the blog to update from a normal writing workflow:

```text
write locally
  -> git push main
  -> GitHub Actions builds the site
  -> server receives the new _site output
  -> Nginx serves the updated blog
```

The point was to remove the manual cycle of SSH login, build commands, file copy, and Nginx checks every time I wrote a post.

## Deployment path

The working deployment path became:

```text
Local machine
  -> GitHub Actions
  -> SSH into EC2
  -> bundle install
  -> bundle exec jekyll build
  -> rsync _site/ to /var/www/myblog
  -> Nginx serves the static output
```

The server used Ubuntu, rbenv-managed Ruby, Bundler, and Nginx. The repository stayed as the source of truth; the server only held the built static result.

## Main issues

The useful debugging points were not about Jekyll itself. They were around runtime consistency:

- Ruby and Bundler versions had to match what the project expected.
- The GitHub Actions SSH key needed correct permissions and host access.
- Nginx needed to point at the final static directory, not the repository root.
- `rsync` had to overwrite old static files without leaving stale artifacts.

## Result

After this setup, publishing became a push-based workflow. The blog source lives in Git, deployment is reproducible, and the EC2 server only serves static files through Nginx.

That is the right shape for a personal technical blog: simple runtime, clear deployment boundary, and no manual publish step.

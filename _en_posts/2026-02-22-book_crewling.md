---
layout: post
lang: en
read_time: true
show_date: true
title: "Reviewing a Selenium-Based Book PDF Crawler Prototype"
date: 2026-02-22
description: A prototype review for a CLI crawler that searches book metadata and evaluates public PDF candidates with license signals.
tags: [python, selenium, cli, crawling, automation]
author: Juwon
permalink: /en/book_crewling.html
---

## Scope

This prototype was not treated as a general downloader. The correct use case is finding legally public or public-domain material and preserving license checks as a required step.

The session focused on making the minimum search-to-result flow work.

## Completed work

The review covered:

- understanding the execution flow
- adding `requirements.txt`
- confirming the Google-based flow
- observing Google's `sorry` and reCAPTCHA blocking behavior
- switching the search backend from Google to Bing
- parsing Bing results
- decoding Bing tracking links into original URLs
- fixing a Selenium `expected_conditions` import bug
- fixing JSON serialization for `Path` values
- writing result JSON under a local `result/` directory

## Architecture

The CLI takes book information, drives a browser search through Selenium, collects candidate URLs, and stores structured result data.

The important design point is that search results are not automatically trusted. A result needs additional signals before it can be considered usable.

## Takeaway

The prototype became more stable after replacing brittle Google scraping with a less blocked search path and fixing serialization issues. The next quality bar would be stronger license classification and cleaner separation between search, parsing, scoring, and output.

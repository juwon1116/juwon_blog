---
layout: post
lang: en
read_time: true
show_date: true
title: "2026-02-22 - Completing a Selenium-Based Book PDF Crawler"
date: 2024-11-22
description: A summary of extending a Selenium-based book PDF crawler from a CLI into a PyQt6 GUI with packaging preparation.
tags: [Python, Selenium, PyQt6, Web Crawling, PyInstaller]
author: Juwon
permalink: /en/book_crewling.html
---

# 2026-02-22 - Completing a Selenium-Based Book PDF Crawler

## One-Line Summary

I extended `ai_crawling_books` from a CLI into a PyQt6 desktop GUI with packaging preparation. The tool collects search results from a book title and author, checks license signals and domain trust together, and filters PDF candidates that are more likely to be legally downloadable.

## Why I Started

I wanted to find PDF candidates from only a book title and author, but I did not want to blindly mix in unauthorized copies. Instead of simply collecting as many search results as possible, I needed automation that could first narrow the results to candidates with legal distribution signals.

Some early documents still had names like `ai_crawling_books_by_codex`. The starting point of this work was to align the README, execution flow, GUI, and packaging direction around the actual project name: `ai_crawling_books`.

## Clarifying The Concepts First

The search layer was split by provider. I separated `brave`, which depends more on Juwon's local environment, from `bing`, which is more suitable as a general default for distribution.

Search results are normalized into a `SearchResult` shape. The crawler calculates `relevance_score` by combining title and author token matching, PDF signals, open-access signals, and noisy-domain penalties.

Page analysis is handled with Selenium. The crawler visits URLs, collects `title`, `meta`, and body text, then looks for author, publisher, year, ISBN, and PDF link hints.

License detection checks positive signals such as `Creative Commons`, `CC BY`, `CC0`, `Public Domain`, and `Open Access` together with negative signals such as `copyright`, `no download`, and `purchase`. This tool is not a legal guarantee engine. It is a filtering tool for reducing risky candidates.

## References

- Existing `book_crawler` package structure
- CLI, Selenium crawler, runner, validators
- `license_detector`, `downloader`, `search_ranker`
- README installation, usage, safety policy, and test notes
- Brave search local integration flow
- Bing search result page parsing flow
- Upwork portfolio structure
- `skill-creator`, `linear-project-planner`

## What I Built

I cleaned up the README around the `ai_crawling_books` name. The confirmed commit was `a7a033d` `docs: update project readme`.

I separated the search providers into `brave` and `bing`, then added result normalization and relevance scoring. After that, Selenium opens result pages, collects metadata and PDF hints, and records `allowed` or `blocked` decisions based on license signals.

Before saving a file, the download layer checks `content-type: application/pdf` and records file size and `SHA-256`. In `dry-run` mode, the tool only inspects and evaluates candidates without downloading them.

At first, I added a localhost-based web GUI. That flow remains in commit `e2e2d6f` `feat: add local gui workflow`. After user feedback, I switched to a PyQt6 desktop app, which corresponds to `e356c5b` `feat: switch gui to pyqt`.

The PyQt6 GUI includes Title, Author, Output, Provider, Language, Max results, Retries, Timeout, Dry run, Run/Cancel/Load result, a result table, Details JSON, and Logs.

The related files are:

- `book_crawler/gui.py`
- `book_crawler/gui_entry.py`
- `scripts/build_zip.py`

I also added dependencies:

- `requirements.txt`: `PyQt6>=6.10,<7`
- `requirements-dev.txt`: `pyinstaller>=6.20,<7`

Verification used these commands:

```bash
python3 -m unittest discover -s tests
python3 -m py_compile book_crawler/*.py
python3 scripts/build_zip.py --help
```

The test run reported `Ran 10 tests ... OK`, and `py_compile` also passed. On macOS, I verified that the GUI launched with the window name `ai_crawling_books` and size `1180x792`.

I also organized the work scope as a Linear project. I created and completed 15 tasks from `JUW-39` through `JUW-53`.

<!-- image: Add a PyQt6 GUI screenshot or a sensitive-info-blurred result screen here -->

## What Blocked Me

The first issue was the expectation around the word "GUI." A localhost web UI can technically be a GUI, but the user expected a desktop app. That is why I moved the interface to PyQt6.

The second issue was provider selection. `brave` depends heavily on Juwon's local skill setup, so it was not a good default for general distribution. Setting `bing` as the default provider was the better direction.

The third issue was packaging. A single zip that covers both Mac and Windows is not realistic, and PyInstaller produces builds for the current OS. 

Screenshots also could not be published directly. The UI can expose local paths, `run_*.json` files, actual PDF URLs, and commercial textbook information, so screenshots need blurring before publication.

## What I Resolved

The project is now organized around the `ai_crawling_books` name. Search, page analysis, license-signal detection, and download validation are connected into one crawler pipeline.

The GUI moved from a localhost web flow to a PyQt6 desktop app. The distribution default provider is `bing`, while `brave` remains available as a local-environment-dependent option.

Packaging was organized around PyInstaller producing OS and architecture specific zip files. This does not solve every platform at once, but it focuses on producing a deliverable artifact.

## What I Learned

The word "GUI" changes meaning depending on user expectations. When a desktop app is the natural expectation, the implementation should match that expectation instead of stopping at a web UI.

A distributable tool should not make local-only dependencies the default. The default provider should be the option that another person can run more easily, not the one that is most convenient in my own environment.

Filtering legal candidates cannot be reduced to a single keyword. License wording, domain trust, and download context need to be considered together for the tool to be practically useful.

## Portfolio Framing

This work is not just a Selenium script. It is a case study in turning a discovery automation workflow into a product-like tool.

The key evidence:

- `python3 -m unittest discover -s tests`: 10 tests passed
- `python3 -m py_compile book_crawler/*.py`: passed
- `python3 scripts/build_zip.py --help`: packaging script checked
- `book_crawler/gui.py`, `book_crawler/gui_entry.py`, `scripts/build_zip.py`
- `a7a033d` `docs: update project readme`
- `e2e2d6f` `feat: add local gui workflow`
- `e356c5b` `feat: switch gui to pyqt`
- Linear `JUW-39` through `JUW-53`, 15 tasks completed

In short, this project is most convincing when described not as "implementing a crawler," but as "turning a crawler into a safer and more usable tool with product-level handling."

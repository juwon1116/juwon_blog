---
layout: post
lang: en
published: false
read_time: true
show_date: true
toc: true
title: "Building a Business Report Writing Skill"
date: 2026-04-03
description: Notes on creating a document-generation skill for drafting Korean shareholder meeting business reports from structured company materials.
img: posts/20260403/business-report-sample-1.png
tags: [automation, docx, python, workflow, legal-docs]
author: Juwon
permalink: /en/write-inc-business-report.html
---

## Why I built it

While working on a freelance company-document task, I wanted to see whether an agent could produce a first draft of a business report when given the right source materials.

The document is repetitive, but not simple. It pulls from scattered company data: overview, shares, major shareholders, executives, financial summaries, creditors, and post-closing events.

That made it a good fit for structured automation.

## What the skill does

The skill is not only a prompt. It is a reusable work package that combines:

- task instructions
- document rules
- extraction logic
- templates
- output expectations
- verification steps

The goal is to make the same reporting task repeatable instead of improvising every draft.

## Design choice

The safer approach was not to ask a model to write long legal-style prose from memory. The better shape was:

1. read source documents
2. extract required values
3. normalize them into structured data
4. assemble the report into the required document format
5. review the output against the checklist

## Takeaway

Document automation works best when generation is constrained by structure. The skill exists to reduce repetitive drafting while keeping the report tied to source data and a fixed format.

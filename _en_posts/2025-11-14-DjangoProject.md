---
layout: post
lang: en
read_time: true
show_date: true
title: "Architecture Notes for a Django-Based AI Quiz Platform"
date: 2025-11-14 23:59:00 +0900
description: A structural walkthrough of Quizly, a Django 5.1 application that generates quizzes from uploaded study materials.
img: posts/20251114/Django.png
tags: [django, python, architecture, ai, web]
author: Juwon
github: JuWunpark/juwon_blog
permalink: /en/DjangoProject.html
---

## Project overview

Quizly is an AI study platform built around one workflow: a user uploads learning material, the app extracts usable text, and OpenAI generates quiz questions from that content.

The project combines a traditional Django web app with document parsing and AI generation.

## Stack

The main stack was:

- Django 5.1.6 for the web backend.
- Python 3.12 for application code.
- MySQL 8.0 for persistent data.
- OpenAI API for quiz generation.
- django-allauth for Google, Kakao, and Naver login.
- PyMuPDF, python-docx, and python-pptx for document extraction.
- Nginx and Cloudflare for deployment and edge traffic.

## Module responsibilities

The important architecture decision was to keep the workflow separated by responsibility:

- Authentication handles user identity and social login.
- Upload logic stores files and validates allowed document types.
- Parsing logic extracts clean text from PDF, DOCX, and PPTX input.
- AI logic turns extracted text into quiz data.
- View logic connects the user-facing pages to each step.

This separation makes the project easier to debug because a failed quiz can be traced to one stage: upload, parse, prompt, generation, or rendering.

## What the project taught

The hard part was not simply calling an AI model. The real work was shaping the app around predictable data boundaries.

The document parser must produce usable text. The prompt layer must receive that text in a controlled format. The database must store generated results in a way the UI can render later.

That is the main lesson from this project: AI features still need normal backend discipline.

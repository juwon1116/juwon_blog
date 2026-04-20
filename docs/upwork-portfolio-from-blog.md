# 업워크 포트폴리오 후보 정리

기준: 업워크 `Add a new portfolio project` 폼에 바로 옮길 수 있는 항목만 추렸다.

- 제목: 70자 이하 목표
- 역할: 100자 이하 목표
- 설명: 600자 이하 목표
- 스킬: 5개
- 첨부물: 블로그 글, 이미지, 샘플 산출물 기준으로 추천

## 먼저 올릴 후보

1. `영업보고서 자동화`
2. `AI 발표자료 생성 + 웹 편집기`
3. `Jekyll 블로그 CI/CD 구축`
4. `Nginx 로그 관제 대시보드`

`Selenium 도서 PDF 크롤러`는 프로토타입 + 라이선스 민감도 때문에 보류 후보로 두는 편이 안전하다.

---

## 1) 영업보고서 자동화

### 왜 좋나
- 문제, 입력 자료, 자동화 기준, 출력물 형태가 명확함
- 샘플 이미지 4장이 이미 있음
- 문서 자동화/백오피스 자동화/법인 문서 워크플로우 카테고리로 설명 가능

### 업워크 입력 초안
- Project title
  `Business Report Automation for Shareholder Meetings`
- Your role
  `Python automation developer for structured document workflows`
- Project description
  `Built a document automation workflow for shareholder-meeting business reports. The system reads source materials such as financial statements, shareholder records, articles of incorporation, and meeting data, extracts verified facts, and renders a structured .docx report in a consistent format. I focused on reliability over free-form generation by enforcing JSON block structures, cross-checking stock and capital figures, standardizing empty-value handling, and using python-docx to produce repeatable reports aligned with a real business template.`
- Skills and deliverables
  `Python`, `python-docx`, `Document Automation`, `JSON`, `Workflow Automation`

### 첨부 추천
- 이미지 4장
  `/assets/img/posts/20260403/business-report-sample-1.png`
  `/assets/img/posts/20260403/business-report-sample-2.png`
  `/assets/img/posts/20260403/business-report-sample-3.png`
  `/assets/img/posts/20260403/business-report-sample-4.png`
- 텍스트/링크
  비공개 초안 글이라 외부 링크보다 이미지 + 설명 위주 추천
- 가능하면 추가
  민감정보 제거한 샘플 `.docx` 1개

### 근거 포스트
- `_posts/2026-04-03-write-inc-business-report.md`

### 메모
- 이 글은 현재 `published: false`
- 공개 링크 증빙보다 산출물 중심 포트폴리오로 가는 편이 맞음

---

## 2) AI 발표자료 생성 + 웹 편집기

### 왜 좋나
- AI 생성에서 끝나지 않고 편집기, 재렌더, 배포까지 연결됨
- 풀스택 + AI 워크플로우 + 인프라 감각까지 같이 보여줌
- 시리즈형 포스트라 문제 해결 흐름 설명이 쉬움

### 업워크 입력 초안
- Project title
  `AI Presentation Generator with Web-Based Slide Editor`
- Your role
  `Full-stack developer for AI generation, slide editing, and deployment`
- Project description
  `Built a Django-based presentation workflow that turns prompts into editable slide decks. I reworked the system around a SlideSpec intermediate model so generated content could be previewed, edited, and re-rendered instead of being treated as a one-shot output. The project included fixing broken text-to-placeholder mapping, building a browser-based editor for titles and bullets, supporting template previews, and preparing Docker, Caddy, Lightsail, and Terraform deployment paths so the tool could move beyond a prototype.`
- Skills and deliverables
  `Django`, `OpenAI API`, `Google Slides`, `PPTXGenJS`, `Docker`

### 첨부 추천
- 텍스트/링크
  포스트 3개를 순서대로 링크
  `https://juwonpark.me/pptauto1.html`
  `https://juwonpark.me/pptauto2.html`
  `https://juwonpark.me/pptauto3.html`
- 가능하면 추가
  에디터 화면 캡처 1장
  생성된 PPT 샘플 1개
  템플릿 미리보기 vs 실제 렌더 비교 이미지 1장

### 근거 포스트
- `_posts/2025-11-14-pptauto1.md`
- `_posts/2025-11-16-pptauto2.md`
- `_posts/2026-03-30-pptauto3.md`

### 메모
- 설명 포인트는 `AI 자동화`보다 `편집 가능한 생성형 웹앱` 쪽이 더 강함
- 현재 레포 기준으로는 시각 첨부물이 부족해서, 실제 서비스 화면 캡처 보강 권장

---

## 3) Jekyll 블로그 CI/CD 구축

### 왜 좋나
- 배포 파이프라인이 단순하고 명확함
- GitHub Actions, SSH, Ruby/Jekyll, Nginx, 서버 트러블슈팅까지 한 번에 설명 가능
- 실제 운영 중인 블로그라 신뢰도 높음

### 업워크 입력 초안
- Project title
  `GitHub Actions CI/CD for a Jekyll Blog on Ubuntu`
- Your role
  `DevOps engineer for CI/CD, server deployment, and web delivery`
- Project description
  `Set up an end-to-end deployment pipeline for a Jekyll blog running on Ubuntu with Nginx. Every push to the main branch triggers GitHub Actions, connects to the server over SSH, synchronizes the repository, builds the site with Ruby and Bundler, and publishes the generated output to the web root. I also resolved issues around rbenv paths, Ruby version mismatches, missing pages, and UTF-8 handling so deployments became predictable and repeatable.`
- Skills and deliverables
  `GitHub Actions`, `Jekyll`, `Nginx`, `Ubuntu`, `CI/CD`

### 첨부 추천
- 링크
  `https://juwonpark.me/firstblogpost.html`
  `https://juwonpark.me`
- 이미지
  `/assets/img/posts/20251107/jekyll.jpg`
- 가능하면 추가
  GitHub Actions 성공 실행 캡처 1장

### 근거 포스트
- `_posts/2025-11-07-firstblogpost.md`

### 메모
- 업워크 클라이언트가 운영 안정성, 블로그/문서 사이트 배포, 소규모 CI/CD를 찾을 때 잘 맞음

---

## 4) Nginx 로그 관제 대시보드

### 왜 좋나
- 로그 수집, 파이프라인, 시각화, 운영 관점 분리가 선명함
- 웹서비스 운영/장애 대응/관제 업무 포트폴리오로 쓰기 좋음
- 블로그 트래픽과 다른 서비스 트래픽 분리라는 실전 포인트가 있음

### 업워크 입력 초안
- Project title
  `Nginx Log Monitoring Dashboard with Elastic Stack`
- Your role
  `DevOps engineer for log pipelines and observability dashboards`
- Project description
  `Built an observability pipeline for Nginx traffic and error logs using Filebeat, Elasticsearch, and Kibana on an EC2 environment. I configured log collection for multiple Nginx log files, shipped events into Elasticsearch, accessed Kibana securely through SSH tunneling, and organized filters to separate blog traffic from other services. The goal was to make traffic patterns and errors visible without logging into the server for every investigation.`
- Skills and deliverables
  `Elasticsearch`, `Kibana`, `Filebeat`, `Nginx`, `Observability`

### 첨부 추천
- 링크
  `https://juwonpark.me/ElasticStack.html`
- 가능하면 추가
  Kibana Discover 화면 1장
  간단한 대시보드 캡처 1장

### 근거 포스트
- `_posts/2025-11-29-ElasticStack.md`

### 메모
- 현재 글만으로도 설명은 되지만, 대시보드 스크린샷 추가하면 훨씬 강해짐

---

## 5) 보류 후보: Selenium 도서 PDF 크롤러

### 왜 보류인가
- 구조는 괜찮지만 아직 `prototype` 성격이 강함
- 도서 PDF 탐색이라는 주제가 라이선스 민감
- 업워크 첫 인상용 포트폴리오로는 다른 후보보다 덜 안전함

### 업워크 입력 초안
- Project title
  `Selenium CLI for Public PDF Discovery and License Checks`
- Your role
  `Python automation developer for CLI and browser workflows`
- Project description
  `Prototyped a Selenium-based CLI that searches for publicly available book PDFs, analyzes candidate pages, checks license signals, and saves structured results as JSON. I replaced a blocked Google flow with a Bing-based pipeline, added tracking-link decoding, fixed serialization and import issues, and kept compliance as a core requirement by treating license validation as mandatory before any download step.`
- Skills and deliverables
  `Python`, `Selenium`, `CLI`, `Web Automation`, `JSON`

### 근거 포스트
- `_posts/2026-02-22-book_crewling.md`

### 메모
- 올리더라도 `public-domain / licensed sources only` 문구를 반드시 전면에 둘 것

---

## 최종 추천

업워크에 먼저 3개만 올린다면 이 순서 추천.

1. `영업보고서 자동화`
2. `AI 발표자료 생성 + 웹 편집기`
3. `Jekyll 블로그 CI/CD 구축`

이유도 단순하다.

- `영업보고서 자동화`: 산출물 증빙 가장 강함
- `AI 발표자료 생성 + 웹 편집기`: 기술 스택 폭 가장 넓음
- `Jekyll 블로그 CI/CD 구축`: 실제 운영형 사례라 신뢰도 높음

## 다음 액션

- `영업보고서 자동화`는 지금 바로 업로드 가능
- `AI 발표자료 생성 + 웹 편집기`는 화면 캡처 2~3장만 보강하면 가장 강력한 카드
- `Nginx 로그 관제 대시보드`는 Kibana 캡처만 추가하면 보조 카드로 좋음

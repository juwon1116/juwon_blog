---
layout: post
read_time: true
show_date: true
title: "2026-02-22 - Selenium 기반 도서 PDF 크롤러 완성"
date: 2024-11-22
description: Selenium 기반 도서 PDF 크롤러를 CLI에서 PyQt6 GUI와 배포 준비까지 확장한 작업 정리.
tags: [Python, Selenium, PyQt6, Web Crawling, PyInstaller]
author: Juwon
---

# 2026-02-22 - Selenium 기반 도서 PDF 크롤러 완성

## 한 줄 요약

책 제목과 저자를 바탕으로 검색 결과를 수집하고, 라이선스 신호와 도메인 신뢰도를 함께 봐서 합법적 다운로드 가능성이 있는 PDF 후보를 선별하는 `ai_crawling_books`를 CLI에서 PyQt6 데스크톱 GUI와 배포 준비 단계까지 확장했다.

## 시작하게 된 이유

책 제목과 저자만으로 PDF 후보를 찾고 싶었지만, 무단 배포본을 그대로 섞어 다루는 방식은 피하고 싶었다. 그래서 단순히 검색 결과를 많이 모으는 것보다, 합법적 가능성이 있는 후보를 먼저 추리는 자동화가 필요했다.

초기 문서에는 `ai_crawling_books_by_codex` 같은 이름도 남아 있었다. 실제 프로젝트명인 `ai_crawling_books`에 맞게 README, 실행 방식, GUI, 배포 방향까지 정리하는 것이 이번 작업의 출발점이었다.

## 먼저 개념부터 정리하기

검색 단계에서는 provider를 분리했다. 로컬 환경 의존성이 있는 `brave`와 범용성이 더 높은 `bing`을 나눴고, 배포 기본값은 `bing`이 더 적절하다고 판단했다.

검색 결과는 `SearchResult` 형태로 정규화했다. 제목/저자 토큰 매칭, PDF 신호, open-access 신호, noisy domain 패널티를 함께 반영해 `relevance_score`를 계산했다.

페이지 분석은 Selenium으로 처리했다. URL에 방문해 `title`, `meta`, 본문을 수집하고, author/publisher/year/isbn 및 PDF 링크 힌트를 탐색했다.

라이선스 판정은 `Creative Commons`, `CC BY`, `CC0`, `Public Domain`, `Open Access` 같은 positive signal과 `copyright`, `no download`, `purchase` 같은 negative signal을 함께 봤다. 이 도구는 합법성을 보장하는 판정기가 아니라, 위험한 후보를 줄이기 위한 필터링 도구다.

## 참고한 자료

- 기존 `book_crawler` 패키지 구조
- CLI, Selenium crawler, runner, validators
- `license_detector`, `downloader`, `search_ranker`
- README의 설치, 실행, 안전 정책, 테스트 설명
- Brave search 로컬 연동 방식
- Bing 검색 결과 페이지 파싱 방식
- Upwork 포트폴리오 구조
- `skill-creator`, `linear-project-planner`

## 직접 해본 내용

README를 `ai_crawling_books` 기준으로 정리했다. 확인된 커밋은 `a7a033d` `docs: update project readme`다.

검색 provider를 `brave`와 `bing`으로 분리하고, 결과 정규화와 관련도 점수 계산을 붙였다. 이후 Selenium으로 결과 페이지를 열어 메타데이터와 PDF 힌트를 수집하고, 라이선스 신호에 따라 `allowed` 또는 `blocked` 판단을 정리했다.

다운로드 단계에서는 실제 저장 전 `content-type: application/pdf`를 확인하고, 파일 크기와 `SHA-256`을 기록하게 했다. `dry-run`에서는 실제 다운로드 없이 탐색과 판정만 검토할 수 있게 했다.

처음에는 localhost 기반 웹 GUI를 붙였다. 이 흐름은 `e2e2d6f` `feat: add local gui workflow` 커밋으로 남아 있다. 이후 사용자 피드백을 반영해 PyQt6 데스크톱 앱으로 전환했고, 이 전환은 `e356c5b` `feat: switch gui to pyqt`에 해당한다.

PyQt6 GUI에는 Title, Author, Output, Provider, Language, Max results, Retries, Timeout, Dry run, Run/Cancel/Load result, 결과 테이블, Details JSON, Logs를 배치했다.

관련 파일은 다음과 같다.

- `book_crawler/gui.py`
- `book_crawler/gui_entry.py`
- `scripts/build_zip.py`

의존성도 추가했다.

- `requirements.txt`: `PyQt6>=6.10,<7`
- `requirements-dev.txt`: `pyinstaller>=6.20,<7`

검증은 아래 명령으로 진행했다.

```bash
python3 -m unittest discover -s tests
python3 -m py_compile book_crawler/*.py
python3 scripts/build_zip.py --help
```

테스트는 `Ran 10 tests ... OK`였고, `py_compile`도 통과했다. GUI는 macOS 기준 창 이름 `ai_crawling_books`, 크기 `1180x792`로 실행 확인했다.

작업 범위는 Linear 프로젝트로도 정리했다. `JUW-39`부터 `JUW-53`까지 총 15개 태스크를 만들고 완료 처리했다.

<!-- image: PyQt6 GUI 실행 화면 또는 민감정보 블러 처리된 결과 화면을 여기에 추가 -->

## 막혔던 부분

첫 번째 문제는 GUI 기대치였다. localhost 웹 UI도 GUI라고 볼 수 있지만, 사용자는 데스크톱 앱을 기대했다. 그래서 PyQt6로 전환했다.

두 번째는 provider 선택이었다. `brave`는 Juwon 로컬 skill 의존성이 강해서 일반 배포용 기본값으로는 적합하지 않았다. 그래서 기본 provider는 `bing`으로 두는 방향이 맞았다.

세 번째는 배포 제약이었다. Mac과 Windows를 한 번에 커버하는 단일 zip은 현실적으로 어렵고, PyInstaller도 현재 OS 기준 산출물을 만든다.

스크린샷도 바로 공개하기 어려웠다. 화면에 로컬 경로, `run_*.json`, 실제 PDF URL, 상업 교재 정보가 노출될 수 있어 블러 처리가 필요했다.

## 해결 또는 정리한 내용

프로젝트는 `ai_crawling_books` 이름 기준으로 정리되었다. 검색, 페이지 분석, 라이선스 신호 판정, 다운로드 검증까지 하나의 크롤러 파이프라인으로 연결했다.

GUI는 localhost 웹 방식에서 PyQt6 데스크톱 앱으로 전환했다. 배포 기본 provider는 `bing`으로 정리했고, `brave`는 로컬 환경 의존성이 있는 선택지로 남겼다.

배포는 PyInstaller 기반으로 현재 OS/아키텍처별 zip을 생성하는 방식으로 정리했다. 모든 플랫폼을 한 번에 해결하지는 않지만, 실제 전달 가능한 산출물을 만드는 데 집중했다.

## 이번 작업에서 배운 점

“GUI”라는 말도 사용자 기대에 따라 의미가 달라진다. 웹 UI보다 데스크톱 앱이 더 자연스러운 상황에서는 구현 방식도 그 기대에 맞춰야 한다.

배포 가능한 도구는 로컬 전용 의존성을 기본값으로 두면 안 된다. 내 환경에서 편한 provider보다, 다른 사람이 바로 실행할 수 있는 provider가 기본값이어야 한다.

합법적 후보 선별은 단일 키워드로 끝나지 않는다. 라이선스 문구, 도메인 신뢰도, 다운로드 맥락을 함께 봐야 실무적으로 쓸 수 있다.

## 포트폴리오 관점에서 정리

이 작업은 단순 Selenium 스크립트가 아니라, 탐색 자동화 도구를 제품 형태로 다듬은 사례다.

핵심 증거는 다음과 같다.

- `python3 -m unittest discover -s tests`: 10 tests 통과
- `python3 -m py_compile book_crawler/*.py`: 통과
- `python3 scripts/build_zip.py --help`: 배포 스크립트 확인
- `book_crawler/gui.py`, `book_crawler/gui_entry.py`, `scripts/build_zip.py`
- `a7a033d` `docs: update project readme`
- `e2e2d6f` `feat: add local gui workflow`
- `e356c5b` `feat: switch gui to pyqt`
- Linear `JUW-39` ~ `JUW-53`, 총 15개 태스크 완료

정리하면, 이 프로젝트는 “크롤링 기능 구현”보다 “안전성과 사용성을 고려해 도구를 제품처럼 다듬은 과정”으로 설명할 때 가장 설득력이 있다.

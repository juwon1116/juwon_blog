---
layout: post
read_time: true
show_date: true
title: "Linear와 Codex를 연결한 Symphony 작업 자동화 구축기"
date: 2026-05-17
description: Linear 이슈를 기준으로 Codex 작업, 테스트, PR, 리뷰 준비까지 자동화하기 위해 Symphony 환경을 구축하며 겪은 설정과 문제 해결 기록.
tags: [Symphony, Codex, Linear, GitHub, Playwright, Django, Grafana, macOS]
author: Juwon
---

## 시작점

최근 작업의 목표는 단순했다. Linear에 쌓인 이슈를 사람이 하나씩 열고, Codex에게 설명하고, 작업 결과를 다시 확인하는 과정을 줄이고 싶었다.

기존 방식은 다음 흐름이었다.

1. Linear 이슈 확인
2. 로컬 repo 이동
3. Codex에게 작업 지시
4. 테스트 실행
5. commit / push / PR 생성
6. Linear 상태 변경
7. 리뷰 준비

이 흐름 자체는 반복적이다. 그래서 이슈 단위로 repo를 clone하고, Codex agent를 실행하고, 결과를 Linear와 GitHub에 남기는 오케스트레이션 도구로 Symphony를 붙였다.

## Symphony 구조 이해

내가 구성한 Symphony 흐름은 대략 이렇게 동작한다.

```text
Linear Issue
   ↓
Symphony
   ↓
ticket별 isolated workspace 생성
   ↓
target repo clone
   ↓
Codex agent 실행
   ↓
테스트 / 구현 / 커밋 / PR
   ↓
Linear workpad 업데이트
```

각 이슈는 별도 workspace를 가진다.

```text
/Users/bagjuwon/code/symphony-workspaces/JUW-73
/Users/bagjuwon/code/symphony-workspaces/JUW-74
/Users/bagjuwon/code/symphony-workspaces/JUW-96
```

이 방식의 장점은 병렬 작업이다. 여러 Linear 이슈를 동시에 실행해도 각 작업이 별도 디렉터리에서 진행된다.

## 프로젝트별 환경 분리

처음 헷갈렸던 부분은 "작업 repo가 바뀔 때마다 `WORKFLOW.md`를 수정해야 하나?"였다.

결론은 프로젝트별 env 파일로 분리하는 쪽이 맞았다.

예를 들어 OTT 프로젝트는 다음 값을 가진다.

```bash
LINEAR_PROJECT_SLUG=ott-recommend-ai-cf97ad451262
SOURCE_REPO_URL=https://github.com/juwonparkme/Movie-recomendation.git
```

그리고 Symphony의 `WORKFLOW.md`에서는 공통 hook만 둔다.

```yaml
hooks:
  after_create: |
    git clone --depth 1 "$SOURCE_REPO_URL" .
    if [ -x scripts/bootstrap_agent.sh ]; then
      scripts/bootstrap_agent.sh
    fi
```

이렇게 하면 프로젝트가 바뀌어도 `SOURCE_REPO_URL`만 바꾸면 된다.

## repo-local skills 문제

또 하나의 질문은 "각 repo마다 `.codex/skills`가 있어야 하나?"였다.

Symphony는 ticket workspace 안에서 Codex를 실행한다. 즉 agent 입장에서는 현재 clone된 repo가 작업 세계다. 그래서 특정 프로젝트에서 써야 하는 스킬은 해당 repo의 `.codex/skills` 안에 들어가는 것이 가장 확실했다.

OTT 프로젝트에서는 다음처럼 구성했다.

```text
/Users/bagjuwon/Projects/OTT_recommend_AI/.codex/skills
```

그리고 Symphony가 ticket별 workspace를 만들 때 repo를 clone하므로, `.codex/skills`도 같이 따라온다. 매번 수동 복사할 필요가 없게 된다.

## 권한 문제: workspace-write와 danger-full-access

초기에는 agent가 `.git`에 쓰지 못하는 문제가 반복됐다.

대표적인 증상은 이런 형태였다.

```text
.git 쓰기 권한 차단
.git/FETCH_HEAD 쓰기 권한 차단
touch .git/codex-write-test: Operation not permitted
```

이 상태에서는 구현은 해도 다음 단계가 막힌다.

```text
branch 생성 불가
commit 불가
push 불가
PR 생성 불가
```

원인은 Codex sandbox 권한이었다. `workspace-write`는 작업 디렉터리에 쓰기 권한을 주지만, 실제 turn에서 `.git` metadata 쓰기나 repo root가 writable root에 제대로 잡히지 않으면 Git 작업이 막힐 수 있었다.

그래서 Symphony 설정을 다음처럼 강화했다.

```yaml
codex:
  approval_policy: never
  thread_sandbox: danger-full-access
  turn_sandbox_policy:
    type: dangerFullAccess
```

이 설정은 unattended agent 실행에서는 중요했다. 사람이 중간에 승인 버튼을 누르지 않아도 branch, commit, push, PR 생성까지 진행해야 했기 때문이다.

## 테스트 하네스 구축

OTT 프로젝트에서 특히 신경 쓴 부분은 테스트였다.

단순히 `py_compile`만 통과하는 상태는 부족했다. 실제 사용자가 기능을 쓸 때 깨지는 문제를 잡지 못하기 때문이다.

그래서 테스트 환경을 세 단계로 나눴다.

### 1. bootstrap

```bash
scripts/bootstrap_agent.sh
```

역할:

```text
.venv 생성
Django dependency 설치
migration 적용
npm install
Playwright Chromium 설치
```

Python 버전도 Django 5.0과 맞게 3.11 또는 3.12를 쓰도록 조정했다.

### 2. validation gate

```bash
scripts/validate_agent.sh
```

역할:

```text
Django check
migration check
py_compile
Django regression tests
coverage gate
Playwright E2E
```

이 스크립트가 Symphony handoff 전 기준이 된다.

### 3. runtime check

```bash
scripts/launch_app.sh
```

역할:

```text
Django dev server 실행
브라우저로 실제 사용자 경로 검증
```

UI 변경이 있으면 단순 테스트 통과만으로 끝내지 않고, 실제 브라우저에서 바뀐 화면을 확인하도록 했다.

## Playwright E2E 추가

OTT 프로젝트의 `/search/` 페이지는 이미지가 많아 성능 문제가 있었다. 그래서 Playwright로 실제 브라우저 동작을 검증했다.

테스트 예시는 다음을 확인한다.

```text
/search/ 접속
초기 카드 8개만 렌더링
스크롤 시 /search/batch/ 호출
추가 카드 로딩
이미지 loading="lazy"
이미지 decoding="async"
하단 nav가 화면 안에 유지
불필요한 filter menu 미노출
```

이 테스트는 코드 레벨 단위 테스트와 다르다. 실제 브라우저가 페이지를 열고 스크롤하며 네트워크 요청과 DOM 상태를 확인한다.

즉 "사용자가 봤을 때 깨지는 문제"를 더 직접적으로 잡는다.

## Linear workpad와 증거 첨부

Symphony 작업의 핵심은 Linear workpad를 source of truth로 쓰는 것이다.

각 이슈에는 하나의 `## Codex Workpad` 댓글을 유지한다.

```md
## Codex Workpad

### Plan

- [ ] 1. 재현
- [ ] 2. 구현
- [ ] 3. 검증
- [ ] 4. PR 생성

### Validation

- [ ] targeted tests
- [ ] Playwright E2E
- [ ] browser screenshot
```

처음에는 notes가 너무 길어져서 읽기 어려웠다. 그래서 긴 로그나 검증 결과 뒤에는 짧은 요약을 반드시 붙이도록 했다.

```md
- 2026-05-12 19:35 KST: Playwright로 /search/ 하단 nav 위치를 검증했다...
- 요약: 모바일 검색 화면에서 마지막 카드와 하단 nav가 겹치지 않음을 확인했다.
```

UI 변경의 경우 로컬 파일 경로만 남기는 것도 부족했다.

```text
test-results/juw-91-after-search-infinite-bottom.png
```

이런 경로는 내 로컬에서는 보이지만 Linear 리뷰어에게는 보이지 않는다. 그래서 실제 Linear attachment 또는 접근 가능한 hosted asset URL로 첨부하고, read-back까지 확인하도록 workflow를 강화했다.

## GitHub PR 설명도 한국어로

자동 생성된 PR 설명이 영어로 나오는 문제도 있었다.

예를 들면 이런 식이었다.

```md
## Summary

- Restored the mobile bottom tab bar...

## Validation

- npm run test:e2e
```

Linear와 workpad는 한국어인데 GitHub PR만 영어면 흐름이 끊긴다. 그래서 Symphony workflow와 `push` skill에 규칙을 추가했다.

```text
GitHub PR title/body/comment prose는 한국어로 작성한다.
단, 명령어, 파일 경로, 에러 메시지, template heading은 필요한 경우 그대로 둔다.
```

이후 PR 본문은 다음 형태를 기대한다.

```md
## 요약

- 모바일 검색 화면에서 하단 탭바가 다시 보이도록 수정했다.

## 검증

- Django regression test 통과
- Playwright E2E 통과
```

템플릿이나 CI가 영어 heading을 강제하는 경우에는 heading만 유지하고 내용은 한국어로 채우도록 했다.

## macOS sleep 문제

Symphony는 장시간 실행된다. Mac이 잠자기 모드로 들어가면 agent 작업이 끊길 수 있다.

그래서 `caffeinate` wrapper를 추가했다.

```bash
mise exec -- ./scripts/symphony-awake.sh \
  --i-understand-that-this-will-be-running-without-the-usual-guardrails \
  --port 4100 \
  WORKFLOW.md
```

내부적으로는 다음처럼 실행된다.

```bash
caffeinate -dimsu bin/symphony ...
```

이렇게 하면 Symphony가 실행되는 동안만 Mac sleep을 막고, 종료되면 원래 상태로 돌아간다.

## Grafana와 Loki

운영 로그 쪽도 정리했다.

Grafana 자체는 로그를 저장하는 시스템이라기보다 보는 도구다. 실제 로그 저장소는 Loki를 사용하고, 서버 로그는 Alloy가 수집해서 Loki로 보낸다.

구성은 다음과 같다.

```text
production server
   ↓
Grafana Alloy
   ↓
Grafana Loki
   ↓
Grafana dashboard / query
```

필요한 환경 변수는 다음과 같은 형태다.

```bash
GRAFANA_LOKI_PUSH_URL=https://<logs-host>/loki/api/v1/push
GRAFANA_LOKI_URL=https://<logs-host>/loki/api/v1/query_range
GRAFANA_LOKI_USERNAME=<instance-or-tenant-id>
GRAFANA_LOKI_PASSWORD=<grafana-cloud-access-policy-token>
```

운영 서버에서 HTTP 500, 502, 504 같은 문제가 나면 코드만 추측하지 않고 Loki에서 nginx/gunicorn 로그를 먼저 확인하는 흐름을 만들었다.

## 겪은 문제들

### 1. PR이 안 생김

처음에는 Linear 상태가 `Human Review`로 넘어갔는데 GitHub PR이 없는 경우가 있었다.

원인은 대체로 둘 중 하나였다.

```text
.git 쓰기 권한 차단
GitHub auth/network 제한
```

즉 구현이나 테스트가 일부 되었더라도 commit/push/PR 단계가 막힌 것이다.

이 경험 때문에 Human Review로 넘어가기 전 completion bar를 강화했다.

```text
branch pushed
PR linked
PR checks green
PR feedback sweep complete
Linear attachment 확인
```

### 2. 테스트가 충분하지 않음

초기에는 정적 검증만 통과하고 Django 실행 테스트나 브라우저 검증은 빠져 있었다.

이 상태에서는 실제 사용자가 보는 UI 버그를 놓칠 수 있다. 그래서 Django regression test와 Playwright E2E를 validation gate에 포함했다.

### 3. Backoff queue

Symphony dashboard에서 이런 메시지도 자주 봤다.

```text
Backoff queue
↻ JUW-107 attempt=5 ... error=agent exited ... :response_timeout
```

이건 작업 코드 실패가 아니라 Symphony가 Codex agent 실행 중 응답 timeout을 만나 재시도 큐에 넣었다는 뜻이다.

특히 `:response_timeout`은 Codex app-server가 정해진 시간 안에 응답하지 않았다는 의미다. 이런 경우에는 기다리거나, 필요하면 `read_timeout_ms`를 늘리는 방식으로 완화할 수 있다.

```yaml
codex:
  read_timeout_ms: 30000
```

## 정리

이번 Symphony 구축에서 핵심은 "agent가 코드를 짜게 하는 것"이 아니었다.

더 중요한 것은 agent가 끝까지 작업할 수 있는 실행 환경을 만드는 것이었다.

필요했던 요소는 다음과 같았다.

```text
프로젝트별 env 분리
repo-local skills
권한 있는 sandbox
bootstrap / validate / launch script
Django regression test
Playwright E2E
Linear workpad 운영 규칙
GitHub PR 한국어 설명
UI screenshot evidence
Grafana/Loki 운영 로그
macOS sleep 방지
```

작업 자동화는 단순히 명령어 하나를 만드는 일이 아니다. agent가 막히는 지점을 줄이고, 실패했을 때 사람이 바로 이해할 수 있는 증거를 남기는 구조를 만드는 일에 가깝다.

이번 설정을 통해 Linear 이슈 하나가 다음 흐름으로 자동화될 수 있게 됐다.

```text
이슈 선택
→ workspace 생성
→ repo clone
→ bootstrap
→ 구현
→ 테스트
→ 브라우저 검증
→ screenshot 첨부
→ commit/push
→ PR 생성
→ Linear Human Review
```

앞으로 개선할 부분은 CI와 local validation의 간극을 줄이는 것이다. 현재 local/Symphony의 `validate_agent.sh`가 GitHub Actions보다 더 강하다. 장기적으로는 GitHub CI에도 Django tests, coverage, Playwright E2E를 포함해 로컬과 원격 검증 기준을 맞추는 것이 좋다.

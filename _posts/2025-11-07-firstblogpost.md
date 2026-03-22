---
layout: post
read_time: true
show_date: true
title: "Jekyll 블로그 자동배포 구축기 (GitHub Actions + Nginx)"
date: 2025-11-07 23:59:00 +0900
description: EC2(Ubuntu)에 Jekyll 블로그를 올리고, GitHub Actions로 main 푸시 시 자동 배포되도록 만든 과정과 트러블슈팅 기록.
img: posts/20251107/jekyll.jpg
tags: [devops, jekyll, github-actions, nginx, rbenv]
author: Juwon
github: JuWunpark/juwon_blog
---

## 왜 자동배포인가?
로컬에서 글 쓰고 `git push`만 하면 서버가 알아서 최신 상태로 바뀌길 원했다.  
“수동 로그인 → 빌드 → 복사”를 없애 생산성을 높이는 게 목표.

---

## 아키텍처 한 장 요약

```text
개발 환경
  ↓ git push (main)
GitHub Actions
  ↓ SSH
EC2 (/home/ubuntu/myblog)
  ├─ rbenv Ruby 3.3.4
  ├─ bundle install
  ├─ bundle exec jekyll build
  └─ rsync _site/ → /var/www/myblog
  ↓
Nginx (80/443) → https://blog.juwonpark.me
```


---

## 서버 구성
- **OS**: Ubuntu 24.04 LTS (EC2)
- **웹서버**: Nginx + Let’s Encrypt(Cloudflare 앞단)
- **Jekyll 빌드**: rbenv + Ruby 3.3.4 + bundler
- **문서 루트**: `/var/www/myblog`
- **소스 경로**: `/home/ubuntu/myblog`

### rbenv & Jekyll
```bash
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init - bash)"

ruby -v || rbenv install -s 3.3.4
rbenv global 3.3.4
gem install bundler jekyll --no-document
```
---
## GitHub Actions 워크플로

- 핵심은 서버에 SSH 접속 → 리포 강제 동기화 → 빌드 → rsync 배포.

```yaml
name: Deploy to Server
on:
  push: { branches: [ main ] }
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Setup SSH
        run: |
          set -e
          mkdir -p ~/.ssh
          echo "${{ secrets.SERVER_SSH_KEY }}" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          PORT="${{ secrets.SERVER_PORT }}"; [ -z "$PORT" ] && PORT=22
          ssh-keyscan -p "$PORT" -H "${{ secrets.SERVER_HOST }}" >> ~/.ssh/known_hosts

      - name: Deploy to server
        run: |
          set -e
          PORT="${{ secrets.SERVER_PORT }}"; [ -z "$PORT" ] && PORT=22
          ssh -i ~/.ssh/deploy_key -p "$PORT" \
            -o StrictHostKeyChecking=yes \
            -o UserKnownHostsFile=~/.ssh/known_hosts \
            "${{ secrets.SERVER_USER }}@${{ secrets.SERVER_HOST }}" '
            set -euo pipefail
            echo "[deploy] start"

            export RBENV_ROOT="$HOME/.rbenv"
            export PATH="$RBENV_ROOT/bin:$PATH"
            eval "$(rbenv init - bash)"

            cd /home/ubuntu/myblog
            RUBY_VER="$(cat .ruby-version 2>/dev/null || echo 3.3.4)"
            rbenv shell "$RUBY_VER"
            gem install bundler --no-document || true

            echo "[deploy] sync to origin/main"
            git fetch origin
            git reset --hard origin/main
            git clean -fd

            echo "[deploy] bundle install"
            bundle install

            echo "[deploy] jekyll build"
            bundle exec jekyll build -s . -d _site

            echo "[deploy] rsync to web root"
            rsync -az --delete _site/ /var/www/myblog/

            echo "[deploy] done"
```

---

## 테마/페이지 커스터마이징
```yml
  title: "Juwon"
  description: "주원의 윈도우95 테마 블로그"
```

About 링크와 페이지:
상단 메뉴 파일 `_includes/topbar.html`

```html
  <a href="{{ '/me/' | relative_url }}"><li>About</li></a>
```
처음에는 Windows 95 테마로 시작했지만, 장기적으로 운영할 블로그 톤과 맞지 않아 이후 커스터마이징 방향을 바꿨다.
---

## 초기 테마
[Windows 95 테마 데모](https://h01000110.github.io/20170917/windows-95)


| 증상                                     | 원인                           | 해결                                                                 |
| -------------------------------------- | ---------------------------- | ------------------------------------------------------------------ |
| `bundle: command not found`            | 비대화식 SSH에서 rbenv PATH 미설정    | 워크플로 원격 스크립트에 `RBENV_ROOT/PATH` + `eval "$(rbenv init - bash)"` 추가 |
| `rbenv: version '3.3.5' not installed` | 서버 Ruby와 `.ruby-version` 불일치 | 버전 **3.3.4**로 통일 후 `rbenv shell 3.3.4`                             |
| `git pull` 충돌                          | 서버에 로컬 변경 파일 존재              | 배포 서버 전용 작업 트리에서만 `git fetch && git reset --hard origin/main && git clean -fd` 사용 |
| Actions `Bad port ''`                  | `SERVER_PORT` 누락             | 비어있으면 22로 폴백                                                       |
| About 404                              | 메뉴는 `/me`, 실 페이지 없음          | 루트 `me.md` 생성 + 메뉴 링크 `/me/`로 고정                                   |
| 한글 깨짐                                  | meta/헤더에 charset 없음          | `<meta charset="utf-8">` + `charset utf-8;`                        |


## 로컬 없이 “바로 글 쓰기” 루틴
1. GitHub에서 새 포스트 파일 만들기: _posts/2025-11-11-my-post.md
2. 본문 작성 → Commit to main
3. Actions 탭에서 Deploy to Server가 실행되는지 확인

로그에 아래 순서가 보이면 성공:
```text
  [deploy] sync to origin/main
  [deploy] bundle install
  [deploy] jekyll build
  [deploy] rsync to web root
  [deploy] done
```
## 결론

한 번 자동배포를 붙여두니 글 작성과 운영이 분리돼서 훨씬 편해졌다.
핵심은 "푸시하면 배포된다"는 신뢰를 만드는 것이고, 그 신뢰를 위해 SSH 환경, Ruby 버전, 배포 서버 작업 트리를 일관되게 관리해야 했다.
앞으로는 글 쓰는 빈도를 유지하면서도 배포 파이프라인은 건드리지 않아도 되는 상태를 목표로 가져가면 된다.


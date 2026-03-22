# GitHub Secrets

현재 기본 배포 경로는 GitHub Pages라서 **필수 Repository secret 없음**.

## 기본 배포

- 대상: `https://juwonpark.me`
- 워크플로: `.github/workflows/jekyll-gh-pages.yml`
- 필요 secret: 없음

## Legacy Server Deploy

`.github/workflows/deploy.yml` 은 자동 실행 안 하고 `workflow_dispatch` 수동 실행만 남겨둠.

이 legacy workflow를 다시 쓸 때만 아래 secret 필요:

- `SERVER_HOST`
- `SERVER_USER`
- `SERVER_PORT`
- `SERVER_SSH_KEY`

지금 기준 운영 기본값은 아님.

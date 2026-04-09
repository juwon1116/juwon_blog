# Juwon Blog

`main` 푸시 기준 배포 대상은 이제 `https://juwonpark.me` 하나만 사용합니다.

## Deploy

- 자동 배포: GitHub Pages
- 도메인: `https://juwonpark.me`
- 워크플로: `.github/workflows/jekyll-gh-pages.yml`
- 커스텀 도메인: `CNAME`

동작:

1. `main` push
2. GitHub Actions에서 Jekyll build
3. GitHub Pages로 배포
4. `juwonpark.me` 반영

## Current Policy

- legacy blog 서브도메인 기준 운영 안 함
- 서버 SSH 배포는 자동 실행 안 함
- `.github/workflows/deploy.yml` 은 legacy/manual 용도만 유지

## Local Check

```bash
bundle exec jekyll build --destination ./_site
```

## Auto Commit

블로그 내용 변경 없이 empty commit만 만들기:

```bash
./scripts/random-auto-commit.sh
```

기본 동작:

- 하루 1회 스케줄 실행
- 실행 시점마다 `1..20`개 랜덤 empty commit 생성
- 커밋 메시지에 `[auto-commit]` 포함
- auto-commit 푸시는 Pages/legacy server deploy 둘 다 skip

수동 dry-run:

```bash
DRY_RUN=1 MIN_COMMITS=2 MAX_COMMITS=4 ./scripts/random-auto-commit.sh
```

## Notes

- `scripts/` 는 Jekyll build 제외
- 프로덕션 기준 URL은 `_config.yml` 의 `url` / `website` 둘 다 `https://juwonpark.me`

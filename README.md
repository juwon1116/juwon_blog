# juwon_blog

**장고, 데브옵스, 자동화, AI 워크플로우를 짧고 실용적인 글로 정리하는 Jekyll 기반 개인 블로그입니다.**

`main` 브랜치에 푸시하면 GitHub Pages가 빌드하고, 커스텀 도메인 [`juwonpark.me`](https://juwonpark.me)로 배포됩니다.  
이번 버전은 홈 화면을 한국어 중심으로 재정리했고, 일부 기술 아이콘은 [ICONIC](https://github.com/YuheshPandian/ICONIC) 오픈소스 SVG를 로컬 자산으로 반입해 사용합니다.

## 무엇이 들어 있나

- 한국어 중심 개인 기술 블로그
- Jekyll + GitHub Pages 배포 파이프라인
- 홈, 소개, 검색, 아카이브, 글 상세 화면 커스텀 스타일
- `SimpleJekyllSearch` 기반 프론트 검색
- 랜덤 empty commit 생성용 보조 스크립트 포함

## 빠른 시작

```bash
bundle install
bundle exec jekyll serve
```

브라우저에서 `http://127.0.0.1:4000` 확인.

정적 결과만 확인하려면:

```bash
bundle exec jekyll build --destination ./_site
```

## 요구 사항

- Ruby 3.x 권장
- Bundler
- Jekyll `4.4.1`

## 기술 스택

| 영역 | 사용 기술 |
| --- | --- |
| 사이트 엔진 | Jekyll |
| 배포 | GitHub Pages, GitHub Actions |
| 스타일링 | 정적 CSS |
| 검색 | SimpleJekyllSearch |
| 도메인 | `juwonpark.me` |

## 주요 경로

```text
.
├── _includes/        # 헤더, 푸터, 메타, 검색 등 공통 조각
├── _layouts/         # 홈, 메뉴 페이지, 포스트 레이아웃
├── _pages/           # 소개, 검색, 태그, 아카이브
├── _posts/           # 블로그 포스트
├── assets/
│   ├── css/          # 사이트 스타일
│   ├── img/          # 프로필, 브랜딩, ICONIC 아이콘
│   └── js/           # 검색 및 기타 스크립트
├── scripts/          # 보조 자동화 스크립트
└── _config.yml       # 사이트 설정
```

## 자주 수정하는 파일

- 홈 화면: `index.html`
- 공통 스타일: `assets/css/main.css`
- 사이트 설정: `_config.yml`
- 소개 페이지: `_pages/about.html`
- 포스트 레이아웃: `_layouts/post.html`

## 배포 방식

배포 흐름:

1. `main` 브랜치에 푸시
2. GitHub Actions가 Jekyll 빌드 실행
3. GitHub Pages에 결과 업로드
4. `CNAME` 기준으로 `https://juwonpark.me` 반영

관련 파일:

- 워크플로: `.github/workflows/jekyll-gh-pages.yml`
- 도메인 설정: `CNAME`

## 검색

검색 페이지는 `search.json`을 기반으로 클라이언트에서 바로 필터링합니다.  
키워드, 도구명, 배포/운영 관련 문구를 빠르게 찾는 용도에 맞춰 가볍게 구성돼 있습니다.

## 보조 스크립트

랜덤 empty commit 생성:

```bash
./scripts/random-auto-commit.sh
```

dry-run 예시:

```bash
DRY_RUN=1 MIN_COMMITS=2 MAX_COMMITS=4 ./scripts/random-auto-commit.sh
```

## 디자인 메모

- 모든 주요 UI 카피를 한국어 중심으로 정리
- 다크/라이트 테마 토글 유지
- 홈과 소개 섹션에 `ICONIC` SVG 아이콘 사용
- 글 화면은 장식보다 가독성 우선

## 라이선스

이 저장소의 글과 커스텀 코드의 라이선스 정책이 별도로 필요하면 추후 명시해야 합니다.  
외부에서 반입한 `ICONIC` 아이콘은 원 저장소의 MIT 라이선스를 따릅니다.

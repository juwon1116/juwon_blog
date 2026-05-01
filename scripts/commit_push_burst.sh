#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: commit_push_burst.sh [options]

Options:
  --repo PATH                Git repository path. Default: current directory
  --count N                  Exact number of commit/push cycles
  --min N                    Minimum random count when --count is omitted. Default: 10
  --max N                    Maximum random count when --count is omitted. Default: 20
  --initial-message MSG      First real commit message when worktree is dirty
  --message-prefix MSG       Prefix for empty commits. Default: chore: auto-commit
  --branch NAME              Branch to push. Default: current branch
  --remote NAME              Remote to push. Default: origin
  -h, --help                 Show help
EOF
}

repo="."
count=""
min_count=10
max_count=20
initial_message="chore: commit burst seed"
message_prefix="chore: auto-commit"
branch=""
remote="origin"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:?missing repo path}"
      shift 2
      ;;
    --count)
      count="${2:?missing count}"
      shift 2
      ;;
    --min)
      min_count="${2:?missing min}"
      shift 2
      ;;
    --max)
      max_count="${2:?missing max}"
      shift 2
      ;;
    --initial-message)
      initial_message="${2:?missing initial message}"
      shift 2
      ;;
    --message-prefix)
      message_prefix="${2:?missing message prefix}"
      shift 2
      ;;
    --branch)
      branch="${2:?missing branch}"
      shift 2
      ;;
    --remote)
      remote="${2:?missing remote}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -n "$count" && ! "$count" =~ ^[0-9]+$ ]]; then
  echo "--count must be an integer" >&2
  exit 1
fi

if [[ ! "$min_count" =~ ^[0-9]+$ || ! "$max_count" =~ ^[0-9]+$ ]]; then
  echo "--min and --max must be integers" >&2
  exit 1
fi

if (( min_count < 1 || max_count < 1 || min_count > max_count )); then
  echo "Invalid min/max range" >&2
  exit 1
fi

if [[ -z "$count" ]]; then
  count=$(( min_count + RANDOM % (max_count - min_count + 1) ))
fi

if (( count < 1 )); then
  echo "--count must be >= 1" >&2
  exit 1
fi

cd "$repo"

if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null || true)" != "true" ]]; then
  echo "Not a git repository: $repo" >&2
  exit 1
fi

if [[ -z "$branch" ]]; then
  branch="$(git branch --show-current)"
fi

if [[ -z "$branch" ]]; then
  echo "Could not determine current branch" >&2
  exit 1
fi

push_with_rebase() {
  if git push "$remote" "$branch"; then
    return 0
  fi

  echo "Push rejected. Attempting pull --rebase on ${remote}/${branch}..." >&2
  if ! git pull --rebase "$remote" "$branch"; then
    echo "Rebase failed. Resolve conflicts and rerun." >&2
    exit 1
  fi

  git push "$remote" "$branch"
}

dirty=0
if [[ -n "$(git status --porcelain)" ]]; then
  dirty=1
fi

completed=0
if (( dirty == 1 )); then
  git add -A
  git commit -m "$initial_message"
  push_with_rebase
  completed=1
fi

width=${#count}
for (( i = completed + 1; i <= count; i++ )); do
  printf -v message "%s %0*d of %d" "$message_prefix" "$width" "$i" "$count"
  git commit --allow-empty -m "$message"
  push_with_rebase
done

echo "count=$count"
echo "dirty_first_commit=$dirty"
echo "branch=$branch"
echo "remote=$remote"
echo "head=$(git rev-parse --short HEAD)"
git status --short --branch

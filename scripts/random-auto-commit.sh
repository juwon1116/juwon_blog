#!/usr/bin/env bash
set -euo pipefail

TZ_NAME="${TZ_NAME:-Asia/Seoul}"
MIN_COMMITS="${MIN_COMMITS:-1}"
MAX_COMMITS="${MAX_COMMITS:-20}"
MESSAGE_PREFIX="${MESSAGE_PREFIX:-chore: daily auto-commit [auto-commit]}"
DRY_RUN="${DRY_RUN:-0}"

if ! [[ "$MIN_COMMITS" =~ ^[0-9]+$ && "$MAX_COMMITS" =~ ^[0-9]+$ ]]; then
  echo "MIN_COMMITS/MAX_COMMITS must be integers" >&2
  exit 1
fi

if (( MIN_COMMITS < 1 || MAX_COMMITS < MIN_COMMITS )); then
  echo "Expected 1 <= MIN_COMMITS <= MAX_COMMITS" >&2
  exit 1
fi

plan_file="$(mktemp)"
trap 'rm -f "$plan_file"' EXIT

TZ_NAME="$TZ_NAME" MIN_COMMITS="$MIN_COMMITS" MAX_COMMITS="$MAX_COMMITS" python3 <<'PY' > "$plan_file"
import os
import random
from datetime import datetime
from zoneinfo import ZoneInfo

tz = ZoneInfo(os.environ["TZ_NAME"])
minimum = int(os.environ["MIN_COMMITS"])
maximum = int(os.environ["MAX_COMMITS"])

now = datetime.now(tz)
start = now.replace(hour=0, minute=0, second=0, microsecond=0)
window = max(int((now - start).total_seconds()), 1)
count = random.randint(minimum, maximum)

offsets = sorted(random.randint(0, window) for _ in range(count))
print(count)
for offset in offsets:
    dt = start.fromtimestamp(start.timestamp() + offset, tz)
    print(dt.strftime("%Y-%m-%dT%H:%M:%S%z"))
PY

COUNT="$(head -n 1 "$plan_file")"
echo "planned_commits=$COUNT"

tail -n +2 "$plan_file" | while IFS= read -r ts; do
  human_ts="$(TZ="$TZ_NAME" date -j -f "%Y-%m-%dT%H:%M:%S%z" "$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || true)"
  if [[ -z "$human_ts" ]]; then
    human_ts="$ts"
  fi

  message="$MESSAGE_PREFIX $human_ts"
  echo "$message"

  if [[ "$DRY_RUN" == "1" ]]; then
    continue
  fi

  GIT_AUTHOR_DATE="$ts" \
  GIT_COMMITTER_DATE="$ts" \
    git commit --allow-empty -m "$message"
done

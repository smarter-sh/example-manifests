#!/usr/bin/env bash
# Download the logs of a GitHub Actions run's failed jobs, and pull out the pre-commit hooks that failed.
#
#   skills/example-manifests-ci-failures/scripts/fetch-run-logs.sh <run or job url, or run id> [output dir]
#
# For each failed job it writes <output dir>/<job id>.log (the whole log, without terminal colors or timestamps)
# and <output dir>/<job id>.failures.txt (each failed hook's block, and the diff the hooks made), and prints the
# run's commit, its jobs, and the failures. The output dir defaults to a new temporary folder. A job url
# (.../job/<id>) fetches that job only, failed or not.
#
# It uses the gh cli, with your gh login or GH_TOKEN, else GH_TOKEN (or GITHUB_TOKEN) from the repository's .env,
# without printing it. GitHub's api sometimes answers 502 or 503; each call is
# retried. Adapted from smarter-sh/smarter's skills/smarter-ci-failures/scripts/fetch-run-logs.sh.
set -euo pipefail

url="${1:?usage: fetch-run-logs.sh <run or job url, or run id> [output dir]}"
out="${2:-$(mktemp -d -t example-manifests-ci-XXXXXX)}"
mkdir -p "$out"

repo="smarter-sh/example-manifests"
if [[ "$url" =~ github\.com/([^/]+/[^/]+)/actions/runs/([0-9]+)(/job/([0-9]+))? ]]; then
  repo="${BASH_REMATCH[1]}"
  run="${BASH_REMATCH[2]}"
  job="${BASH_REMATCH[4]:-}"
elif [[ "$url" =~ ^[0-9]+$ ]]; then
  run="$url"
  job=""
else
  echo "Not a GitHub Actions run url: $url" >&2
  exit 2
fi

cd "$(git rev-parse --show-toplevel)"

# Credentials: gh's login or GH_TOKEN, else the GH_TOKEN (or GITHUB_TOKEN) in the repository's .env, which
# replaces a stale token in the environment. The token is never printed.
if ! gh api rate_limit >/dev/null 2>&1 && [ -f .env ]; then
  unset GITHUB_TOKEN
  GH_TOKEN="$(grep -E '^(GH_TOKEN|GITHUB_TOKEN)=' .env | head -1 | cut -d= -f2- | tr -d "\"'" || true)"
  export GH_TOKEN
fi
if ! gh api rate_limit >/dev/null 2>&1; then
  echo "GitHub's api refused your credentials, and it needs them to download job logs. Run gh auth login, or" >&2
  echo "put GH_TOKEN=<token> in this repository's .env." >&2
  exit 1
fi

# gh api, retried: GitHub's api answers 502 and 503 now and then, the run's logs included.
api() {
  local attempt
  for attempt in 1 2 3 4 5; do
    if gh api --allow-escape-sequences "$@"; then
      return 0
    fi
    echo "  (gh api $1 failed, attempt $attempt of 5; retrying)" >&2
    sleep $((attempt * 5))
  done
  return 1
}

# terminal colors, which the logs keep, and which gh refuses to print without --allow-escape-sequences.
strip_colors() { sed $'s/\x1b\\[[0-9;]*[A-Za-z]//g'; }

echo "Run $run of $repo:"
api "repos/$repo/actions/runs/$run" \
  --jq '"  \(.name), \(.event) on \(.head_branch) at \(.head_sha[0:9]): \(.conclusion // .status)\n  \(.html_url)"'
echo "  commit: $(api "repos/$repo/commits/$(api "repos/$repo/actions/runs/$run" --jq .head_sha)" --jq '.commit.message | split("\n")[0]')"
echo
echo "Jobs:"
api "repos/$repo/actions/runs/$run/jobs?per_page=100" --jq '.jobs[] | "  \(.conclusion // .status)\t\(.id)\t\(.name)"'

if [ -n "$job" ]; then
  jobs="$job"
else
  jobs="$(api "repos/$repo/actions/runs/$run/jobs?per_page=100" \
    --jq '.jobs[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled") | .id')"
fi
if [ -z "$jobs" ]; then
  echo
  echo "No failed jobs."
  exit 0
fi

for id in $jobs; do
  log="$out/$id.log"
  failures="$out/$id.failures.txt"
  # Each line starts with a timestamp, e.g. "2026-11-01T12:34:56.1234567Z ": cut it.
  api "repos/$repo/actions/jobs/$id/logs" | strip_colors | cut -c30- >"$log"
  {
    # pre-commit prints one "<hook name>....Passed|Failed|Skipped" line per hook, and after a Failed line, the
    # hook's id, exit code and output. Print each Failed block, up to the next hook's result line.
    awk '
      /\.\.\.+(\([^)]*\))?(Passed|Skipped|Failed)$/ { inblock = ($0 ~ /Failed$/) }
      inblock { print }
    ' "$log"
    # --show-diff-on-failure: the changes the hooks made themselves.
    awk '/^pre-commit hook\(s\) made changes/ { indiff = 1 } /^##\[error\]/ { indiff = 0 } indiff { print }' "$log"
    grep -nE '##\[error\]' "$log" || true
  } >"$failures"
  echo
  echo "=== job $id: $log"
  if [ -s "$failures" ]; then
    cat "$failures"
  else
    echo "(no failed hook found: read the log's end)"
    tail -40 "$log"
  fi
done

echo
echo "Logs and failures are in $out"

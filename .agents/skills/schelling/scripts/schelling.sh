#!/usr/bin/env bash
set -euo pipefail

API_BASE="${SCHELLING_API_BASE:-https://api.schelling.sh}"

usage() {
  cat <<'EOF'
Usage:
  schelling.sh post [-|<file.json>]              # JSON body: {"problems":["..."]} from stdin or file
  schelling.sh post "<p1>" ["<p2>" ...]          # one or more problem strings
  schelling.sh follow_up <cid> "<residue>"

Posting streams responses from the API (event session, then post with items[] / cids, then respond events while the connection stays open). Use curl -N.

Env:
  SCHELLING_API_BASE   Override API base URL (default: https://api.schelling.sh)
EOF
}

require_arg() {
  local value="${1:-}"
  local name="${2:-arg}"
  if [[ -z "$value" ]]; then
    echo "Missing required argument: $name" >&2
    usage >&2
    exit 1
  fi
}

build_problems_json() {
  if command -v jq >/dev/null 2>&1; then
    jq -n --args '$ARGS.positional | {problems: .}' -- "$@"
  elif command -v python3 >/dev/null 2>&1; then
    PYTHONDONTWRITEBYTECODE=1 python3 -c 'import json,sys; print(json.dumps({"problems":sys.argv[1:]}))' -- "$@"
  else
    echo "schelling.sh: need jq or python3 to build JSON from problem arguments." >&2
    exit 1
  fi
}

post_many_curl_payload() {
  curl -sS -N "${API_BASE}/post_many" \
    -H "Content-Type: application/json" \
    --data-binary "$1"
}

post_many_curl_file() {
  curl -sS -N "${API_BASE}/post_many" \
    -H "Content-Type: application/json" \
    --data-binary @"$1"
}

post_many_curl_stdin() {
  curl -sS -N "${API_BASE}/post_many" \
    -H "Content-Type: application/json" \
    --data-binary @-
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

first="${1:-}"
case "$first" in
  follow_up)
    shift
    cid="${1:-}"
    residue="${2:-}"
    require_arg "$cid" "cid"
    require_arg "$residue" "residue"
    curl -sS -X POST "${API_BASE}/follow_up/${cid}" \
      -H "Content-Type: application/json" \
      -d "{\"residue\":\"${residue//\"/\\\"}\"}"
    ;;

  post|post_many)
    shift
    if [[ $# -eq 0 ]]; then
      echo "post: pass \"-\", a JSON file path, or one or more problem strings." >&2
      exit 1
    fi
    if [[ "$1" == "-" ]]; then
      post_many_curl_stdin
    elif [[ $# -eq 1 && -f "$1" ]]; then
      post_many_curl_file "$1"
    else
      body="$(build_problems_json "$@")"
      post_many_curl_payload "$body"
    fi
    ;;

  -h|--help|help)
    usage
    ;;

  *)
    echo "Unknown command: $first" >&2
    usage >&2
    exit 1
    ;;
esac

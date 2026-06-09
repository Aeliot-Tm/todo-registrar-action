#!/usr/bin/env bash
set -euo pipefail

# Fixed context for deterministic fixture comparison.
# Uses the same variable names as action.yml, overridden via env(1).
exec env \
  GITHUB_SERVER_URL=https://github.com \
  GITHUB_REPOSITORY=owner/repo \
  GITHUB_RUN_ID=12345678 \
  COMMIT_SHA=abcdef1234567890abcdef1234567890abcdef12 \
  "$(dirname "$0")/build-pr-body.sh" "$@"

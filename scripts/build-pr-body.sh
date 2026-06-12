#!/usr/bin/env bash
set -euo pipefail

REPORT_PATH="${1:?report path required}"
PR_BODY_PATH="${2:?PR body output path required}"
LOGO_URL="${3:-https://raw.githubusercontent.com/Aeliot-Tm/todo-registrar-action/main/docs/logo-in-comment.svg}"
ACTION_MARKETPLACE_URL="https://github.com/marketplace/actions/todo-registrar"
ACTION_LINK="[TODO Registrar Action](https://github.com/Aeliot-Tm/todo-registrar-action)"

pluralize() {
  local count="$1"
  local singular="$2"
  local plural="$3"

  if [[ "$count" == "1" ]]; then
    echo "$singular"
  else
    echo "$plural"
  fi
}

write_alert() {
  local registered="$1"
  local new_issues="$2"
  local glued="$3"
  local analyzed="$4"

  if [[ "$registered" -eq 0 ]]; then
    echo "> [!TIP]"
    if [[ -n "$analyzed" ]]; then
      echo "> No new TODOs to register. Scanned **${analyzed}** $(pluralize "$analyzed" "file" "files"), nothing changed."
    else
      echo "> No new TODOs to register."
    fi
  elif [[ "$new_issues" -gt 0 ]]; then
    echo "> [!NOTE]"
    echo "> Automated registration of TODO comments by ${ACTION_LINK}."
  elif [[ "$glued" -gt 0 ]]; then
    echo "> [!IMPORTANT]"
    echo "> All registered TODOs were linked to existing issues. No new tracker tickets were created."
  else
    echo "> [!NOTE]"
    echo "> Automated registration of TODO comments by ${ACTION_LINK}."
  fi
}

write_footer() {
  local server_url="${GITHUB_SERVER_URL:-https://github.com}"
  local repository="${GITHUB_REPOSITORY:-}"
  local run_id="${GITHUB_RUN_ID:-}"
  local commit_sha="${COMMIT_SHA:-}"

  [[ -n "$run_id" && -n "$repository" ]] || return 0

  local workflow_url="${server_url}/${repository}/actions/runs/${run_id}"
  local footer="> Run by [workflow #${run_id}](${workflow_url})"

  if [[ -n "$commit_sha" ]]; then
    footer+=" · [view changes](${server_url}/${repository}/commit/${commit_sha})"
  fi

  echo ""
  echo "$footer"
}

{
  echo '<div align="center">'
  echo ""
  echo "[![TODO Registrar](${LOGO_URL})](${ACTION_MARKETPLACE_URL})"
  echo ""
  echo '</div>'
  echo ""

  if [[ -f "$REPORT_PATH" ]]; then
    read -r REGISTERED NEW_ISSUES GLUED <<< "$(jq -r '.summary.todos | "\(.registered) \(.newIssues) \(.glued)"' "$REPORT_PATH")"
    ANALYZED="$(jq -r '.summary.files.analyzed // empty' "$REPORT_PATH")"
    UPDATED_FILES="$(jq '[.files[]? | select(.summary.todos.registered > 0)] | length' "$REPORT_PATH")"

    write_alert "$REGISTERED" "$NEW_ISSUES" "$GLUED" "$ANALYZED"
    echo ""
    echo "---"
    echo ""
    echo "## Processing summary"
    echo ""

    echo "| Registered | New issues | Glued |"
    echo "| :--------: | :--------: | :---: |"
    echo "| **${REGISTERED}** | **${NEW_ISSUES}** | **${GLUED}** |"
    echo ""
    echo "- **Registered** — TODO comments that received an issue key"
    echo "- **New issues** — new issues created in the tracker"
    echo "- **Glued** — TODOs that reused an existing issue key"

    if [[ "$UPDATED_FILES" -gt 0 ]]; then
      echo ""
      echo "<details>"
      echo "<summary><strong>Updated files</strong> (${UPDATED_FILES})</summary>"
      echo ""
      echo "| File | Registered TODOs |"
      echo "|------|-----------------:|"
      jq -r '.files | map(select(.summary.todos.registered > 0)) | sort_by(-.summary.todos.registered) | .[] | "| `\(.path)` | \(.summary.todos.registered) |"' "$REPORT_PATH"
      echo ""
      echo "</details>"
    fi

    write_footer
  else
    echo "> [!WARNING]"
    echo "> Processing report is not available."
    write_footer
  fi
} > "$PR_BODY_PATH"

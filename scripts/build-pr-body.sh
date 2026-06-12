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

write_logo_linked() {
  echo "<a href=\"${ACTION_MARKETPLACE_URL}\"><img src=\"${LOGO_URL}\" alt=\"TODO Registrar\" /></a>"
}

write_empty_header() {
  local analyzed="$1"

  echo '<table>'
  echo '<tr>'
  echo '<td align="center" valign="middle" width="40%">'
  write_logo_linked
  echo '</td>'
  echo '<td valign="middle">'
  echo ""
  echo "> [!TIP]"
  if [[ -n "$analyzed" ]]; then
    echo "> No new TODOs to register. Scanned **${analyzed}** $(pluralize "$analyzed" "file" "files"), nothing changed."
  else
    echo "> No new TODOs to register."
  fi
  echo ""
  echo '</td>'
  echo '</tr>'
  echo '</table>'
}

write_metrics_header() {
  local registered="$1"
  local new_issues="$2"
  local glued="$3"

  echo '<table>'
  echo '<tr>'
  echo '<td rowspan="2" align="center" valign="middle" width="40%">'
  write_logo_linked
  echo '</td>'
  echo '<th align="center">Registered</th>'
  echo '<th align="center">New issues</th>'
  echo '<th align="center">Glued</th>'
  echo '</tr>'
  echo '<tr>'
  echo "<td align=\"center\"><strong>${registered}</strong></td>"
  echo "<td align=\"center\"><strong>${new_issues}</strong></td>"
  echo "<td align=\"center\"><strong>${glued}</strong></td>"
  echo '</tr>'
  echo '</table>'
}

write_missing_report_header() {
  echo '<table>'
  echo '<tr>'
  echo '<td align="center" valign="middle" width="40%">'
  write_logo_linked
  echo '</td>'
  echo '<td valign="middle">'
  echo ""
  echo "> [!WARNING]"
  echo "> Processing report is not available."
  echo ""
  echo '</td>'
  echo '</tr>'
  echo '</table>'
}

write_created_issues() {
  local report_path="$1"
  local created_issues_count

  created_issues_count="$(jq '[.issues[]?] | length' "$report_path")"
  [[ "$created_issues_count" -gt 0 ]] || return 0

  echo "<details>"
  echo "<summary><strong>Created issues</strong> (${created_issues_count})</summary>"
  echo ""
  echo "| Issue | TODOs |"
  echo "|-------|------:|"
  jq -r '.issues[]? | "| `\(.key)` | \(.usageCounter) |"' "$report_path"
  echo ""
  echo "</details>"
}

write_metric_legend() {
  echo "<details>"
  echo "<summary><strong>Metric definitions</strong></summary>"
  echo ""
  echo "- **Registered** — TODO comments that received an issue key"
  echo "- **New issues** — new issues created in the tracker"
  echo "- **Glued** — TODOs that reused an existing issue key"
  echo ""
  echo "</details>"
}

write_alert() {
  local registered="$1"
  local new_issues="$2"
  local glued="$3"

  if [[ "$new_issues" -gt 0 ]]; then
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

{
  if [[ -f "$REPORT_PATH" ]]; then
    read -r REGISTERED NEW_ISSUES GLUED <<< "$(jq -r '.summary.todos | "\(.registered) \(.newIssues) \(.glued)"' "$REPORT_PATH")"
    ANALYZED="$(jq -r '.summary.files.analyzed // empty' "$REPORT_PATH")"
    UPDATED_FILES="$(jq '[.files[]? | select(.summary.todos.registered > 0)] | length' "$REPORT_PATH")"

    if [[ "$REGISTERED" -eq 0 ]]; then
      write_empty_header "$ANALYZED"
    else
      write_metrics_header "$REGISTERED" "$NEW_ISSUES" "$GLUED"
      echo ""
      write_alert "$REGISTERED" "$NEW_ISSUES" "$GLUED"

      CREATED_ISSUES_COUNT="$(jq '[.issues[]?] | length' "$REPORT_PATH")"
      if [[ "$CREATED_ISSUES_COUNT" -gt 0 ]]; then
        echo ""
        write_created_issues "$REPORT_PATH"
      fi

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

      echo ""
      write_metric_legend
    fi
  else
    write_missing_report_header
  fi
} > "$PR_BODY_PATH"

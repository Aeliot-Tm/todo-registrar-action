# Using outputs

TODO Registrar Action exposes workflow outputs so later steps can react to what happened during the run.

All outputs are **strings**. In expressions and shell conditions, compare them to `'true'` and `'false'`, not to boolean values.

| Output | Type | When set |
|--------|------|----------|
| `current_branch` | string | Always — branch checked out at the start of the action |
| `template_branch` | string | Always — raw `new_branch_name` input before placeholder substitution |
| `new_branch` | string | Always — resolved working branch name |
| `target_branch` | string | Always — target branch for a pull request |
| `skipped` | `'true'` / `'false'` | Always — `true` when processing was skipped (open PR, branch behind remote, etc.) |
| `has_changes` | `'true'` / `'false'` | Always — `true` when todo-registrar changes were committed and pushed |

Give the action step an `id` to read its outputs:

```yaml
- name: Register TODOs
  id: registrar
  uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar
```

Reference outputs as `steps.<id>.outputs.<name>`, for example `steps.registrar.outputs.skipped`.

## React to skip

When `skipped` is `true`, later action steps did not run (no Docker scan, no commit, no PR). The workflow still succeeds; check the workflow annotation for the reason.

```yaml
- name: Register TODOs
  id: registrar
  uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: '{current}-todo-registrar-{runner_id}'
    check_opened: like

- name: Log skip reason
  if: steps.registrar.outputs.skipped == 'true'
  run: echo "Registrar skipped — an open PR or remote branch state blocked processing."

- name: Continue only when processed
  if: steps.registrar.outputs.skipped != 'true'
  run: echo "Registrar ran on branch ${{ steps.registrar.outputs.new_branch }}"
```

## React to changes

Use `has_changes` to run follow-up steps only when files were updated and pushed:

```yaml
- name: Register TODOs
  id: registrar
  uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar

- name: Notify about new PR
  if: steps.registrar.outputs.has_changes == 'true'
  run: |
    echo "Changes pushed to branch: ${{ steps.registrar.outputs.new_branch }}"
    echo "Target branch for PR: ${{ steps.registrar.outputs.target_branch }}"
```

Remember: `has_changes` is `false` when there was nothing to commit **or** when the action was skipped.

## Combine `skipped` and `has_changes`

Typical outcomes:

| `skipped` | `has_changes` | Meaning |
|-----------|---------------|---------|
| `true` | `false` | Processing blocked before todo-registrar ran |
| `false` | `false` | Scan ran, but no TODO updates were committed |
| `false` | `true` | TODO comments were updated and pushed |

```yaml
- name: Register TODOs
  id: registrar
  uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar

- name: Summary
  if: always()
  run: |
    echo "skipped=${{ steps.registrar.outputs.skipped }}"
    echo "has_changes=${{ steps.registrar.outputs.has_changes }}"
    echo "new_branch=${{ steps.registrar.outputs.new_branch }}"
```

## Branch metadata

Branch outputs are useful for logging, notifications, or custom automation:

```yaml
- name: Print branch resolution
  if: steps.registrar.outputs.skipped != 'true'
  run: |
    echo "Template:  ${{ steps.registrar.outputs.template_branch }}"
    echo "Resolved:  ${{ steps.registrar.outputs.new_branch }}"
    echo "Current:   ${{ steps.registrar.outputs.current_branch }}"
    echo "PR target: ${{ steps.registrar.outputs.target_branch }}"
```

When `new_branch` equals `target_branch`, the action commits to the current branch and does not open a pull request (even if `has_changes` is `true`).

## Pass outputs to another job

Job outputs must be declared explicitly. Example: run registrar in one job and notify in another:

```yaml
jobs:
  register:
    runs-on: ubuntu-latest
    outputs:
      skipped: ${{ steps.registrar.outputs.skipped }}
      has_changes: ${{ steps.registrar.outputs.has_changes }}
      new_branch: ${{ steps.registrar.outputs.new_branch }}
    steps:
      - uses: actions/checkout@v4

      - name: Register TODOs
        id: registrar
        uses: Aeliot-Tm/todo-registrar-action@1.6.6
        with:
          config_path: .todo-registrar.yaml
          new_branch_name: todo-registrar

  notify:
    needs: register
    if: needs.register.outputs.has_changes == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: echo "TODO updates on branch ${{ needs.register.outputs.new_branch }}"
```

## Workflow summary

Write a short summary to the Actions run page:

```yaml
- name: Register TODOs
  id: registrar
  uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar

- name: Job summary
  if: always()
  run: |
    {
      echo "### TODO Registrar"
      echo ""
      echo "| Output | Value |"
      echo "|--------|-------|"
      echo "| skipped | \`${{ steps.registrar.outputs.skipped }}\` |"
      echo "| has_changes | \`${{ steps.registrar.outputs.has_changes }}\` |"
      echo "| new_branch | \`${{ steps.registrar.outputs.new_branch }}\` |"
      echo "| target_branch | \`${{ steps.registrar.outputs.target_branch }}\` |"
    } >> "$GITHUB_STEP_SUMMARY"
```

## Related documentation

- [How it works](how-it-works.md) — when outputs are set during the workflow
- [Inputs reference](../README.md#inputs) — options that affect branch and skip behavior

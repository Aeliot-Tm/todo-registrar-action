# Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `check_opened` | No | `true` | Check for open PRs: `true` (exact match), `like` (pattern match for templates), `false` (skip check) |
| `config` | No* | | Inline YAML configuration (recommended) |
| `config_path` | No* | | Path to configuration file (relative to workspace) |
| `env_vars` | No | | Environment variable names to pass to container (newline or space separated) |
| `new_branch_name` | No** | | Branch name or template with placeholders. If empty, stays on the current branch |
| `target_branch_name` | No** | | Target branch for pull request. If empty, uses the current branch |
| `user_email` | No | `action@github.com` | Git user email for commits |
| `user_name` | No | `GitHub Action` | Git user name for commits |
| `verbosity` | No | `normal` | Verbosity level: `quiet`, `normal`, `verbose`, `very-verbose`, `debug` |

> \* If neither `config_path` nor `config` is provided, todo-registrar will check default configuration paths (see [Configuration](configuration.md)).
>
> \** You can define flexible PR workflows using branch name templates.
> If both `new_branch_name` and `target_branch_name` are omitted or equal, no pull request is created,
> but changes are still pushed.

## The `new_branch_name` option

The `new_branch_name` option supports template placeholders that are replaced at runtime. All placeholders are **case-insensitive**.

| Placeholder | Description |
|-------------|-------------|
| `{current}` | Current branch name |
| `{runner_id}`, `{runnerId}` | GitHub workflow run ID (`github.run_id`) |
| `{random}` | Random alphanumeric string (5 characters by default) |
| `{random:N}` | Random alphanumeric string of N characters (e.g., `{random:10}`) |

**Template resolution examples:**

| Template | Resolved Branch Name |
|---|---|
| `{current}-todo-registrar-{random}` | `main-todo-registrar-a1b2c` |
| `{current}-{runner_id}-todo-registrar` | `main-12345678-todo-registrar` |
| `todo-registrar-{random:10}` | `todo-registrar-a1b2c3d4e5` |

> **Note:** The typo `{curent}` (single 'r') is also supported but will produce a warning.

## The `check_opened` option

The `check_opened` option helps avoid duplicate tickets. It is strongly recommended to enable it.

**Values:**

| Value | Description |
|-------|-------------|
| `true` | Exact match — checks for open PRs with the exact branch name |
| `like` | Pattern match — checks for open PRs matching the template pattern |
| `false` | Skip check — no PR checking is performed |

**Behavior:**

- **`true` (exact match)**: Checks for existing open PRs from `new_branch_name` to `target_branch_name`. Skips processing if found.
- **`like` (pattern match)**: Converts the `new_branch_name` template to a regex pattern and checks if any open PR's head branch matches. Useful when branch names contain dynamic parts like `{runner_id}` or `{random}`.
  - `{current}` → matches literal current branch name
  - `{runner_id}`, `{runnerId}` → matches any digits (`[0-9]+`)
  - `{random}`, `{random:N}` → matches alphanumeric characters (`[0-9a-z]+`)
- **Branch behind check** (for both `true` and `like`): If `new_branch_name` differs from current branch and exists on remote, checks if current HEAD is behind the remote branch. Skips processing if behind to avoid push conflicts.

> **NOTE:** When processing is skipped, the action still succeeds (does not fail) and adds a workflow annotation explaining why.
>
> ![annotation.png](annotation.png)

## Related documentation

- [Examples](examples.md) — workflow YAML using these inputs
- [Using outputs](outputs.md) — action outputs after a run
- [How it works](how-it-works.md) — where inputs are applied in the workflow
- [Configuration](configuration.md) — todo-registrar config file format

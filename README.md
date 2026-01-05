![logo.svg](docs/logo.svg)

[![GitHub Release](https://img.shields.io/github/v/release/Aeliot-Tm/todo-registrar-action?label=Release)](https://packagist.org/packages/aeliot/todo-registrar-action)
[![GitHub License](https://img.shields.io/github/license/Aeliot-Tm/todo-registrar-action?label=License)](LICENSE)

# TODO Registrar Action

GitHub Action for finding TODO comments in code and automatically creating issues in your issue tracker.

This action uses Docker container of **[TODO registrar](https://github.com/Aeliot-Tm/todo-registrar)**.

### Features

- Scans your codebase for TODO/FIXME/etc comments.
- Automatically creates issues in supported issue trackers (GitHub, GitLab, JIRA).
- Injects issue IDs back into TODO comments to prevent duplicates.
- Supports inline configuration for flexible issue customization.

Action adds numbers of ticket inside TODOs in the code and makes commit. It permits to avoid creation
of duplicated tickets, and you don't need in 'supporting database'. All saved in your repository.

## Usage

Create a workflow file in your `.github/workflows/todo-registrar.yaml` directory with the following contents:
```yaml
name: TODO registrar

on:
  push:
    branches: [ "main" ] # or "master" or "develop" (depends on your repository)

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: TODO registrar
        uses: Aeliot-Tm/todo-registrar-action@1.1.0
        with:
          check_opened: true
          new_branch_name: todo-registrar
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `check_opened` | No | | Check if exists opened PR from new branch to target or not. Processing skipped if exists. Default: false |
| `config` | No* | | Inline YAML configuration |
| `config_path` | No* | | Path to configuration file (relative to workspace) |
| `env_vars` | No | | Environment variable names to pass to container (newline or space separated) |
| `new_branch_name` | No** | | Name of new branch to create for changes. If empty - stay on current branch |
| `target_branch_name` | No** | | Target branch for pull request. If empty - use current branch |
| `user_email` | No | `action@github.com` | Git user email for commits |
| `user_name` | No | `GitHub Action` | Git user name for commits |
| `verbosity` | No | `normal` | Verbosity level: `quiet`, `normal`, `verbose`, `very-verbose`, `debug` |

\* Either `config_path` or `config` must be provided.

\** You may create flexible scenarios for the maintaining of PRs' with branch names.
If omitted both `new_branch_name` and `target_branch_name` or they are the same then PR will not be created
but changes will be pushed.

### Option check_opened

Option `check_opened` is important to avoid creation of duplicated tickets. It is strongly recommended to set `true` to it.

## Examples

### With configuration file

```yaml
- uses: Aeliot-Tm/todo-registrar-action@v1
  with:
    config_path: .todo-registrar.yaml
```

### With inline configuration

```yaml
- uses: Aeliot-Tm/todo-registrar-action@v1
  with:
    config: |
      paths:
        in: /code/src
      registrar:
        type: GitHub
        options:
          service:
            personalAccessToken: ${{ secrets.GITHUB_TOKEN }}
            owner: ${{ github.repository_owner }}
            repository: ${{ github.event.repository.name }}
```

### With environment variables

Use `env_vars` to securely pass environment variables (e.g., secrets) into the container.
Variables are defined in the standard `env` section and their names are listed in `env_vars`.
This works with both `config_path` and inline `config`:

**With config file:**

```yaml
- uses: Aeliot-Tm/todo-registrar-action@v1
  env:
    GITHUB_TOKEN: ${{ secrets.TODO_REGISTRAR_TOKEN }}
    GITHUB_OWNER: ${{ github.repository_owner }}
    GITHUB_REPO: ${{ github.event.repository.name }}
  with:
    config_path: .todo-registrar.yaml
    env_vars: |
      GITHUB_TOKEN
      GITHUB_OWNER
      GITHUB_REPO
```

In your `.todo-registrar.yaml`, reference these variables using the `%env()%` syntax:

```yaml
registrar:
  type: GitHub
  options:
    service:
      personalAccessToken: '%env(GITHUB_TOKEN)%'
      owner: '%env(GITHUB_OWNER)%'
      repository: '%env(GITHUB_REPO)%'
```

**With inline config:**

```yaml
- uses: Aeliot-Tm/todo-registrar-action@v1
  env:
    GITHUB_TOKEN: ${{ secrets.TODO_REGISTRAR_TOKEN }}
    GITHUB_OWNER: ${{ github.repository_owner }}
    GITHUB_REPO: ${{ github.event.repository.name }}
  with:
    env_vars: |
      GITHUB_TOKEN
      GITHUB_OWNER
      GITHUB_REPO
    config: |
      registrar:
        type: GitHub
        options:
          service:
            personalAccessToken: '%env(GITHUB_TOKEN)%'
            owner: '%env(GITHUB_OWNER)%'
            repository: '%env(GITHUB_REPO)%'
```

### With automatic branch and pull request

The action can automatically create a new branch, commit changes, push, and create a pull request:

```yaml
- uses: Aeliot-Tm/todo-registrar-action@v1
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar-${{ github.run_id }}
```

**Git workflow behavior:**

- If `new_branch_name` is not provided, changes are committed to the current branch
- If `target_branch_name` is not provided, it defaults to the current branch
- Pull request is created only when `new_branch_name` differs from `target_branch_name`
- If there are no changes to commit, push and PR creation are skipped

**Custom git user configuration:**

```yaml
- uses: Aeliot-Tm/todo-registrar-action@v1
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar
    user_name: 'My Bot'
    user_email: 'bot@example.com'
```

## Configuration

For detailed configuration options, see the [TODO registrar documentation](https://github.com/Aeliot-Tm/todo-registrar/blob/main/docs/config/global_config_yaml.md).

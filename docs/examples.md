# Examples

Workflow snippets for common setups. Replace `@1.6.6` with the [release version](https://github.com/Aeliot-Tm/todo-registrar-action/releases) you want to pin.

## With default configuration paths

If you have a configuration file at one of the default paths checked by todo-registrar (e.g., `.todo-registrar.yaml`, `.todo-registrar.yml`, etc.), you can omit both `config_path` and `config`:

```yaml
- uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    new_branch_name: todo-registrar
```

## With configuration file

```yaml
- uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar
```

## With inline configuration

```yaml
- uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config: |
      paths:
        in: /code/src
      registrar:
        type: GitHub
        options:
          service:
            personalAccessToken: ${{ secrets.GITHUB_TOKEN }}
            repository: "${{ github.repository }}"
    new_branch_name: todo-registrar
```

## With environment variables

Use `env_vars` to securely pass environment variables (e.g., secrets) into the container.
Variables are defined in the standard `env` section and their names are listed in `env_vars`.
This works with both `config_path` and inline `config`.

**With config file:**

```yaml
- uses: Aeliot-Tm/todo-registrar-action@1.6.6
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    GITHUB_REPO: "${{ github.repository }}"
  with:
    config_path: .todo-registrar.yaml
    env_vars: |
      GITHUB_TOKEN
      GITHUB_REPO
    new_branch_name: todo-registrar
```

In your `.todo-registrar.yaml`, reference these variables using the `%env()%` syntax:

```yaml
registrar:
  type: GitHub
  options:
    service:
      personalAccessToken: '%env(GITHUB_TOKEN)%'
      repository: '%env(GITHUB_REPO)%'
```

**With inline config:**

```yaml
- uses: Aeliot-Tm/todo-registrar-action@1.6.6
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    env_vars: |
      GITHUB_TOKEN
      GITHUB_REPO
    config: |
      registrar:
        type: GitHub
        options:
          service:
            personalAccessToken: '%env(GITHUB_TOKEN)%'
            repository: '${{ github.repository }}'
    new_branch_name: todo-registrar
```

## With automatic branch and pull request

The action can automatically create a new branch, commit changes, push, and create a pull request:

```yaml
- uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: '{current}-todo-registrar-{runner_id}'
    check_opened: 'like'
```

This creates a branch like `main-todo-registrar-12345678` and uses pattern matching to detect any existing PR with a similar name pattern.

**Git workflow behavior:**

- If `new_branch_name` is not provided, changes are committed to the current branch
- If `target_branch_name` is not provided, it defaults to the current branch
- A pull request is created only when `new_branch_name` differs from `target_branch_name`
- If there are no changes to commit, push and PR creation are skipped

See [Pull request body and processing report](pull-request-report.md) for PR title, summary metrics, and example descriptions.

## Custom Git user configuration

```yaml
- uses: Aeliot-Tm/todo-registrar-action@1.6.6
  with:
    config_path: .todo-registrar.yaml
    new_branch_name: todo-registrar
    user_name: 'My Bot'
    user_email: 'bot@example.com'
```

## Related documentation

- [Inputs](inputs.md) — input reference and branch templates
- [Permissions](permissions.md) — required workflow and repository settings
- [Using outputs](outputs.md) — react to `skipped` and `has_changes` in later steps
- [Configuration](configuration.md) — todo-registrar config file format

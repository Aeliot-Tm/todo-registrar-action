# Permissions

## Workflow permissions

First, configure workflow permissions:

```yaml
permissions:
  contents: write         # required: allows committing and pushing
  pull-requests: write    # required: allows creating pull requests
  issues: write           # optional: allows creating issues on GitHub
```

## Repository settings

Second, allow the action to create pull requests in the repository settings:

1. Go to your repository on GitHub
2. **Settings** → **Actions** → **General**
3. Scroll down to the **Workflow permissions** section
4. Check **Allow GitHub Actions to create and approve pull requests**
5. _Optional:_ select **Read and write permissions** to allow creating issues in the repository
6. Click **Save**

## Triggering workflows for issues

By default, the action uses the standard runner token (`secrets.GITHUB_TOKEN`). However, events created
with this token (such as issue creation) **will not trigger other GitHub Actions workflows**.
This is a [GitHub limitation](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication#using-the-github_token-in-a-workflow)
designed to prevent recursive workflow runs.

If you need issue-related workflows to be triggered automatically (e.g., labeling, notifications, project board automation),
you must use a separate personal access token (PAT) or a GitHub App token instead of the default one.

**Example with a separate token:**

```yaml
- uses: Aeliot-Tm/todo-registrar-action@2.0.0
  env:
    GITHUB_TOKEN: ${{ secrets.TODO_REGISTRAR_TOKEN }}
  with:
    config_path: .todo-registrar.yaml
    env_vars: GITHUB_TOKEN
    new_branch_name: todo-registrar
```

## Related documentation

- [Examples](examples.md) — full workflow snippets
- [Configuration](configuration.md) — passing tokens via `%env(GITHUB_TOKEN)%`

![logo.svg](docs/logo.svg)

# TODO Registrar Action

GitHub Action for finding TODO comments in code and automatically creating issues in your issue tracker.

This action is a wrapper around **[TODO registrar](https://github.com/Aeliot-Tm/todo-registrar)** Docker container.

## Features

- Scans your codebase for TODO/FIXME/etc comments.
- Automatically creates issues in supported issue trackers (GitHub, GitLab, JIRA).
- Injects issue IDs back into TODO comments to prevent duplicates.
- Supports inline configuration for flexible issue customization.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `config_path` | No* | | Path to configuration file (relative to workspace) |
| `config` | No* | | Inline YAML configuration |
| `verbosity` | No | `normal` | Verbosity level: `quiet`, `normal`, `verbose`, `very-verbose`, `debug` |
| `env_vars` | No | | Environment variable names to pass to container (newline or space separated) |

\* Either `config_path` or `config` must be provided.

## Usage

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

## Configuration

For detailed configuration options, see the [TODO registrar documentation](https://github.com/Aeliot-Tm/todo-registrar/blob/main/docs/config/global_config_yaml.md).

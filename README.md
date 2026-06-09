![logo.svg](docs/logo.svg)

[![GitHub Release](https://img.shields.io/github/v/release/Aeliot-Tm/todo-registrar-action?label=Release)](https://github.com/Aeliot-Tm/todo-registrar-action/releases)
[![Testing](https://github.com/Aeliot-Tm/todo-registrar-action/actions/workflows/automated-testing.yaml/badge.svg?branch=main)](https://github.com/Aeliot-Tm/todo-registrar-action/actions/workflows/automated-testing.yaml?query=branch%3Amain)
[![GitHub License](https://img.shields.io/github/license/Aeliot-Tm/todo-registrar-action?label=License)](LICENSE)

# TODO Registrar Action

GitHub Action for finding TODO comments in code and automatically creating issues in your issue tracker.

This action runs the Docker container from **[TODO registrar](https://github.com/Aeliot-Tm/todo-registrar)**.

### Features

- Scans your codebase for TODO/FIXME/etc comments.
- Automatically creates issues in supported issue trackers (GitHub, GitLab, JIRA).
- Injects issue IDs back into TODO comments to prevent duplicates.
- Supports inline configuration for flexible issue customization.

The action adds issue numbers to TODO comments in the code and commits the changes. This helps avoid
duplicate tickets without an external database — everything is stored in your repository.

![detect_register_inject.png](docs/detect_register_inject.png)

> See the latest **benchmark [here](https://github.com/Aeliot-Tm/todo-registrar-benchmark/blob/main/benchmark.md)**.

## Quick start

Create a workflow file at `.github/workflows/todo-registrar.yaml`:

```yaml
name: TODO registrar

on:
  push:
    branches: [ "main" ] # or "master" or "develop"

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  register:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Aeliot-Tm/todo-registrar-action@1.6.6
        with:
          new_branch_name: todo-registrar
```

Configure [workflow permissions](docs/permissions.md) in the repository settings before the first run.

## Documentation

1. [How it works](docs/how-it-works.md) — Workflow steps, skip logic, outcomes.
2. [Inputs](docs/inputs.md) — Input reference and branch templates.
3. [Using outputs](docs/outputs.md) — Conditional steps and job outputs.
4. [Examples](docs/examples.md) — Workflow YAML for common setups.
5. [Configuration](docs/configuration.md) — TODO Registrar config and loading.
6. [Permissions](docs/permissions.md) — Tokens, PAT, repository settings.
7. [Pull request report](docs/pull-request-report.md) — PR body and processing report.

## External documentation

- [TODO Registrar](https://github.com/Aeliot-Tm/todo-registrar) — scanner and issue tracker integration.
- [Benchmark results](https://github.com/Aeliot-Tm/todo-registrar-benchmark/blob/main/benchmark.md) — performance comparisons.

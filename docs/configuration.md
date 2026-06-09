# Configuration

The action passes configuration to [TODO Registrar](https://github.com/Aeliot-Tm/todo-registrar) in one of three ways:

| Method | Input | Description |
|--------|-------|-------------|
| Inline YAML | `config` | Passed to the container on stdin (recommended) |
| Config file | `config_path` | Path relative to the repository root (mounted at `/code`) |
| Default paths | _(none)_ | TODO Registrar searches standard locations such as `.todo-registrar.yaml` |

See [Examples](examples.md) for workflow snippets with inline config, config files, and environment variables.

## TODO Registrar documentation

- [Configuration options (YAML)](https://github.com/Aeliot-Tm/todo-registrar/blob/main/docs/config/general_config_yaml.md) — paths, registrar type, issue templates, and more
- [Configuration loading](https://github.com/Aeliot-Tm/todo-registrar/blob/main/docs/config/general_config.md) — default file paths and precedence

## Related documentation

- [Inputs](inputs.md) — `config`, `config_path`, and `env_vars`
- [Examples](examples.md) — `%env(VAR)%` syntax and secrets
- [Permissions](permissions.md) — tokens and workflow permissions

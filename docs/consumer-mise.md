# Consume with mise

The repository generates `mise/registry.toml`. Install it as a user-level config fragment:

```text
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/mise/conf.d"
cp mise/registry.toml "${XDG_CONFIG_HOME:-$HOME/.config}/mise/conf.d/50-custom-aqua-registry.toml"
```

After that, generated aliases are available without backend prefixes:

```text
mise use -g tool@latest
mise ls-remote tool
mise install tool@1.2.3
```

The fragment contains both the custom Aqua registry URL and `[tool_alias]` mappings.

For development against a local checkout, use a `mise.local.toml` override and a `file://` custom Aqua registry URL. Keep that local file uncommitted.

If registry changes are not visible immediately, remember that mise caches custom Aqua registry content according to `aqua.registry_cache_ttl`. Clearing the mise cache or temporarily using a development TTL of `0s` forces a refresh.

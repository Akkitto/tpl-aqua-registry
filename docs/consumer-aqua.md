# Consume with Aqua

Aqua supports custom GitHub registries through `github_content`. Pin a registry tag or commit:

```yaml
registries:
  - name: custom
    type: github_content
    repo_owner: your-owner
    repo_name: aqua-registry
    ref: v1.0.0
    path: registry.yaml

packages:
  - name: your-owner/tool@v1.2.3
    registry: custom
```

Do not use a branch name as `ref`; Aqua treats registry refs as immutable.

Aqua v2 policy restricts non-standard registries by default. Create and explicitly allow an Aqua policy appropriate for the packages and registry you trust before installing from a custom registry.

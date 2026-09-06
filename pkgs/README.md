# Packages

Package source definitions live at `pkgs/<owner>/<repository>/registry.yaml`.

The directory may initially contain no package definitions. `scripts/build.sh` treats that as a valid empty registry and generates `packages: []`.

Add a package with:

```text
mise run new-package -- OWNER/REPOSITORY
```

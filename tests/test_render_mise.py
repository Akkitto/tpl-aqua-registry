#!/usr/bin/env python3
"""Unit tests for deterministic mise fragment generation."""

from __future__ import annotations

import importlib.util
from pathlib import Path
import unittest


MODULE_PATH = Path(__file__).resolve().parents[1] / "scripts" / "render_mise.py"
SPEC = importlib.util.spec_from_file_location("render_mise", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
render_mise = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(render_mise)


class RenderMiseTests(unittest.TestCase):
  def base_config(self) -> dict:
    return {
      "repository": {
        "provider": "github",
        "owner": "example",
        "name": "registry",
        "public_url": "",
      },
      "mise": {
        "alias_strategy": "basename",
        "alias_overrides": {},
        "alias_excludes": [],
        "registry_cache_ttl": "1w",
      },
    }

  def test_derives_github_registry_url(self) -> None:
    self.assertEqual(
      render_mise.derive_registry_url(self.base_config()),
      "https://github.com/example/registry",
    )

  def test_generates_prefix_free_alias(self) -> None:
    registry = {"packages": [{"name": "owner/tool", "type": "github_release"}]}
    aliases = render_mise.build_aliases(self.base_config(), registry)
    self.assertEqual(aliases, {"tool": "aqua:owner/tool"})

  def test_override_wins(self) -> None:
    config = self.base_config()
    config["mise"]["alias_overrides"] = {"owner/long-name": "short"}
    registry = {
      "packages": [{"name": "owner/long-name", "type": "github_release"}]
    }
    aliases = render_mise.build_aliases(config, registry)
    self.assertEqual(aliases, {"short": "aqua:owner/long-name"})

  def test_excluded_package_has_no_alias(self) -> None:
    config = self.base_config()
    config["mise"]["alias_excludes"] = ["owner/internal"]
    registry = {
      "packages": [{"name": "owner/internal", "type": "github_release"}]
    }
    self.assertEqual(render_mise.build_aliases(config, registry), {})

  def test_alias_collision_fails(self) -> None:
    registry = {
      "packages": [
        {"name": "one/tool", "type": "github_release"},
        {"name": "two/tool", "type": "github_release"},
      ]
    }
    with self.assertRaisesRegex(ValueError, "alias collision"):
      render_mise.build_aliases(self.base_config(), registry)


if __name__ == "__main__":
  unittest.main()

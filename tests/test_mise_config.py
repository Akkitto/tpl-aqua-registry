import tomllib
import unittest
from pathlib import Path


class MiseConfigTests(unittest.TestCase):
  """Guard the registry template's bootstrap dependency boundary."""

  @classmethod
  def setUpClass(cls) -> None:
    repo_root = Path(__file__).resolve().parents[1]
    with (repo_root / "mise.toml").open("rb") as config_file:
      cls.config = tomllib.load(config_file)

  def test_has_no_global_tools(self) -> None:
    # Global tools would be resolved before every task, including configure.
    self.assertNotIn("tools", self.config)

  def test_aqua_cli_uses_github_backend(self) -> None:
    new_package_tools = self.config["tasks"]["new-package"]["tools"]
    self.assertIn("github:aquaproj/aqua", new_package_tools)
    self.assertNotIn("aqua:aquaproj/aqua", new_package_tools)

  def test_configure_only_needs_bootstrap_safe_tools(self) -> None:
    configure_tools = self.config["tasks"]["configure"]["tools"]
    self.assertEqual(
      {
        "python": "3.13",
        "github:mikefarah/yq": "latest",
      },
      configure_tools,
    )


if __name__ == "__main__":
  unittest.main()

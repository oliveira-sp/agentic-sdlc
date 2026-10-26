#!/usr/bin/env python3
"""Exercise the read-only payload viewers against temporary directories."""

from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().with_name("compare-payload.sh")


class ComparePayloadTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(
            prefix="compare-payload-test-", dir="/tmp/opencode"
        )
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.payload = self.root / "repo payload"
        self.dest = self.root / "installed config"
        self.payload.mkdir()
        self.dest.mkdir()

    def write(self, root, name, text):
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def run_viewer(self, mode):
        result = subprocess.run(
            ["bash", str(SCRIPT), mode, str(self.payload), str(self.dest)],
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        self.assertNotIn("\x1b[", result.stdout)
        return result.stdout

    def test_clean_ignores_destination_only_files(self):
        for root in (self.payload, self.dest):
            self.write(root, "same.txt", "same\n")
        self.write(self.dest, "machine-local.txt", "local\n")
        self.assertEqual(
            self.run_viewer("status"),
            "Nothing to install (installed files match repository payload).\n",
        )
        self.assertEqual(self.run_viewer("diff"), "")

    def test_status_groups_additions_and_modifications(self):
        self.write(self.payload, "nested/new file.txt", "new\n")
        self.write(self.payload, "changed.txt", "repo\n")
        self.write(self.dest, "changed.txt", "installed\n")
        output = self.run_viewer("status")
        self.assertIn("Changes to be installed:\n", output)
        self.assertIn(
            "\tnew file:   nested/new file.txt\n\tmodified:   changed.txt\n",
            output,
        )

    def test_diff_uses_installed_baseline_and_git_headers(self):
        self.write(self.payload, "changed.txt", "repo\n")
        self.write(self.dest, "changed.txt", "installed\n")
        output = self.run_viewer("diff")
        self.assertTrue(output.startswith(
            "diff --git a/changed.txt b/changed.txt\n"
            "--- a/changed.txt\n+++ b/changed.txt\n"
        ))
        self.assertIn("-installed\n+repo\n", output)
        self.assertEqual((self.dest / "changed.txt").read_text(), "installed\n")

    def test_new_file_uses_dev_null(self):
        self.write(self.payload, "new.txt", "new\n")
        output = self.run_viewer("diff")
        self.assertIn("new file mode 100644\n--- /dev/null\n+++ b/new.txt\n", output)
        self.assertIn("+new\n", output)
        self.assertFalse((self.dest / "new.txt").exists())

    def test_new_empty_file_is_reported(self):
        self.write(self.payload, "empty.txt", "")
        self.assertEqual(
            self.run_viewer("diff"),
            "diff --git a/empty.txt b/empty.txt\nnew file mode 100644\n",
        )

    def test_new_executable_mode(self):
        path = self.write(self.payload, "script.sh", "#!/bin/sh\n")
        path.chmod(0o755)
        self.assertIn("new file mode 100755\n", self.run_viewer("diff"))

    def test_missing_destination_is_all_new(self):
        self.dest = self.root / "not installed"
        self.write(self.payload, "new.txt", "new\n")
        self.assertIn("\tnew file:   new.txt\n", self.run_viewer("status"))
        self.assertIn("--- /dev/null\n", self.run_viewer("diff"))
        self.assertFalse(self.dest.exists())


if __name__ == "__main__":
    unittest.main()

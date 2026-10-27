#!/usr/bin/env python3
"""Exercise gcommit with mocked OpenCode and Git; never create real commits."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "config/bin/gcommit"
VALID = "fix(opencode): use instruct variant for commit message generation\n"
TOOL_CALL = '''<tool_call>
<function=command>
{"command": "true"}
</parameter>
</function>
</tool_call>
'''


class GcommitTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="gcommit-test-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        config = self.root / "config/opencode/skills/commit"
        (config / "scripts").mkdir(parents=True)
        (config / "commit-prompt.md").write_text("Write a Conventional Commit message.\n")
        (config / "scripts/commit-context.sh").write_text("echo '--- staged diff (full) ---'\n")
        self.mock("git", '''
import json, os, sys
from pathlib import Path
root = Path(os.environ["MOCK_ROOT"])
if sys.argv[1:] == ["diff", "--cached", "--quiet"]:
    sys.exit(int(os.environ.get("MOCK_DIFF_STATUS", "1")))
if sys.argv[1:] != ["commit", "--edit", "-F", "-"]:
    sys.exit("unexpected git invocation")
(root / "commit.json").write_text(json.dumps({"args": sys.argv[1:], "message": sys.stdin.read()}))
''')
        self.mock("opencode", '''
import json, os, sys
from pathlib import Path
root = Path(os.environ["MOCK_ROOT"])
if sys.argv[1] == "api":
    print(json.dumps({"data": {"model": {"providerID": "mock", "id": "model", "variant": "instruct"}}}))
    sys.exit(0)
if sys.argv[1] != "run":
    sys.exit("unexpected opencode invocation")
count_file = root / "count"
count = int(count_file.read_text()) if count_file.exists() else 0
responses = json.loads((root / "responses.json").read_text())
response = responses[min(count, len(responses) - 1)]
count_file.write_text(str(count + 1))
with (root / "runs.jsonl").open("a") as stream:
    stream.write(json.dumps(sys.argv[1:]) + "\\n")
sys.stdout.write(response.get("text", ""))
sys.stderr.write(response.get("stderr", ""))
sys.exit(response.get("status", 0))
''')
        self.env = {key: value for key, value in os.environ.items() if not key.startswith("GCOMMIT_")}
        self.env.update(
            PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
            XDG_CONFIG_HOME=str(self.root / "config"),
            MOCK_ROOT=str(self.root),
            GCOMMIT_MODEL="mock/model#instruct",
            GCOMMIT_RETRIES="3",
            GCOMMIT_RETRY_DELAY="0",
        )

    def mock(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env python3\n" + body)
        path.chmod(0o755)

    def run_script(self, responses, *args):
        responses = [
            {**response, "text": response["raw"] if "raw" in response else
             "<commit_message>\n" + response.get("text", "").rstrip("\n") +
             "\n</commit_message>\n"}
            for response in responses
        ]
        (self.root / "responses.json").write_text(json.dumps(responses))
        return subprocess.run(
            ["bash", str(SCRIPT), *args], env=self.env, cwd=self.root,
            capture_output=True, text=True, timeout=10,
        )

    def assert_committed(self, result, message=VALID, attempts=1):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads((self.root / "commit.json").read_text())["message"], message)
        self.assertEqual(int((self.root / "count").read_text()), attempts)

    def test_valid_subject(self):
        self.assert_committed(self.run_script([{"text": VALID}]))

    def test_analysis_and_drafts_outside_final_block(self):
        response = (
            "To create the commit message, I need to analyze the staged changes.\n"
            "**Draft:**\nfeat(ssh): add identity script and docs\n\n"
            "Let me verify the subject length.\n"
            "<commit_message>\n" + VALID + "</commit_message>\n"
            "This is the final message.\n"
        )
        self.assert_committed(self.run_script([{"raw": response}]))

    def test_invalid_envelopes_never_commit(self):
        block = "<commit_message>\n" + VALID + "</commit_message>\n"
        invalid = [
            VALID, "", block + block,
            "<commit_message>\n" + VALID,
            VALID + "</commit_message>\n",
            "</commit_message>\n<commit_message>\n" + VALID,
            "<commit_message>\n" + block + "</commit_message>\n",
            "<commit_message>" + VALID + "</commit_message>\n",
            " <commit_message>\n" + VALID + "</commit_message>\n",
            "<commit_message extra>\n" + VALID + "</commit_message>\n",
            "<commit_message>\n</commit_message>\n",
        ]
        for response in invalid:
            with self.subTest(response=response):
                result = self.run_script([{"raw": response}])
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((self.root / "commit.json").exists())
                self.assertIn("no valid commit message after 3 attempts", result.stderr)
                (self.root / "count").unlink()

    def test_retries_include_specific_feedback_and_snapshot(self):
        result = self.run_script([
            {"raw": VALID}, {"text": "fix: trailing period.\n"}, {"text": VALID},
        ])
        self.assert_committed(result, attempts=3)
        runs = [json.loads(line) for line in (self.root / "runs.jsonl").read_text().splitlines()]
        self.assertNotIn("## Correction for retry", runs[0][-1])
        self.assertIn("expected exactly one complete", runs[1][-1])
        self.assertIn("no trailing period", runs[2][-1])
        for run in runs:
            self.assertIn("--- staged diff (full) ---", run[-1])

    def test_valid_body(self):
        message = "feat(api)!: reject invalid requests\n\n- Validate input\n- Return an error\n"
        self.assert_committed(self.run_script([{"text": message}]), message)

    def test_envelope_preserves_plain_text_not_xml(self):
        message = "fix(api): validate input & output\n\n- Reject values < 0 and preserve `&amp;` literally\n"
        self.assert_committed(self.run_script([{"text": message}]), message)

    def test_message_can_describe_its_envelope(self):
        message = (
            "feat(gcommit): require <commit_message> envelope in model responses\n\n"
            "- Extract <commit_message> and </commit_message> delimiters\n"
            "- Reject malformed or duplicate blocks\n"
        )
        self.assert_committed(self.run_script([{"text": message}]), message)

    def test_custom_type_and_no_scope(self):
        message = "maintenance: refresh dependencies\n"
        self.assert_committed(self.run_script([{"text": message}]), message)

    def test_tool_call_then_valid(self):
        result = self.run_script([{"text": TOOL_CALL}, {"text": VALID}])
        self.assert_committed(result, attempts=2)
        self.assertIn("rejected", result.stderr)

    def test_empty_then_valid(self):
        result = self.run_script([{"text": " \n\t"}, {"text": VALID}])
        self.assert_committed(result, attempts=2)
        self.assertIn("empty response", result.stderr)

    def test_command_failure_then_valid(self):
        result = self.run_script([{"text": VALID, "status": 7}, {"text": VALID}])
        self.assert_committed(result, attempts=2)
        self.assertIn("status 7", result.stderr)

    def test_invalid_responses_never_commit(self):
        invalid = [
            TOOL_CALL,
            "Here is the message:\n" + VALID,
            "```text\n" + VALID + "```\n",
            VALID + "\n<think>Use this message</think>\n",
            VALID + "\n<function=command>true</function>\n",
            VALID + "\n<|im_start|>assistant\n",
            VALID + "\n<think>\n" + "reasoning\n" * 10000 + "</think>\n",
            "fix: " + "a" * 72 + "\n",
            "fix: trailing period.\n",
            "fix: trailing space \n",
            "fix: missing blank line\n- Body\n",
            "fix: embedded\x1b[0m escape\n",
        ]
        for message in invalid:
            with self.subTest(message=message):
                result = self.run_script([{"text": message}])
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((self.root / "commit.json").exists())
                self.assertIn("no valid commit message after 3 attempts", result.stderr)
                (self.root / "count").unlink()

    def test_all_command_failures(self):
        result = self.run_script([{"status": 1}])
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / "commit.json").exists())
        self.assertEqual((self.root / "count").read_text(), "3")

    def test_debug_preserves_diagnostics_and_rejected_output(self):
        result = self.run_script([
            {"text": TOOL_CALL, "stderr": "provider diagnostic\n"}, {"text": VALID},
        ], "--debug")
        self.assert_committed(result, attempts=2)
        self.assertIn("provider diagnostic", result.stderr)
        self.assertIn(TOOL_CALL.strip(), result.stderr)

    def test_normal_mode_hides_provider_stderr(self):
        result = self.run_script([{"text": VALID, "stderr": "provider diagnostic\n"}])
        self.assert_committed(result)
        self.assertNotIn("provider diagnostic", result.stderr)

    def test_no_staged_changes(self):
        self.env["MOCK_DIFF_STATUS"] = "0"
        result = self.run_script([{"text": VALID}])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("nothing staged", result.stderr)
        self.assertFalse((self.root / "count").exists())
        self.assertFalse((self.root / "commit.json").exists())

    def test_invalid_retry_count(self):
        self.env["GCOMMIT_RETRIES"] = "0"
        result = self.run_script([{"text": VALID}])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("positive integer", result.stderr)
        self.assertFalse((self.root / "count").exists())

    def test_agent_model_variant_resolution(self):
        del self.env["GCOMMIT_MODEL"]
        result = self.run_script([{"text": VALID}])
        self.assert_committed(result)
        args = json.loads((self.root / "runs.jsonl").read_text())
        self.assertEqual(args[args.index("--model") + 1], "mock/model#instruct")


if __name__ == "__main__":
    unittest.main()

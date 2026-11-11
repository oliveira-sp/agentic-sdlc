---
description: Generate a handoff and preload a fresh, idle OpenCode session
subagent: false
---

Generate a handoff from this conversation and prepare a fresh OpenCode V2
session with that context. Keep the new session idle until the user sends their
next instruction. Do not fork the conversation or launch another TUI or plugin.

Next-session focus (may be empty):
$ARGUMENTS

## Workflow

1. Load the `handoff` skill and follow its summarization, artifact-reference,
   suggested-skills, and redaction rules. Use the focus above when supplied;
   otherwise summarize the current task for continuation.
2. Before writing, check that `opencode` and `jq` are available. Reserve a unique
   handoff file outside the workspace with `mktemp`, using a short kebab-case
   topic slug. Prefer `/tmp/opencode` on Linux when it exists; otherwise use the
   OS temporary directory. Do not overwrite an existing handoff. Write the
   document to the reserved file and keep its restrictive permissions.
3. Create a new top-level session in the **current session's working directory**,
   titled `Handoff: <topic>`. Explicitly pass `location.directory`: the API's
   default is not necessarily the shell's current directory. Preserve the
   current agent and model/variant when their identifiers are available; do not
   silently switch from a planning agent to a build agent. If the current agent
   cannot write the handoff, stop and ask the user to switch agents. If a model
   identifier is unavailable, use the new session's default and report that.
4. Preload the document with a synthetic message and **`resume: false`**. This
   queues the context without running the model. Never send a user prompt, call
   `opencode run`, or trigger generation as part of this workflow.

   Run the API calls through the shell tool, not command-template shell blocks.
   Use `jq` to construct JSON safely; never interpolate the focus or document
   directly into shell code or hand-built JSON. For example, in Bash, after
   setting `handoff_path`, `handoff_title`, and `handoff_agent` to the actual
   reserved path, title, and current agent:

   ```bash
   set -euo pipefail
   test -s "$handoff_path"
   create_body=$(jq -n \
     --arg title "$handoff_title" \
     --arg directory "$(pwd -P)" \
     --arg agent "$handoff_agent" \
     '{title: $title, location: {directory: $directory}, agent: $agent}')
   # Add the known current model reference to create_body when available.
   created=$(opencode api post /api/session --data "$create_body")
   session_id=$(jq -er '.data.id | select(type == "string" and startswith("ses_"))' <<< "$created")
   printf 'Created continuation session: %s\n' "$session_id"
   preload_body=$(jq -n --rawfile text "$handoff_path" \
     '{text: ("Handoff context for the next user instruction:\n\n" + $text),
       description: "Handoff context", resume: false}')
   admitted=$(opencode api post "/api/session/$session_id/synthetic" --data "$preload_body")
   jq -e '.data.type == "synthetic"' <<< "$admitted" >/dev/null
   inbox=$(opencode api get "/api/session/$session_id/inbox")
   jq -e --argjson expected "$preload_body" \
     'any(.data[]; .type == "synthetic" and .payload.text == $expected.text)' \
     <<< "$inbox" >/dev/null
   ```

   Use the same server/authentication context as the current TUI. If it uses an
   explicit server rather than the shared local service, pass that known server
   to every API call; if it cannot be determined, stop rather than creating the
   session on another server.
5. On an API or verification failure, report the error, the saved document path,
   and any session ID already created. Do not claim the context is ready, create
   another session automatically, or delete the document or session. Retrying
   preloading should reuse the existing session rather than create a duplicate.
6. On success, report the document path, session title, and ID. Tell the user to
   run `/sessions` and select that title to open it in the TUI, then send their
   next instruction. If the user's configured shortcut for the session/recent
   menu is known, mention it too; do not assume a machine-specific keybinding.

Leave the original session, workspace files, configuration, and Git state alone.
The existing `handoff` skill itself remains document-only.

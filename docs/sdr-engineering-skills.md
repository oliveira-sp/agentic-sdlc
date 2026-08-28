# SDR: Porting mattpocock/skills to opencode

**Status:** Design agreed, NOT yet implemented. No files created yet.
**Date:** 2026-08-28
**Owner:** saaspasse

## 1. Context

We want to adopt Matt Pocock's engineering skills (`github.com/mattpocock/skills`) into our
local **opencode** setup (`~/.config/opencode/`). The upstream skills are written for
Claude Code / Codex: they assume `/slash` invocation and an issue-tracker world (GitHub /
Linear / local). opencode has no `/slash` native concept and no `type` field distinguishing
user- vs model-invoked skills. We are porting a **minimal, tracker-wired** subset, adapted to
opencode's primitives.

We already have locally: `skills/grill-me`, `skills/grilling`, `skills/handoff` (ported
Productivity skills) and a custom `chezmoi` skill + `command/chezmoi/*` + `agent/chezmoi/*`.
We also have a GitLab MCP (`glab mcp serve`) wired in `opencode.jsonc`.

## 2. Resolved decisions

| # | Decision | Choice |
|---|----------|--------|
| Q2 | Porting strategy | **Adapt** to opencode — rewrite `/slash` refs, fit command/agent format |
| Q1 | Scope | Minimal core + tracker wiring |
| Q3 | Tracker backend | **GitLab** via `glab` (already a first-class upstream backend) |
| Q6 | Branding | Dropped; setup skill named **`setup-engineering`** |
| Q5 | Representation | User-triggered flows → **commands**; model discipline → **skills** |
| Q8 | Directory naming | **Plural**: `skills/`, `commands/`, `agents/` (migrate chezmoi too) |
| Q9 | tdd / code-review invocation | **Both** user-invokable (`/tdd`, `/code-review`) and model-invokable |
| Q10 | code-review sub-agents | Built-in **subagent tool** using `general`/`explore`; no new agent files |
| Q11 | Tracker config location | **Per-project root**: `docs/agents/issue-tracker.md` + `AGENTS.md` |

## 3. Design tree

```
Port mattpocock skills to opencode
├── Strategy: adapt (Q2)
├── Scope (Q1)
│   ├── Disciplines (skills, model+user invokable — Q5/Q9)
│   │   ├── tdd
│   │   └── code-review  (parallel Standards+Spec sub-agents — Q10)
│   └── Tracker-wired flows (commands, user-invoked — Q5)
│       ├── setup-engineering   (renamed, branding dropped — Q6)
│       ├── to-spec
│       └── to-tickets
├── Tracker backend: GitLab / glab (Q3)
│   └── Abstraction = docs/agents/issue-tracker.md (per-project — Q11)
└── Layout: plural dirs, migrate chezmoi (Q8)
```

### Skill-vs-command rule (our convention)
- **Skill** = description-driven guidance the model can reach for. `tdd`, `code-review`.
- **Command** (`commands/*.md`) = user-triggered `/name` action. `setup-engineering`,
  `to-spec`, `to-tickets`.
- This matches the existing chezmoi split (`chezmoi` skill + `command/chezmoi/*`).

## 4. Build plan

### 4.1 Directory migration (Q8)
Rename so everything is plural; merge with what already exists:
- `skill/` → `skills/` (includes `chezmoi`, `grill-me`, `grilling`, `handoff`)
- `command/` → `commands/` (merge into existing `commands/` which has `commit.md`,
  `project-discover.md`; chezmoi's `add/audit/stage` move under `commands/chezmoi/`)
- `agent/` → `agents/` (chezmoi's `commit-prep`, `discover`)

### 4.2 Skills to create
- `skills/tdd/SKILL.md` — adapt upstream `tdd`; strip `/slash` references; normal skill
  (user + model invokable). Red-green-refactor loop.
- `skills/code-review/SKILL.md` — adapt upstream `code-review`; "run Standards and Spec
  reviews as **parallel sub-agents via the subagent tool**" (no dedicated agent files).
  Two-axis: Standards (repo coding standards + Fowler smell baseline) and Spec (faithful to
  originating issue/spec).

### 4.3 Commands to create
- `commands/setup-engineering.md` — adapt `setup-matt-pocock-skills`. Offers
  GitHub / GitLab / Local / Other, **defaults to GitLab**. Writes
  `docs/agents/issue-tracker.md` (seeded from upstream `issue-tracker-gitlab.md` template using
  `glab`) and edits `AGENTS.md` (never creates `CLAUDE.md`). Uses `$ARGUMENTS` for any input.
- `commands/to-spec.md` — adapt `to-spec`. Synthesizes a spec from the conversation (no
  interview) and publishes via `glab issue create --label ready-for-agent`, reading the tracker
  doc for exact commands.
- `commands/to-tickets.md` — adapt `to-tickets`. Breaks plan/spec into tracer-bullet tickets
  with blocking edges; publishes in dependency order; blocking via
  `glab issue link --link-type blocks <issue> <blocking-issue>`. Applies `ready-for-agent`.

### 4.4 Source material to fetch (faithful port)
- upstream `skills/engineering/{tdd,code-review,setup-matt-pocock-skills,to-spec,to-tickets}/SKILL.md`
- upstream `setup-matt-pocock-skills` template `issue-tracker-gitlab.md` (the GitLab command set)

## 5. Upstream quirks to translate
- `disable-model-invocation: true` (Anthropic field) → **omit** for `tdd`/`code-review`
  (we want both user + model invocation); not needed for commands.
- `/slash-name` references between skills → "call the `<name>` skill" / `/<name>` command.
- `argument-hint` (Anthropic) → opencode `$ARGUMENTS` / `$1`.
- `to-spec`/`to-tickets` are **prompt-driven**, not scripted — only example names + the
  blocking description need to mention `glab`; no hardcoded `gh` calls to replace.

## 6. Open risks
- **Plural-dir loading**: current opencode version loads *singular* dirs (proven by chezmoi).
  Plural is docs-canonical but version-dependent. After migration, verify skills/commands/agents
  load; fall back to singular if not.
- **Optional cleanup (out of scope)**: `handoff` uses Anthropic `argument-hint` (ignored by
  opencode) → could switch to `$ARGUMENTS`.

## 7. Out of scope (deferred)
`triage`, `implement`, `wayfinder`, `grill-with-docs`, `ask-matt`, and the rest of Productivity
(`teach`, `to-questionnaire`, `wait-what`, `writing-for-agents`). `triage-labels.md` only
generated if `triage` is later added.

# Agentic SDLC Framework Architecture

## Overview

The Agentic SDLC Framework provides a structured way to integrate specialized AI agents into the software development lifecycle. Rather than treating AI as an unstructured conversational assistant, the framework orchestrates agents through explicit workflows, durable engineering artifacts, and human approval checkpoints.

The framework is built on four foundational concepts:

- **Agents** — autonomous units with a focused responsibility that consume inputs and produce outputs.
- **Workflows** — orchestrators that sequence agent activities and advance process state.
- **Artifacts** — persistent, human-readable engineering documents exchanged between phases.
- **Executions** — bounded runs of a workflow that capture context, state, artifacts, and logs.

Together, these concepts enable reproducible, auditable, and human-controlled AI-assisted development.

## Agents

An agent is a self-contained unit of work with a specific responsibility. Each agent:

- Has a narrowly defined responsibility aligned to one phase of the development lifecycle.
- Consumes inputs from the workflow context and previously generated artifacts.
- Produces artifacts as its output.
- Does **not** control workflow state or decide when a step should advance.

Agents are interchangeable implementations of a responsibility. The framework does not mandate a specific agent implementation; it only requires that an agent honors its input contract and produces outputs in the expected artifact format.

Initial agent responsibilities include:

| Agent | Responsibility |
|---|---|
| Product Manager Agent | Transforms ideas into structured feature definitions. |
| Requirements Agent | Refines a feature definition into a detailed GitLab issue. |
| Architecture Agent | Produces an architecture plan for a given issue. |
| Implementation Planner Agent | Translates architecture and issue context into an implementation plan. |
| Coding Agent | Executes code changes per an implementation plan. |
| Review Agent | Reviews changes, runs validations, and prepares merge request content. |

## Workflows

A workflow is an orchestrator of agent activities. It defines which agents run, in what order, and under what conditions. Workflows own the lifecycle of process state — deciding when a step is complete, when to pause for human input, and when to transition to the next phase.

Agents do not control workflow state; they only fulfill their responsibility within the context provided by the active workflow.

### Initial Workflows

**Product Workflow**

Transforms a raw idea into a structured feature definition and a GitLab issue.

```
Idea → Feature Definition → GitLab Issue
```

**Engineering Workflow**

Transforms a GitLab issue into an implementation-ready plan.

```
GitLab Issue → Issue Brief → Repository Context → Implementation Plan
```

**Implementation Workflow**

Executes development against an implementation plan, with validation gates.

```
Implementation Plan → Code Changes → Validation → Merge Request
```

**Review Workflow**

Validates changes and prepares merge request content for human review.

```
Code Review → Verification → Merge Request Preparation
```

## Artifacts

An artifact is a persistent, human-readable engineering document produced as the output of an agent or a human review. Artifacts are the durable exchange format between workflow phases.

Initial artifact types include:

- `product-definition.md` — structured feature definition from the Product Workflow.
- `issue-brief.md` — distilled engineering brief derived from a GitLab issue.
- `architecture-plan.md` — architectural approach and constraints for a feature.
- `implementation-plan.md` — step-by-step plan for implementing a feature.
- `review-report.md` — review findings and merge request readiness assessment.

Key invariants for artifacts:

- Agents generate artifacts.
- Workflows manage the artifact lifecycle, including creation, handoff, and archival.
- Human validation of important artifacts is a required gate before certain transitions.

Artifacts are stored within the execution directory (see Executions) and may also be referenced by upstream systems such as GitLab issues.

## Executions

A workflow execution is a bounded run of a single workflow instance. Each execution captures everything needed to reproduce, audit, or resume the work performed.

Every execution contains:

- **Context** — the inputs supplied to the workflow (for example, a feature idea, an issue IID, or a repository ref).
- **Workflow state** — the current phase, gate status, and progress of the execution.
- **Generated artifacts** — the artifacts produced during the execution.
- **Logs** — an audit trail of agent invocations, decisions, and human interactions.

An example execution directory structure:

```
executions/
└── product/
    └── exec_20240115_143201/
        ├── context.json
        ├── state.json
        ├── artifacts/
        │   ├── product-definition.md
        │   └── issue-brief.md
        └── logs/
            ├── product-manager-agent.log
            └── requirements-agent.log
```

Executions are treated as immutable records once the workflow completes. Interrupted executions may be resumed from their persisted state.

## Human Control

The framework preserves human control over important decisions through approval checkpoints. Humans validate:

- Requirements — feature definitions and issue briefs before engineering work begins.
- Architecture decisions — architecture plans before implementation planning.
- Implementation strategy — implementation plans before code changes begin.
- Final changes — review reports and merge request content before submission.

The framework must not automatically perform any of the following:

- Merge code into protected branches.
- Close GitLab issues.
- Modify requirements or issue descriptions.

These actions remain under explicit human control. The framework may prepare merge requests and draft content, but submission and approval of those requests is a human decision.

## Architectural Decisions

The following decisions shape the framework's design:

1. **Separation of concerns.** Agents produce artifacts; workflows own state. This keeps agent logic simple and makes workflow transitions explicit.
2. **Artifacts as the contract.** All inter-phase communication occurs through persisted artifacts, making the process auditable and resumable.
3. **Human-in-the-loop by default.** Important transitions pause for human validation. No code is merged or issues closed without explicit approval.
4. **Execution isolation.** Each workflow run is scoped to a single execution directory, preserving a complete audit trail.
5. **Agent interchangeability.** Agents are bound to responsibilities, not specific implementations, allowing different LLM or tool configurations to fulfill the same role.

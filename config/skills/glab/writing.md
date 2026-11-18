# Writing for GitLab

Write like a competent teammate, not a generated report. Make the contribution
easy for people to understand, act on, and revisit; keep it precise enough for
an AI agent to use without guessing.

## Audience and context

Readers may include software engineers, electrical and schematic engineers,
reviewers, product owners, product managers, and project managers. Adapt to the
purpose and immediate readers without assuming everyone shares one specialty.

- Lead with the point, impact, or decision in language a cross-functional
  teammate can understand. Follow with the technical detail needed to act or
  review. A short reply does not need a separate summary.
- Keep precise technical terms and the project's domain vocabulary. Explain
  unfamiliar terms when they matter; do not dilute technical detail or expand
  every acronym mechanically.
- Read the relevant description and discussion before writing. Consult linked
  requirements, project context, or code when needed to support the contribution.
- Distinguish observed facts, hypotheses, proposals, and agreed decisions. Never
  invent requirements, test results, commitments, owners, or deadlines.
- Ask for missing information when it changes the meaning or requested action,
  unless the workflow explicitly requires drafting without further questions.
  In that case, identify the unresolved gap. Otherwise, write what is known and
  flag uncertainty only where it matters. Follow workflow-specific gap markers.

## Voice and readability

- Start with useful information, not an introduction to what you are about to
  say. Cut generic filler, repeated context, and ceremonial conclusions.
- Use direct, natural, respectful language and short paragraphs. Prefer concrete
  statements to vague claims such as "improve robustness" or "enhance usability."
- Use headings, lists, and tables only when they help readers navigate or
  compare information. Do not turn a short reply into a report.
- Keep the reasoning and context needed to understand the point. Concise does
  not mean omitting evidence, technical constraints, or important tradeoffs.
- State the ask or next step when one is needed. Do not manufacture an action
  item for an informational reply or repeat what the thread already settled.
- Use links and GitLab references to make supporting material easy to find.
  Keep the essential point in the text rather than forcing readers to follow
  every link. Use code formatting for identifiers, commands, and exact values.

## Match the contribution

These are content prompts, not mandatory headings or a universal template.
Preserve project templates and specialized workflow requirements; avoid
boilerplate in optional sections and follow required missing-information rules.

- **Issues and work items:** explain the problem, why it matters, and what a
  successful outcome looks like. Include constraints and acceptance criteria
  when useful and supported by the requirements. Titles should name the
  specific problem or capability, not a generic "improvement."
- **Epics:** explain the broader outcome, scope, and how the work fits together.
  Link to child work rather than duplicating every ticket's details.
- **MR descriptions:** explain what changed and why. Highlight what reviewers
  should pay attention to, relevant testing and its limits, and known risks.
  Do not present planned or unverified testing as completed.
- **Comments and notes:** respond directly to the point in the thread. Add
  reasoning or a clear question when needed; a few sentences are often enough.
  Avoid repeating the whole description or discussion.
- **Review notes:** distinguish a blocking problem, a non-blocking suggestion,
  and a genuine question. State known impact and supporting evidence. Do not
  hide a blocker behind a tentative question or turn an uncertain concern into
  a proven defect. Use explicit labels if the project requires them or the
  distinction would otherwise be unclear.

## Editing existing text

Make the smallest rewrite that solves the readability problem. Preserve the
author's meaning, language, technical details, uncertainty, links, checklists,
and project conventions. Reorganize when it materially helps, but do not
silently change scope, strengthen claims, turn proposals into decisions, or
rewrite unrelated sections. A request for a full rewrite allows broader
changes to presentation, not invention or changes to agreed meaning.

## Examples

These are hypothetical rewrites. The after versions use only the information
in the before versions; adapt the style, not the example's facts.

### Issue description

**Before:**
> In order to improve the user experience, it would be beneficial to enhance
> the error handling associated with CSV imports. Currently, when a file has
> no header row, the import fails with "Unknown error." The desired behavior
> is to tell the user that the header row is missing.

**After:**
> CSV imports without a header row fail with "Unknown error," leaving users
> without an explanation. Show an error that identifies the missing header row.

### MR description

**Before:**
> This merge request introduces an enhancement to the CSV import validation
> mechanism by checking for a missing header row before parsing. It now shows
> "Header row missing." A unit test covering this case passes locally. The
> browser flow has not been tested.

**After:**
> Check for a missing CSV header row before parsing and show "Header row missing."
>
> The unit test for this case passes locally. The browser flow is untested.

### Review question

**Before:**
> **Observation:** I cannot find a timeout in the controller startup path and
> am unsure whether one is handled elsewhere.
> **Recommendation:** It would be beneficial to consider whether the absence
> of a controller response could result in an indefinite startup wait.

**After:**
> What happens if the controller doesn't respond? I don't see a timeout handled
> here. Could this leave startup waiting indefinitely, or is it handled elsewhere?

### Discussion reply

**Before:**
> Thank you for raising this important point. To provide clarification regarding
> the scope of this particular change, it is important to note that it only
> affects CSV imports. The JSON import path remains unchanged.

**After:**
> This change only affects CSV imports. JSON imports are unchanged.

## Before handing off the text

Check that the main point is easy to find, the detail fits the readers and the
task, and any ask is clear. Remove repetition and empty structure. Verify that
claims are supported, uncertainty is preserved, and no rewrite changed the
meaning. Apply the existing workflow's publishing and approval rules.

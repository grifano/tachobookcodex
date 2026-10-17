# TachoBook — Agent Instructions

## Project

TachoBook is a native iOS app built with Swift and SwiftUI.

The Figma design is the visual source of truth for UI implementation.

## Figma — Development Screens

Approved UI Design:
https://www.figma.com/design/rpZZnwAC53fG7zjQy42Snq/TachoBook--UI-Design

Development Screens:
https://www.figma.com/design/rpZZnwAC53fG7zjQy42Snq/TachoBook--UI-Design?node-id=284-5819

When implementing UI:

1. Navigate to the Development Screens page.
2. Locate the relevant approved screen or component.
3. Read its design context using Figma MCP.
4. Retrieve the reference screenshot.
5. Implement the design in native SwiftUI.
6. Compare the implementation against Figma.

Do not assume the default Cover page contains
the approved implementation designs.

Use direct frame/node links from the assigned
Notion Task whenever available.

Use the local `figma-desktop` MCP server whenever implementation depends on Figma.

## Shared instructions and task ownership

This repository-root `AGENTS.md` is the shared source of development rules for Codex and Claude Code. Keep it versioned with the code. `CLAUDE.md` imports it; do not maintain a second copy of these rules outside the repository.

- Notion is the source of truth for approved product specifications, task scope, and acceptance criteria. Read the assigned task and linked approved specification before implementation.
- Figma is the visual source of truth when a task affects UI.
- Serhii makes final product decisions and approves merging work.
- Work only on the assigned task. If a task contains an explicit restriction such as "do not commit or push", honor it and resolve the conflict with Serhii before publishing; this default workflow does not silently cancel task-specific restrictions.

## Branches and parallel work

1. Confirm the repository, current branch, and working-tree status before editing. Preserve existing uncommitted work.
2. Use a separate clone or Git worktree for each concurrently running executor. Never let two agents edit the same working directory.
3. Fetch the latest remote state and create a new task branch from `origin/main`, unless the task specifies another base. Record the base commit SHA.
4. Name branches `codex/<task-id-or-short-name>` or `claude/<task-id-or-short-name>`. One task per branch; resume an existing task on its existing branch.
5. Never implement directly on `main`, push directly to `main`, force-push, or overwrite another executor's branch without explicit authorization.
6. Commit only task-related files after reviewing the diff. Do not commit credentials, build output, or local IDE state.

When Codex and Claude Code are explicitly assigned the same task for comparison, use the same approved specification, acceptance criteria, and exact base commit SHA in two separate branches and working directories. Do not copy or merge the competing implementation. Open one PR per implementation; Serhii selects which result to accept.

## Task status and review handoff

- `Next`: the task is ready to be started.
- `Doing`: the assigned executor has started work.
- `Review`: implementation is ready for human review, with a PR and verification evidence.
- `Done`: Serhii has approved the result, the selected PR has been merged, and applicable post-merge checks have passed.

For an assigned implementation task, commit and push the task branch and open a pull request targeting `main` after relevant verification, unless the task explicitly restricts publishing. Opening a PR does not authorize merging it.

Include in the PR:

- The task link, executor, and base commit SHA.
- What changed and why.
- Acceptance criteria checked, exact verification commands and results.
- Any checks not run, blockers, or known limitations.
- How Serhii can verify the result; include screenshots for visible UI changes.

Update only the assigned Notion task when task-tracking access is available and authorized. Add the branch and PR links and a short verification summary. Never claim a status update succeeded without checking it. If access is unavailable, report the intended transition for Serhii to apply; do not create duplicate tasks or change database properties.

If verification is blocked, report the blocker and keep the task in `Doing`; a draft PR may be used to share progress. Do not present unverified work as ready for review. If changes are requested, return to `Doing` and update the same branch and PR.

Stop at `Review` until Serhii approves merging. Merge only when he explicitly authorizes the executor to do so, or let him merge it himself. After merge, verify the resulting `main` using applicable checks before marking the selected task `Done`. For comparison runs, close the unselected PR without merging and record that it was not selected; do not report that implementation as delivered.

## Core workflow

For new screens, flows, or meaningful feature work:

1. For UI changes, inspect the relevant Figma node using Figma MCP. For logic-only or documentation tasks, use the approved specification; Figma inspection is not required.
2. Inspect the existing project structure and reusable components.
3. Create a short implementation plan before coding.
4. Implement UI using native SwiftUI and keep business logic independently testable.
5. Add or update tests for meaningful logic.
6. Build and run relevant tests.
7. For UI changes, compare the implementation against the Figma screenshot/context.
8. Fix visual or behavioral mismatches before declaring the task complete.

For small isolated fixes, keep the process proportional and avoid unnecessary planning overhead.

## Skills

Use relevant installed skills when applicable:

- `figma` and `figma-implement-design` for Figma-to-code work.
- `swiftui-pro` for SwiftUI implementation and review.
- `swift-testing-pro` for Swift Testing.
- `swiftdata-pro` when persistence using SwiftData is actually required.
- `test-driven-development` for logic-heavy or behavior-driven implementation.
- `systematic-debugging` when diagnosing defects.
- `code-review` for final review of significant changes.
- `security-best-practices` when handling sensitive data, permissions, storage, networking, or security-sensitive code.
- `verification-before-completion` before claiming meaningful work is complete.
- `writing-plans` for substantial tasks.
- `brainstorming` only when requirements or product behavior are unclear.

Do not invoke skills mechanically when they do not add value.

## Figma rules

- Do not redesign approved UI unless explicitly asked.
- Do not invent spacing, typography, colors, icons, states, or behavior when Figma contains the answer.
- Use design context and screenshots rather than relying only on visual guessing.
- Reuse existing project components where they can accurately represent the design.
- Do not modify the Figma file unless explicitly requested.
- Read-only Figma MCP operations are allowed for implementation and verification.
- Treat dates, times, names, counts, and other values shown in Figma as sample design content unless requirements explicitly define them as fixed data.
- Runtime values should come from the app state or current system data, not be copied from the Figma mockup.

## Adaptive layout

Figma frame dimensions represent the reference viewport, not fixed runtime dimensions.

- Never hardcode the source device width (for example 402 pt) into production SwiftUI layout.
- Translate Figma container widths into layout relationships.
- Example: a 370 pt container inside a 402 pt screen means 16 pt horizontal margins, not `.frame(width: 370)`.
- Full-width cards, sheets, buttons, and navigation containers must adapt using available width and semantic padding.
- Respect safe areas.
- Fixed dimensions are appropriate only for intrinsically fixed elements such as icons, controls, and specific visual indicators.
- Verify layouts at multiple iPhone widths before completion.

## Swift / SwiftUI

- Prefer native SwiftUI and current Apple APIs.
- Keep views small and composable.
- Keep business logic out of large view bodies.
- Avoid unnecessary abstractions and architecture layers.
- Do not add third-party dependencies unless they are clearly necessary and approved.
- Preserve the project's existing deployment target and Swift settings unless explicitly asked to change them.
- Follow accessibility best practices, including Dynamic Type and VoiceOver where applicable.
- Prefer the native SwiftUI system font for Apple system typography. Do not recreate SF Pro using custom font files unless the design explicitly requires a non-system typeface.
- When Figma shows glass/material effects, use the appropriate native SwiftUI material or Liquid Glass API supported by the project's deployment target, with a compatibility fallback when necessary.

## State and data

- Use the simplest state model that correctly represents the feature.
- Do not introduce SwiftData until persistence is required.
- Keep derived values derived instead of duplicating stored state where practical.

## Testing

- Use Swift Testing for unit and logic tests.
- Use XCTest for UI tests.
- Test meaningful behavior and calculations rather than implementation details.
- Before finishing a substantial code task, run the relevant build and tests on a Mac with a compatible Xcode and simulator. Inspect available schemes and destinations rather than inventing them.
- Record actual commands and results. If the environment cannot run iOS checks, report them as not run; never infer a passing build from code inspection.
- For documentation-only changes, review the diff, links, instruction consistency, and imports; an app build is not required.

## Change discipline

- Do not modify unrelated files.
- Do not perform broad refactors while implementing a focused feature unless required.
- Do not silently change product behavior.
- If Figma, requirements, and existing code conflict, stop and explain the conflict before choosing one.
- Prefer the smallest implementation that satisfies the approved behavior and design.

## Completion criteria

Do not state that a meaningful feature is complete until:

- the project builds,
- relevant tests pass,
- the intended flow works,
- UI changes have been checked against Figma,
- and no known in-scope issue remains unresolved.

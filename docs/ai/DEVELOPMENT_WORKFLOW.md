# Orange Development Workflow

## Golden Rule

One task, one module, one test, one commit.

## How To Use `prompts.md`

1. Start with P01.
2. Give only one prompt to the coding agent.
3. Include `CLAUDE.md` and the workspace docs as context.
4. After the agent finishes, run the manual test steps in that prompt.
5. Run `ACCEPTANCE_CHECKLIST.md`.
6. Commit using the prompt's suggested commit message.
7. Move to the next prompt.

Do not skip prompts unless you intentionally mark them as not applicable and understand all dependencies.

## Before Each Prompt

- Confirm the project opens.
- Confirm the previous prompt's acceptance criteria still pass.
- Commit or stash unfinished work.
- Tell the coding agent exactly which Prompt ID it is implementing.

## After Each Prompt

Ask the coding agent to provide:

- files changed,
- what it implemented,
- what it intentionally did not implement,
- manual test results,
- known risks.

Then test it yourself.

## Git Rule

Use the commit message from the prompt.

If you make fixes after a prompt, use a separate fix commit.

## When To Use Opus Review

Use `testprompt.md` with Opus after:

- a cluster of 5 prompts,
- all core systems P01-P20,
- all prototype prompts P01-P30,
- or anytime architecture feels unstable.

## When A Smaller Agent Wants To Redesign

Reject the redesign. Tell it:

"Follow `prompts.md`, `PROMPTS_CLARIFICATIONS.md`, and the current Prompt ID. Do not introduce new architecture."

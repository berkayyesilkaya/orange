# Orange Workspace Documentation Pack v2

Place these files in the root of the Godot repository, next to `prompts.md` and `testprompt.md`, or in `docs/ai/`.

Recommended root-level files:

- `CLAUDE.md`
- `prompts.md`
- `testprompt.md`

Recommended `docs/ai/` files:

- `PROJECT_BRIEF.md`
- `TECHNICAL_RULES.md`
- `ARCHITECTURE.md`
- `PROMPTS_CLARIFICATIONS.md`
- `DEVELOPMENT_WORKFLOW.md`
- `PROMPT_TEMPLATE.md`
- `ACCEPTANCE_CHECKLIST.md`
- `TESTPROMPT.md`

## Recommended Use

When giving a coding agent one prompt from `prompts.md`, include:

1. `CLAUDE.md`
2. `PROMPTS_CLARIFICATIONS.md`
3. the exact prompt block from `prompts.md`
4. any current error logs or relevant files

## Why v2 Exists

Opus produced a strong canonical `prompts.md` and `testprompt.md`. This v2 pack updates the earlier workspace docs so they align with Opus's architecture and adds clarifications for a few small ambiguities.

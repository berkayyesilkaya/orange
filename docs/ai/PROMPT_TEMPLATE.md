# Orange Implementation Prompt Template

Use this when you run a single implementation prompt with a smaller coding agent.

```text
You are implementing one module for Orange, a Godot 4.x GDScript 2D isometric cozy puzzle adventure.

Before coding, read and follow:
- CLAUDE.md
- prompts.md sections 1-7
- PROMPTS_CLARIFICATIONS.md
- PROJECT_BRIEF.md
- TECHNICAL_RULES.md
- ARCHITECTURE.md
- DEVELOPMENT_WORKFLOW.md
- ACCEPTANCE_CHECKLIST.md

You are implementing only this prompt:
[PASTE EXACT PROMPT ID BLOCK FROM prompts.md]

Important rules:
- Do not redesign architecture.
- Do not edit unrelated files.
- Do not add new autoloads, signals, folders, or systems unless this prompt explicitly requires it.
- Use GDScript only.
- Keep the implementation compatible with responsive web and touch/mouse input.
- Preserve all previous module behavior.

Before writing code, briefly list:
1. Files you will edit.
2. Files you will not edit.
3. How you will test the module.

After coding, report:
1. Files changed.
2. What was implemented.
3. Manual test steps performed.
4. Any risks or assumptions.
5. Suggested Git commit message from the prompt.
```

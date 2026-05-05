# Orange AI Coding Agent Instructions

You are working on **Orange**, a solo-developed **Godot 4.x / GDScript** cozy isometric pixel-art puzzle adventure.

Your job is not to redesign the project. Your job is to implement the exact requested module while preserving the shared architecture, naming, style, and project constraints.

## Read Order Before Coding

Read these files before making changes:

1. `prompts.md` (repo root)
2. `docs/ai/PROMPTS_CLARIFICATIONS.md`
3. `docs/ai/PROJECT_BRIEF.md`
4. `docs/ai/TECHNICAL_RULES.md`
5. `docs/ai/ARCHITECTURE.md`
6. `docs/ai/DEVELOPMENT_WORKFLOW.md`
7. `docs/ai/ACCEPTANCE_CHECKLIST.md`
8. The specific prompt ID you were given

`prompts.md` is the canonical implementation plan. The workspace docs in `docs/ai/` exist to make each prompt easier and safer to execute. The QA review prompt lives at `docs/ai/testprompt.md`.

## Non-Negotiable Decisions

- Engine: Godot 4.x.
- Language: GDScript only.
- First target: responsive web.
- Orientation: landscape first.
- Camera: 2D isometric.
- Character: chibi isometric Orange.
- Movement: free tap/click movement.
- Interaction: contextual one-button action.
- UI: minimal cozy UI with pixel notebook flavor.
- Hint system: one-level gentle hint only.
- Dialogue: Orange speaks a cute fictional language; English meaning appears in a small bottom text box.
- Object text: floating minimal labels near objects.
- Puzzle system: reusable base plus custom puzzle logic.
- Fragment collection: manual collection after puzzle solve.
- Key items: very small fixed key item system only.
- Save: after every meaningful reward, especially fragment collection and key item completion.
- Prototype scope: Episode 1 plus Episode 2 sunlight bridge only.

## Forbidden Changes

Do not add:

- C#.
- Combat.
- Multiplayer.
- Quest systems.
- Large inventory.
- Complex menus.
- Save slots.
- Procedural generation.
- Multi-level hints.
- Sound-only puzzle requirements.
- New autoloads, new global signals, or new folders unless the active prompt explicitly asks.

## Coding Discipline

- One prompt, one module, one test, one commit.
- Do not edit files outside the active prompt unless required for integration and explicitly explained.
- Do not rename existing signals, ids, folders, scenes, or autoloads.
- Keep code typed and readable.
- Prefer small, boring, testable code over clever abstractions.
- If something is unclear, choose the least invasive implementation that preserves `prompts.md`.

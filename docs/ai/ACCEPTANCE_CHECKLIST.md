# Orange Acceptance Checklist

Use this after every coding-agent task.

## Global

- [ ] Project still opens in Godot 4.x.
- [ ] No C# files were introduced.
- [ ] No unrelated systems were rewritten.
- [ ] Files are in the expected `prompts.md` folder structure.
- [ ] Names follow `snake_case` files/folders and `PascalCase` classes.
- [ ] No large inventory, quest system, combat, multiplayer, or complex menu was added.

## Architecture

- [ ] Required autoloads still exist.
- [ ] `EventBus` signal names and signatures were not changed.
- [ ] `GameState` is runtime state only.
- [ ] `SaveSystem` is the only file writer for `user://save.json`.
- [ ] New logic belongs to the correct module.

## Controls

- [ ] Mouse click works.
- [ ] Touch-style input is supported or preserved.
- [ ] UI clicks do not trigger movement accidentally.
- [ ] Interaction stays one-button contextual.

## Puzzle and Reward Flow

- [ ] Puzzle starts correctly.
- [ ] Puzzle solves only when intended.
- [ ] Puzzle solve reveals a fragment.
- [ ] Fragment is manually collected.
- [ ] Mini frame updates in the correct slot.
- [ ] Save is requested after reward.
- [ ] Key item completion fires once.

## UI

- [ ] HUD remains minimal.
- [ ] Action button is large and touch-friendly.
- [ ] Dialogue is short.
- [ ] Orange fictional language and English text are preserved.
- [ ] Floating labels fade out.
- [ ] Hint is one-level only.

## Save/Load

- [ ] Save file is not written every frame.
- [ ] Missing save file does not crash.
- [ ] Reload restores relevant progress.

## Prototype Scope

- [ ] The change does not expand beyond Episode 1 plus Episode 2 bridge.
- [ ] The Secret Map Card remains the main Episode 1 reward.
- [ ] The Episode 2 bridge requires the Secret Map Card.

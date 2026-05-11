# Orange — Phase 2 Implementation Prompts (P31–P42)

This document is the canonical, ordered set of implementation prompts for building Episode 2 of *Orange*. It continues from `prompts.md` (P01–P30), which covers Episode 1 and the Episode 2 sunlit bridge. Treat both documents as a single plan: the architecture, rules, and identifiers from `prompts.md` apply here without exception.

---

## 1. Phase 2 Summary

Phase 1 delivered:

- Episode 1 in full (4 zones, 4 puzzles, Secret Map Card).
- The Episode 2 bridge (Sunlit Map Activation puzzle in a single sunlit clearing zone).
- A prototype end card after the bridge solve.
- Save, load, soft transitions, web export.

Phase 2 delivers:

- **Episode 2: Sunlit Waterfall** — 4 zones, 4 puzzles, 4 Mixed Compass fragments.
- Mixed Compass completion moment (all 4 slots filled).
- Episode 2 end card ("To be continued — the compass is ready.").
- Surgical updates to `EpisodeController`, `zone.gd`, and `constants.gd` so Episode 2 zones load and save correctly.
- Removal of the Phase 1 prototype end card from the bridge zone (EpisodeController handles the transition from bridge → Episode 2 instead).

---

## 2. Absolute Constraints (inherited from prompts.md — non-negotiable)

1. GDScript only. No C#.
2. Godot 4.x API only. No Godot 3 idioms.
3. No new autoloads. No new global signals. No new folders outside the additions listed below.
4. Do not rename any existing signal, autoload, class, or file.
5. Every puzzle must be fully solvable without audio.
6. One-level hint only — no hint tiers.
7. Save after every fragment collection and key item completion. Never per-frame.
8. Smaller agents must not invent new features not listed in a prompt.

---

## 3. Phase 2 Scope

**In scope:**

- 4 Episode 2 zones (`ep2.zone_1` → `ep2.zone_4`) under `episodes/episode_2/zones/`.
- 4 Episode 2 puzzles under `episodes/episode_2/puzzles/`.
- 4 puzzle definition `.tres` files under `episodes/episode_2/definitions/`.
- 3 new JSON data files under `data/dialogue/`, `data/hints/`, `data/floating_labels/`.
- New constants for ep2 zone ids, puzzle ids, and fragment ids.
- Mixed Compass completion trigger (in zone 4) and Episode 2 end card.
- Surgical updates to: `globals/constants.gd`, `globals/episode_controller.gd`, `episodes/zone.gd`.
- Removal of `PrototypeEndCard` from `episodes/episode_2_bridge/zones/zone_sunlit_clearing.tscn`.

**Out of scope (do not add):**

- Episode 3.
- The Teleportation Door.
- Any content beyond what is listed per-prompt.
- Inventory, settings menus, dialogue trees, combat, multiplayer.
- Multi-tier hints, save slots, procedural generation.

---

## 4. What Must Be Preserved From Phase 1

The following files must not be modified in ways that break Episode 1 or the bridge zone, unless a Phase 2 prompt explicitly requires it:

| System | Key requirement |
|--------|----------------|
| `PuzzleBase` | Lifecycle (INACTIVE → ACTIVE → SOLVED), idempotent `mark_solved()`, `_on_already_solved()` virtual |
| `FragmentPickup` | Manual collect via action button — never auto-collected |
| `MiniFrame` | Fills by `frame_slot` order; fires `key_item_completed` when all slots filled |
| `KeyItemInventory` | `grant`, `has`, `get_item`, `use` — no changes |
| `SaveSystem` | Saves only on `save_requested` and `fragment_collected`; single save path |
| `EpisodeController` | Only module that calls `change_scene_to_file`; existing zone paths for ep1 and ep2bridge must remain intact |
| `HUD`, `DialogueBox`, `HintButton` | Reused as-is in all ep2 zones; no structural changes |
| `InteractionManager` | Existing `_dispatch_action` logic for ep1/ep2bridge puzzles unchanged |
| `ZoneExit` | Works by `target_zone_id` → `EpisodeController.zone_path_for_id()` |
| All Episode 1 zones and puzzles | Must pass end-to-end after every Phase 2 prompt |
| Bridge zone solve flow | Sunlit Map Activation emits `key_item_used(&"key.secret_map_card", &"sunlit_clearing")`; EpisodeController handles the transition to ep2.zone_1 (after P36) |

---

## 5. New Folder Structure Additions

```
res://
├── episodes/
│   └── episode_2/
│       ├── zones/
│       │   ├── zone_1_waterfall_entry.tscn
│       │   ├── zone_2_upper_stream.tscn
│       │   ├── zone_3_mist_pool.tscn
│       │   └── zone_4_rock_face.tscn
│       ├── puzzles/
│       │   ├── sun_reflection/
│       │   │   ├── sun_reflection_puzzle.tscn
│       │   │   └── sun_reflection_puzzle.gd
│       │   ├── water_flow_path/
│       │   │   ├── water_flow_path_puzzle.tscn
│       │   │   └── water_flow_path_puzzle.gd
│       │   ├── mist_symbol/
│       │   │   ├── mist_symbol_puzzle.tscn
│       │   │   └── mist_symbol_puzzle.gd
│       │   └── rock_water/
│       │       ├── rock_water_puzzle.tscn
│       │       └── rock_water_puzzle.gd
│       └── definitions/
│           ├── puzzle_sun_reflection.tres
│           ├── puzzle_water_flow.tres
│           ├── puzzle_mist_symbol.tres
│           └── puzzle_rock_water.tres
├── data/
│   ├── dialogue/
│   │   └── episode_2.json              (new)
│   ├── hints/
│   │   └── episode_2.json              (new)
│   └── floating_labels/
│       └── episode_2.json              (new)
└── ui/
    ├── ep2_end_card.tscn               (new)
    └── ep2_end_card.gd                 (new)
```

No other new folders. Place files exactly as shown.

---

## 6. New Identifiers

All new identifiers for Phase 2. Smaller agents must use these values exactly.

### 6.1 New Constants (to add to `globals/constants.gd` in P31)

```gdscript
# Episode 2 puzzle ids
const PUZZLE_SUN_REFLECTION: StringName = &"ep2.sun_reflection"
const PUZZLE_WATER_FLOW:     StringName = &"ep2.water_flow"
const PUZZLE_MIST_SYMBOL:    StringName = &"ep2.mist_symbol"
const PUZZLE_ROCK_WATER:     StringName = &"ep2.rock_water"

# Episode 2 fragment ids (belong to the Mixed Compass)
const FRAG_COMPASS_1: StringName = &"ep2.compass.frag_1"
const FRAG_COMPASS_2: StringName = &"ep2.compass.frag_2"
const FRAG_COMPASS_3: StringName = &"ep2.compass.frag_3"
const FRAG_COMPASS_4: StringName = &"ep2.compass.frag_4"

# Episode 2 zone ids
const ZONE_EP2_1: StringName = &"ep2.zone_1"
const ZONE_EP2_2: StringName = &"ep2.zone_2"
const ZONE_EP2_3: StringName = &"ep2.zone_3"
const ZONE_EP2_4: StringName = &"ep2.zone_4"
```

### 6.2 Episode Identifier

The episode id for Episode 2 is `&"ep2"`. Distinct from `&"ep2bridge"`. Zone IDs use the prefix `"ep2."` (with dot) to avoid collision with `"ep2bridge"` in string prefix checks.

### 6.3 Sub-Interactable IDs

These are the `interactable_id` values set on child `Interactable` nodes inside each puzzle scene. They are NOT the same as the puzzle id. Because they do not match any puzzle constant, `InteractionManager._dispatch_action` routes them through `action_dispatched` (the else branch), and the puzzle scene handles them directly.

| Puzzle | Interactable IDs |
|--------|-----------------|
| Sun Reflection | `ep2.sun_reflection.stone_1`, `ep2.sun_reflection.stone_2`, `ep2.sun_reflection.stone_3` |
| Water Flow Path | `ep2.water_flow.channel_1`, `ep2.water_flow.channel_2`, `ep2.water_flow.channel_3`, `ep2.water_flow.confirm` |
| Mist Symbol | `ep2.mist_symbol.panel_a`, `ep2.mist_symbol.panel_b`, `ep2.mist_symbol.panel_c`, `ep2.mist_symbol.panel_d` |
| Rock Water | `ep2.rock_water.mark_a`, `ep2.rock_water.mark_b`, `ep2.rock_water.mark_c`, `ep2.rock_water.mark_d` |

---

## 7. Episode 2 Zone Architecture

| Zone ID | Scene file | Puzzle housed | Exit target |
|---------|------------|---------------|-------------|
| `ep2.zone_1` | `zone_1_waterfall_entry.tscn` | Sun Reflection | `ep2.zone_2` |
| `ep2.zone_2` | `zone_2_upper_stream.tscn` | Water Flow Path | `ep2.zone_3` |
| `ep2.zone_3` | `zone_3_mist_pool.tscn` | Mist Symbol | `ep2.zone_4` |
| `ep2.zone_4` | `zone_4_rock_face.tscn` | Rock Water + Compass completion | (none — end card appears) |

Each zone follows the same template as Episode 1 zones:
- Root: `Node2D` with `zone.gd` script; `zone_id` exported and set.
- Children: `Background`, `WalkableArea`, `Interactables`, `OrangeCharacter`, `FollowCamera`, `HUD`, `ActionButton`, `DialogueBox`, `HintButton`, `InteractionManager`.
- Zone exit: a `ZoneExit` Area2D node with `target_zone_id` set; present in zones 1–3, absent in zone 4.

---

## 8. Mixed Compass Fragment Rewards

| Fragment constant | Puzzle | Frame slot | Art path (placeholder) |
|------------------|--------|-----------|-------------------------|
| `FRAG_COMPASS_1` | Sun Reflection | 0 | `res://art/compass_frag_1.png` |
| `FRAG_COMPASS_2` | Water Flow | 1 | `res://art/compass_frag_2.png` |
| `FRAG_COMPASS_3` | Mist Symbol | 2 | `res://art/compass_frag_3.png` |
| `FRAG_COMPASS_4` | Rock Water | 3 | `res://art/compass_frag_4.png` |

When all 4 are collected, `MiniFrame` fires `key_item_completed(&"key.mixed_compass")`.

---

## 9. Episode 2 Puzzle Mechanic Overview

### 9.1 Sun Reflection (zone_1)

Three `ReflectiveStone` Interactables. Each stone has a `rotation_step: int` (0–3, wraps) and a `correct_rotation: int`. Action "Rotate" increments `rotation_step` by 1 (mod 4) and updates the visual. After every rotate, the puzzle checks all three stones: if all match `correct_rotation`, call `mark_solved()`. No penalty for wrong rotations — keep rotating.

### 9.2 Water Flow Path (zone_2)

Three `FlowChannel` Interactables (`channel_1`, `channel_2`, `channel_3`) and one `ConfirmFlow` Interactable (`confirm`). Each channel has `is_open: bool`, toggled by action "Open/Close". The `confirm` interactable has action label "Send Water". On confirm, the puzzle checks whether the combination of open/closed channels matches `expected_open: Array[StringName]` (exported on the puzzle node). If correct, `mark_solved()`. If wrong, show dialogue `"ep2.water_flow_wrong"` and keep current state (no reset).

### 9.3 Mist Symbol (zone_3)

Four `MistPanel` Interactables (`panel_a`–`panel_d`), each representing a different symbol. A `ReferenceSymbol` `Sprite2D` in the scene (not an Interactable) shows the target symbol visually. Exported `correct_panel: StringName` on the puzzle. Action "Examine". On examine: if the panel ID matches `correct_panel`, `mark_solved()`. If wrong, show dialogue `"ep2.mist_symbol_wrong"`. No state change; player can re-examine.

### 9.4 Rock Water (zone_4)

Four `ErosionRock` Interactables (`mark_a`–`mark_d`), representing water-level marks at different heights on a rock face (mark_a lowest, mark_d highest). The player must tap them from lowest to highest. Action "Touch". The puzzle tracks `_tapped_sequence: Array[StringName]`. On each tap, append the ID; if it matches the correct prefix of `expected_order`, continue. If it diverges, reset `_tapped_sequence` and show dialogue `"ep2.rock_water_wrong"`. On full match (all 4 in order), `mark_solved()`.

---

## 10. JSON Data Definitions

### 10.1 `data/dialogue/episode_2.json`

```json
{
  "ep2.entry":               { "orange": "Muu ruu wa!",    "english": "This is the place. Light and water, together." },
  "ep2.sun_reflection_intro":{ "orange": "Ruu shini?",     "english": "The stones are catching the light." },
  "ep2.sun_reflection_wrong":{ "orange": "Mimi...",        "english": "The light went the wrong way." },
  "ep2.sun_reflection_solved":{ "orange": "Waa! Ruu mii!", "english": "The symbol is glowing. The compass remembers this." },
  "ep2.water_flow_intro":    { "orange": "Ru ru ru...",    "english": "The water wants to go somewhere." },
  "ep2.water_flow_wrong":    { "orange": "Mimi ruu?",      "english": "That path leads the water astray." },
  "ep2.water_flow_solved":   { "orange": "Wa ruu!",        "english": "The flowers are drinking. They know the compass." },
  "ep2.mist_symbol_intro":   { "orange": "Miii...",        "english": "Something is hiding in the mist." },
  "ep2.mist_symbol_wrong":   { "orange": "Muu...",         "english": "That symbol is different." },
  "ep2.mist_symbol_solved":  { "orange": "Ruu wa!",        "english": "I found it. The mist keeps its secrets well." },
  "ep2.rock_water_intro":    { "orange": "Ru mimi?",       "english": "These marks remember how high the water climbed." },
  "ep2.rock_water_wrong":    { "orange": "Muu ruu.",       "english": "The water didn't climb in that order." },
  "ep2.rock_water_solved":   { "orange": "Wa ruu wa!",     "english": "The rocks told me everything. The compass is almost ready." },
  "ep2.compass_completed":   { "orange": "RUUU!",          "english": "The Mixed Compass is complete. It will guide me wherever I need to go." }
}
```

### 10.2 `data/hints/episode_2.json`

```json
{
  "ep2.sun_reflection": "Each stone bends the light. Try rotating them until all three beams meet at the symbol.",
  "ep2.water_flow":     "Only one combination of open and closed channels sends water to all three roots.",
  "ep2.mist_symbol":    "Look at the carved mark near the mist pool. One of the four symbols in the mist matches it exactly.",
  "ep2.rock_water":     "The lowest mark on the rock face holds the oldest memory of the water."
}
```

### 10.3 `data/floating_labels/episode_2.json`

```json
{
  "ep2.sun_reflection.stone_1": "Reflective Stone",
  "ep2.sun_reflection.stone_2": "Reflective Stone",
  "ep2.sun_reflection.stone_3": "Reflective Stone",
  "ep2.water_flow.channel_1":   "Flow Channel",
  "ep2.water_flow.channel_2":   "Flow Channel",
  "ep2.water_flow.channel_3":   "Flow Channel",
  "ep2.water_flow.confirm":     "Water Gate",
  "ep2.mist_symbol.panel_a":    "Mist Panel",
  "ep2.mist_symbol.panel_b":    "Mist Panel",
  "ep2.mist_symbol.panel_c":    "Mist Panel",
  "ep2.mist_symbol.panel_d":    "Mist Panel",
  "ep2.rock_water.mark_a":      "Erosion Mark",
  "ep2.rock_water.mark_b":      "Erosion Mark",
  "ep2.rock_water.mark_c":      "Erosion Mark",
  "ep2.rock_water.mark_d":      "Erosion Mark"
}
```

---

## 11. How to Use These Prompts

Same rules as `prompts.md` section 7:

1. Complete all Phase 1 prompts (P01–P30) before starting Phase 2.
2. Pick the next prompt in order. Do not skip.
3. Paste the full prompt block into the coding agent, along with `prompts.md` sections 1–7 and this document's sections 1–9.
4. After the agent finishes, run the listed test steps manually.
5. If they pass, commit. If they fail, return the failure verbatim.
6. Never run two prompts in parallel.
7. After all Phase 2 prompts, run `phase2_testprompt.md` with Claude Opus.

---

# Implementation Prompts

> Order rationale: P31 adds identifiers. P32–P33 create JSON and resource data. P34 builds zone scenes. P35 wires routes and episode detection. P36 replaces the Phase 1 end card with a live scene transition. P37–P40 implement the four puzzles. P41 adds the compass completion moment and Episode 2 end card. P42 is the final integration pass.

---

## Prompt 31 — Update Constants for Episode 2

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P31 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P31 prompt:

- **Prompt ID:** P31
- **Module name:** Episode 2 Constants
- **Goal:** Add all Episode 2 identifiers to `globals/constants.gd` so every subsequent prompt can reference them without hardcoding strings.
- **Context from previous modules:** P03 created `constants.gd` with Episode 1 and bridge constants. Phase 2 requires new puzzle ids, fragment ids, and zone ids.
- **Files/folders to create or edit:**
  - `res://globals/constants.gd` — add new constants only; do not remove or rename anything.
- **Scene/node structure:** None.
- **GDScript requirements:**
  Add the following constants (exact values, exact names):
  ```gdscript
  # Episode 2 puzzle ids
  const PUZZLE_SUN_REFLECTION: StringName = &"ep2.sun_reflection"
  const PUZZLE_WATER_FLOW:     StringName = &"ep2.water_flow"
  const PUZZLE_MIST_SYMBOL:    StringName = &"ep2.mist_symbol"
  const PUZZLE_ROCK_WATER:     StringName = &"ep2.rock_water"

  # Episode 2 fragment ids (belong to the Mixed Compass)
  const FRAG_COMPASS_1: StringName = &"ep2.compass.frag_1"
  const FRAG_COMPASS_2: StringName = &"ep2.compass.frag_2"
  const FRAG_COMPASS_3: StringName = &"ep2.compass.frag_3"
  const FRAG_COMPASS_4: StringName = &"ep2.compass.frag_4"

  # Episode 2 zone ids
  const ZONE_EP2_1: StringName = &"ep2.zone_1"
  const ZONE_EP2_2: StringName = &"ep2.zone_2"
  const ZONE_EP2_3: StringName = &"ep2.zone_3"
  const ZONE_EP2_4: StringName = &"ep2.zone_4"
  ```
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:** All later Phase 2 scripts must reference these constants rather than hardcoding strings.
- **Acceptance criteria:**
  - Project parses without errors.
  - `print(Constants.PUZZLE_SUN_REFLECTION)` prints `ep2.sun_reflection`.
  - `print(Constants.FRAG_COMPASS_4)` prints `ep2.compass.frag_4`.
  - `print(Constants.ZONE_EP2_1)` prints `ep2.zone_1`.
  - All existing Episode 1 constants are unchanged.
- **Manual test steps:**
  1. Add a temporary script to any scene that prints three of the new constants on `_ready`. Confirm the values. Remove the temp script.
- **Common failure cases to avoid:**
  - Adding the constants inside a function instead of at class scope.
  - Using `String` instead of `StringName` (use `&"..."` literal syntax).
- **Git commit message:** `feat(globals): add Episode 2 constants (P31)`

---

## Prompt 32 — Episode 2 JSON Data Files

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–10)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P32 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P32 prompt:

- **Prompt ID:** P32
- **Module name:** Episode 2 JSON Data
- **Goal:** Create the three Episode 2 JSON data files (dialogue, hints, floating labels) and register them with `HintButton` and `InteractionManager` so they are merged at startup.
- **Context from previous modules:** `HintButton` (`ui/hint_button.gd`) already loads hint files from a `_HINT_PATHS` array. `InteractionManager` (`interaction/interaction_manager.gd`) already loads label files from a `_LABEL_PATHS` array. Both were updated in Phase 1 (FX-002) to use this array pattern. `DialogueBox` (`ui/dialogue_box.gd`) may load only a single episode's JSON based on `GameState.current_episode` — if so, it must be updated here to use the same array pattern.
- **Files/folders to create or edit:**
  - `res://data/dialogue/episode_2.json` — create; see section 10.1 of this document for exact content.
  - `res://data/hints/episode_2.json` — create; see section 10.2 for exact content.
  - `res://data/floating_labels/episode_2.json` — create; see section 10.3 for exact content.
  - `res://ui/hint_button.gd` — add `"res://data/hints/episode_2.json"` to `_HINT_PATHS`.
  - `res://interaction/interaction_manager.gd` — add `"res://data/floating_labels/episode_2.json"` to `_LABEL_PATHS`.
  - `res://ui/dialogue_box.gd` — if it loads a single JSON by episode id, refactor to load all episode files at `_ready()` into a merged `_line_data: Dictionary`, same pattern as HintButton. Add `"res://data/dialogue/episode_1.json"`, `"res://data/dialogue/episode_2_bridge.json"`, and `"res://data/dialogue/episode_2.json"` to the array.
- **Scene/node structure:** None.
- **GDScript requirements:**
  - All three loaders must merge dictionaries from all files in their array at `_ready()` — never replace keys.
  - Missing files are silently skipped (already the pattern from FX-002).
  - The `DialogueBox.show_text(text, duration)` and `show_line(line_id, duration)` methods must work with the merged dictionary.
- **Data/resource requirements:** JSON content exactly as specified in section 10 of this document. No gameplay state in JSON.
- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:**
  - After this prompt, `HintButton.hint_for(&"ep2.sun_reflection")` must return the correct hint text.
  - `InteractionManager._label_data` must contain keys for all 16 ep2 interactable ids.
  - `DialogueBox` (or equivalent) must serve ep2 dialogue lines by key.
- **Acceptance criteria:**
  - All three JSON files exist and are valid JSON.
  - In a running zone, emitting `EventBus.dialogue_requested.emit(&"ep2.entry")` shows the correct orange + English lines.
  - `HintButton.hint_for(&"ep2.water_flow")` returns `"Only one combination..."`.
  - No parser errors on startup.
- **Manual test steps:**
  1. Run zone 1; emit `EventBus.dialogue_requested.emit(&"ep2.entry")` from a temp script. Confirm dialogue shows.
  2. Add a temp print for `HintButton.hint_for(&"ep2.mist_symbol")`; verify it is non-empty.
- **Common failure cases to avoid:**
  - Replacing rather than merging the dictionaries (new keys must not erase old keys).
  - Putting gameplay state (rotation values, open/close flags) in JSON. JSON is for text only.
- **Git commit message:** `feat(data): add Episode 2 JSON data files and register loaders (P32)`

---

## Prompt 33 — Episode 2 Resource Definitions

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P33 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P33 prompt:

- **Prompt ID:** P33
- **Module name:** Episode 2 Puzzle Resource Definitions
- **Goal:** Create the four `.tres` resource files that define Episode 2 puzzles and their fragment rewards. These are the `PuzzleDefinition` resources (from P14) used by each puzzle scene.
- **Context from previous modules:** `PuzzleDefinition` and `FragmentReward` resource scripts exist (`puzzles/puzzle_definition.gd`, `puzzles/fragment_reward.gd`). The `mixed_compass.tres` key item already exists (`key_items/mixed_compass.tres`). Fragment art paths may use placeholders.
- **Files/folders to create or edit:**
  - `res://episodes/episode_2/definitions/puzzle_sun_reflection.tres`
  - `res://episodes/episode_2/definitions/puzzle_water_flow.tres`
  - `res://episodes/episode_2/definitions/puzzle_mist_symbol.tres`
  - `res://episodes/episode_2/definitions/puzzle_rock_water.tres`
- **Scene/node structure:** None — pure resources.
- **GDScript requirements:** None — these are `.tres` data files only.
- **Data/resource requirements:**

  `puzzle_sun_reflection.tres`:
  ```
  puzzle_id            = &"ep2.sun_reflection"
  display_name         = "Sun Reflection"
  episode_id           = &"ep2"
  intro_dialogue_key   = &"ep2.sun_reflection_intro"
  solved_dialogue_key  = &"ep2.sun_reflection_solved"
  fragment_reward:
    fragment_id = &"ep2.compass.frag_1"
    key_item_id = &"key.mixed_compass"
    frame_slot  = 0
    art_path    = "res://art/compass_frag_1.png"
  ```

  `puzzle_water_flow.tres`:
  ```
  puzzle_id            = &"ep2.water_flow"
  display_name         = "Water Flow Path"
  episode_id           = &"ep2"
  intro_dialogue_key   = &"ep2.water_flow_intro"
  solved_dialogue_key  = &"ep2.water_flow_solved"
  fragment_reward:
    fragment_id = &"ep2.compass.frag_2"
    key_item_id = &"key.mixed_compass"
    frame_slot  = 1
    art_path    = "res://art/compass_frag_2.png"
  ```

  `puzzle_mist_symbol.tres`:
  ```
  puzzle_id            = &"ep2.mist_symbol"
  display_name         = "Mist Symbol"
  episode_id           = &"ep2"
  intro_dialogue_key   = &"ep2.mist_symbol_intro"
  solved_dialogue_key  = &"ep2.mist_symbol_solved"
  fragment_reward:
    fragment_id = &"ep2.compass.frag_3"
    key_item_id = &"key.mixed_compass"
    frame_slot  = 2
    art_path    = "res://art/compass_frag_3.png"
  ```

  `puzzle_rock_water.tres`:
  ```
  puzzle_id            = &"ep2.rock_water"
  display_name         = "Rock Water Height"
  episode_id           = &"ep2"
  intro_dialogue_key   = &"ep2.rock_water_intro"
  solved_dialogue_key  = &"ep2.rock_water_solved"
  fragment_reward:
    fragment_id = &"ep2.compass.frag_4"
    key_item_id = &"key.mixed_compass"
    frame_slot  = 3
    art_path    = "res://art/compass_frag_4.png"
  ```

- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:** Each `.tres` must load cleanly via `load("res://episodes/episode_2/definitions/puzzle_*.tres")`. Puzzle scenes created in P37–P40 will set `definition = preload(...)` on the puzzle node.
- **Acceptance criteria:**
  - All four `.tres` files load without errors.
  - `load("res://episodes/episode_2/definitions/puzzle_sun_reflection.tres").puzzle_id == &"ep2.sun_reflection"` is true.
  - `load("res://episodes/episode_2/definitions/puzzle_rock_water.tres").fragment_reward.frame_slot == 3` is true.
- **Manual test steps:**
  1. Add a temp script that loads all four `.tres` files and prints their `puzzle_id` fields. Confirm values. Remove the temp script.
- **Common failure cases to avoid:**
  - Setting `frame_slot` out of order (must be 0, 1, 2, 3 for frag_1, frag_2, frag_3, frag_4 respectively).
  - Referencing a non-existent key item id (must use `&"key.mixed_compass"` exactly).
- **Git commit message:** `feat(ep2): add Episode 2 puzzle resource definitions (P33)`

---

## Prompt 34 — Episode 2 Zone Scenes

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P34 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P34 prompt:

- **Prompt ID:** P34
- **Module name:** Episode 2 Zone Scenes
- **Goal:** Create the four Episode 2 zone scenes following the same template as Episode 1 zones. Puzzles are not yet placed — just the shell. Zone exits wire zones 1→2→3. Zone 4 has no exit.
- **Context from previous modules:** Episode 1 zones (`episodes/episode_1/zones/`) and the bridge zone are working references. `ZoneExit` (`episodes/zone_exit.gd`) handles zone transitions. `EpisodeController.zone_path_for_id()` is called by `ZoneExit` — this will fail for ep2 zone ids until P35 registers them. Do not test zone exits until after P35.
- **Files/folders to create or edit:**
  - `res://episodes/episode_2/zones/zone_1_waterfall_entry.tscn`
  - `res://episodes/episode_2/zones/zone_2_upper_stream.tscn`
  - `res://episodes/episode_2/zones/zone_3_mist_pool.tscn`
  - `res://episodes/episode_2/zones/zone_4_rock_face.tscn`
- **Scene/node structure:** Each zone scene follows this structure exactly:
  ```
  [Node2D "Zone*"]              ← script: episodes/zone.gd; zone_id exported
    [Node2D "Background"]
    [Area2D "WalkableArea"]
      [CollisionShape2D]        ← RectangleShape2D 2560×1440
    [Node2D "Interactables"]   ← puzzle scene will be instanced here in P37–P40
    [OrangeCharacter]           ← instance: characters/orange/orange_character.tscn
    [Camera2D "FollowCamera"]   ← instance: camera/follow_camera.tscn; target_path = OrangeCharacter
    [CanvasLayer "HUD"]         ← instance: ui/hud.tscn
    [ActionButton]              ← instance: ui/action_button.tscn
    [DialogueBox]               ← instance: ui/dialogue_box.tscn
    [HintButton]                ← instance: ui/hint_button.tscn
    [Node "InteractionManager"] ← script: interaction/interaction_manager.gd; orange = OrangeCharacter
  ```
  Zones 1–3 additionally have:
  ```
    [Area2D "ZoneExit"]         ← script: episodes/zone_exit.gd; target_zone_id set per zone
      [CollisionShape2D]        ← small rectangle at zone boundary
  ```
  Zone 4 does NOT have a ZoneExit. The compass completion trigger (P41) ends episode 2.

  Zone IDs:
  - zone_1_waterfall_entry: `zone_id = &"ep2.zone_1"`
  - zone_2_upper_stream:    `zone_id = &"ep2.zone_2"`
  - zone_3_mist_pool:       `zone_id = &"ep2.zone_3"`
  - zone_4_rock_face:       `zone_id = &"ep2.zone_4"`

  ZoneExit targets:
  - zone_1 → `target_zone_id = &"ep2.zone_2"`
  - zone_2 → `target_zone_id = &"ep2.zone_3"`
  - zone_3 → `target_zone_id = &"ep2.zone_4"`

- **GDScript requirements:** No new scripts. Uses existing `zone.gd`, `zone_exit.gd`, `interaction_manager.gd`.
- **Data/resource requirements:** None.
- **UI requirements:** HUD, ActionButton, DialogueBox, HintButton instanced and wired via `zone.gd`'s `_setup_hud()`.
- **Save/load requirements:** Zone entry sets `GameState.current_zone` via `zone.gd` (no change needed).
- **Integration requirements:**
  - Do not open a zone in Godot and run it yet — `ZoneExit` will push an error because ep2 zone paths are not in `EpisodeController._ZONE_PATHS` until P35. This is expected.
  - Visuals may be placeholder colored rectangles or empty.
- **Acceptance criteria:**
  - All four `.tscn` files exist and open in the Godot editor without errors.
  - Zone IDs are set correctly on each zone root node.
  - ZoneExit `target_zone_id` is correct on zones 1–3.
  - Zone 4 has no ZoneExit node.
- **Manual test steps:**
  1. Open each scene in the Godot editor; confirm no red errors in the scene tree.
  2. Verify zone_id property in the inspector for each zone root.
  3. Do NOT run until after P35.
- **Common failure cases to avoid:**
  - Adding a ZoneExit to zone 4.
  - Setting `zone_id` to a wrong string (e.g. `"ep2bridge.zone_1"`).
  - Forgetting to export `zone_id` as a variable on the zone root (it's inherited from `zone.gd`).
- **Git commit message:** `feat(ep2): add four Episode 2 zone scenes (P34)`

---

## Prompt 35 — Wire Episode 2 Routes into Core Systems

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P35 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P35 prompt:

- **Prompt ID:** P35
- **Module name:** Episode 2 Core System Wiring
- **Goal:** Register Episode 2 zone paths and key item in `EpisodeController`, add Episode 2 episode detection in `zone.gd`, and confirm `InteractionManager` does not need changes for ep2 sub-interactables. After this prompt, all four Episode 2 zones can be loaded by `ZoneExit`. The bridge → Episode 2 transition is wired in P36, not here.
- **Context from previous modules:** `EpisodeController` (`globals/episode_controller.gd`) holds `_ZONE_PATHS` and `_EPISODE_KEY_ITEMS` dictionaries and detects zone episode via `_on_node_added`. `zone.gd` syncs `GameState.current_episode` in `_ready()`. After Phase 1 FX-003, `_on_node_added` checks for `"ep2bridge"` before `"ep1"` to avoid prefix collisions.
- **Files/folders to create or edit:**
  - `res://globals/episode_controller.gd` — add ep2 zone paths and ep2 key item.
  - `res://episodes/zone.gd` — add `"ep2."` prefix detection.
- **Scene/node structure:** None.
- **GDScript requirements:**

  **In `episode_controller.gd`:**

  1. Add to `_ZONE_PATHS`:
     ```gdscript
     &"ep2.zone_1": "res://episodes/episode_2/zones/zone_1_waterfall_entry.tscn",
     &"ep2.zone_2": "res://episodes/episode_2/zones/zone_2_upper_stream.tscn",
     &"ep2.zone_3": "res://episodes/episode_2/zones/zone_3_mist_pool.tscn",
     &"ep2.zone_4": "res://episodes/episode_2/zones/zone_4_rock_face.tscn",
     ```

  2. Add to `_EPISODE_KEY_ITEMS`:
     ```gdscript
     &"ep2": "res://key_items/mixed_compass.tres",
     ```

  3. In `_on_node_added`, update the Zone detection block to include ep2. The check for `"ep2bridge"` must remain BEFORE `"ep2."` to avoid substring collision:
     ```gdscript
     if node is Zone:
         var zid := str((node as Zone).zone_id)
         if zid.begins_with("ep2bridge"):
             set_episode(&"ep2bridge")
         elif zid.begins_with("ep2."):   # dot avoids matching "ep2bridge"
             set_episode(&"ep2")
         elif zid.begins_with("ep1"):
             set_episode(&"ep1")
     ```

  **In `zone.gd`:**

  In `_ready()`, update the `current_episode` sync block to include ep2. Again, `"ep2bridge"` must be checked before `"ep2."`:
  ```gdscript
  if str(zone_id).begins_with("ep2bridge"):
      GameState.current_episode = &"ep2bridge"
  elif str(zone_id).begins_with("ep2."):
      GameState.current_episode = &"ep2"
  elif str(zone_id).begins_with("ep1"):
      GameState.current_episode = &"ep1"
  ```

  **InteractionManager note:** No changes needed. Episode 2 puzzle sub-interactables (IDs like `"ep2.sun_reflection.stone_1"`) do not match any puzzle constant in `_dispatch_action`, so they correctly fall through to the `action_dispatched.emit(interactable)` else-branch. Each ep2 puzzle scene will connect to `InteractionManager.action_dispatched` directly.

- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None. The save schema does not change; ep2 zone ids and fragment ids are stored as strings in existing arrays.
- **Integration requirements:**
  - After this prompt, opening `ep2.zone_1` in the editor and pressing F6 ("Run Current Scene") should load without errors and allow Orange to walk to the zone exit and reach zone 2.
  - MiniFrame should rebind to `mixed_compass.tres` when any ep2 zone loads.
  - Episode 1 zones must still work end-to-end.
- **Acceptance criteria:**
  - `EpisodeController.zone_path_for_id(&"ep2.zone_3")` returns `"res://episodes/episode_2/zones/zone_3_mist_pool.tscn"`.
  - Running ep2.zone_1 and walking to zone exit transitions to ep2.zone_2.
  - Running ep2.zone_1, observing the HUD MiniFrame shows the Mixed Compass slots (empty).
  - Running ep1.zone_1 end-to-end still works.
- **Manual test steps:**
  1. Add a temp print: `print(EpisodeController.zone_path_for_id(&"ep2.zone_4"))`. Confirm output is the correct path.
  2. Run `zone_1_waterfall_entry.tscn`; walk Orange to the zone exit; confirm zone 2 loads.
  3. Run Episode 1 zone 1 → zone 4 → bridge; confirm end card still shows (not yet changed — P36 does that).
- **Common failure cases to avoid:**
  - Checking `"ep2."` before `"ep2bridge"` — this would incorrectly classify bridge zones as ep2.
  - Adding zone paths with a typo in the file name — the path must exactly match the filename from P34.
- **Git commit message:** `feat(core): wire Episode 2 zone routes and episode detection (P35)`

---

## Prompt 36 — Bridge Zone Transition Update

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P36 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P36 prompt:

- **Prompt ID:** P36
- **Module name:** Bridge → Episode 2 Live Transition
- **Goal:** Replace the Phase 1 prototype end card with a live transition to Episode 2. When the bridge puzzle fires `key_item_used(&"key.secret_map_card", &"sunlit_clearing")`, `EpisodeController` now transitions to `ep2.zone_1` instead of showing an end card. The `PrototypeEndCard` and `EndCardLayer` are removed from the bridge zone scene.
- **Context from previous modules:** Phase 1 (P28) added `PrototypeEndCard` under an `EndCardLayer (CanvasLayer, layer=64)` in `zone_sunlit_clearing.tscn`. `PrototypeEndCard` listens to `key_item_used` and shows an end screen. In Phase 2, `EpisodeController` takes over that responsibility. `EpisodeController` is the only module that may call `change_scene_to_file` (architectural rule C05).
- **Files/folders to create or edit:**
  - `res://episodes/episode_2_bridge/zones/zone_sunlit_clearing.tscn` — remove `EndCardLayer` and `PrototypeEndCard` nodes.
  - `res://globals/episode_controller.gd` — add `key_item_used` signal handler that transitions to ep2.zone_1.
- **Scene/node structure:**
  Remove from `zone_sunlit_clearing.tscn`:
  - The `[ext_resource ... path="res://ui/prototype_end_card.tscn" ...]` ext_resource entry.
  - The `[node name="EndCardLayer" type="CanvasLayer" ...]` node.
  - The `[node name="PrototypeEndCard" parent="EndCardLayer" ...]` node.
  The `prototype_end_card.tscn` and `prototype_end_card.gd` files themselves are NOT deleted — they may be used in tests.
- **GDScript requirements:**

  In `episode_controller.gd`, in `_ready()`, add:
  ```gdscript
  EventBus.key_item_used.connect(_on_key_item_used)
  ```

  Add the handler:
  ```gdscript
  func _on_key_item_used(key_item_id: StringName, context: StringName) -> void:
      if key_item_id == Constants.KEY_SECRET_MAP_CARD and context == &"sunlit_clearing":
          var path := zone_path_for_id(Constants.ZONE_EP2_1)
          if path.is_empty():
              push_error("EpisodeController: ep2.zone_1 path not registered.")
              return
          EventBus.zone_change_requested.emit(path)
  ```

- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None. The bridge puzzle already sets `flags["episode_2_route_revealed"] = true` (P27). This remains unchanged.
- **Integration requirements:**
  - After this prompt, solving the bridge puzzle must transition to `ep2.zone_1` with a soft fade (provided by `EpisodeController._change_scene_faded`).
  - The old "prototype end card" behavior is gone from the bridge zone.
  - Episode 1 end-to-end flow is unaffected (the bridge puzzle solve still works; it just ends at ep2 now).
- **Acceptance criteria:**
  - `zone_sunlit_clearing.tscn` no longer contains EndCardLayer or PrototypeEndCard.
  - Solving the bridge puzzle triggers the soft fade and loads `zone_1_waterfall_entry.tscn`.
  - The MiniFrame in ep2.zone_1 shows the Mixed Compass (empty slots).
  - No errors in the Output tab.
- **Manual test steps:**
  1. Run the bridge zone; solve the puzzle (or force `EventBus.key_item_used.emit(&"key.secret_map_card", &"sunlit_clearing")` from a temp script). Confirm zone_1_waterfall_entry loads.
  2. Confirm no prototype end card appears.
  3. Confirm MiniFrame shows Mixed Compass in ep2.zone_1.
- **Common failure cases to avoid:**
  - Connecting `key_item_used` multiple times (use `connect` once in `_ready`, not in `_on_node_added`).
  - Removing `prototype_end_card.tscn` from the file system — only remove it from the bridge zone's `.tscn`.
- **Git commit message:** `feat(core): bridge zone transitions to Episode 2 via EpisodeController (P36)`

---

## Prompt 37 — Sun Reflection Puzzle (Episode 2, Zone 1)

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P37 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P37 prompt:

- **Prompt ID:** P37
- **Module name:** Episode 2 Puzzle 1 — Sun Reflection
- **Goal:** Implement the sun reflection puzzle: three reflective stones that the player rotates until all three redirect light beams to a common target symbol. When all three match their correct rotation, the puzzle solves.
- **Context from previous modules:** `PuzzleBase` handles the lifecycle (`INACTIVE → ACTIVE → SOLVED`). `FragmentPickup` appears after `puzzle_solved`. `InteractionManager.action_dispatched` carries sub-interactable taps to the puzzle. The puzzle definition resource `puzzle_sun_reflection.tres` (from P33) provides `fragment_reward` and dialogue keys.
- **Files/folders to create or edit:**
  - `res://episodes/episode_2/puzzles/sun_reflection/sun_reflection_puzzle.tscn`
  - `res://episodes/episode_2/puzzles/sun_reflection/sun_reflection_puzzle.gd`
  - `res://episodes/episode_2/zones/zone_1_waterfall_entry.tscn` — instance the puzzle under `Interactables`.
- **Scene/node structure:**

  `sun_reflection_puzzle.tscn`:
  ```
  [Node2D "SunReflectionPuzzle"]   ← script: sun_reflection_puzzle.gd; definition = puzzle_sun_reflection.tres
    [Interactable "Stone1"]        ← interactable_id = &"ep2.sun_reflection.stone_1"; action_label = "Rotate"
    [Interactable "Stone2"]        ← interactable_id = &"ep2.sun_reflection.stone_2"; action_label = "Rotate"
    [Interactable "Stone3"]        ← interactable_id = &"ep2.sun_reflection.stone_3"; action_label = "Rotate"
    [Sprite2D "TargetSymbol"]      ← static visual; shows where the beams should converge
  ```

  Each `Interactable` is an `Area2D` (or the existing `Interactable` scene from interaction/) with the appropriate id. Add placeholder `Sprite2D` children to each Stone for visual feedback (rotation arrow or directional indicator).

- **GDScript requirements:**

  `class_name SunReflectionPuzzle extends PuzzleBase`

  Exports (set these in the inspector, not hardcoded):
  ```gdscript
  @export var correct_rotation_stone1: int = 2   # default values; override in inspector
  @export var correct_rotation_stone2: int = 1
  @export var correct_rotation_stone3: int = 3
  ```

  Internal state per stone (use a Dictionary keyed by `interactable_id`):
  ```gdscript
  var _rotations: Dictionary = {
      &"ep2.sun_reflection.stone_1": 0,
      &"ep2.sun_reflection.stone_2": 0,
      &"ep2.sun_reflection.stone_3": 0,
  }
  ```

  `_ready()`:
  ```gdscript
  func _ready() -> void:
      super()
      if _state == State.INACTIVE:
          start_puzzle()
      if _state == State.ACTIVE:
          _connect_manager()

  func _connect_manager() -> void:
      var im := get_tree().get_current_scene().get_node_or_null("InteractionManager") as InteractionManager
      if im:
          im.action_dispatched.connect(_on_action_dispatched)
  ```

  `_on_action_dispatched(interactable: Interactable)`:
  - If `interactable.interactable_id` does not start with `"ep2.sun_reflection."`, return.
  - Increment the rotation for that stone: `_rotations[id] = (_rotations[id] + 1) % 4`.
  - Update the stone's visual (rotate the `Sprite2D` by 90° per step).
  - Check: if all three rotations match their correct values, call `mark_solved()`.

  `_on_already_solved()`:
  - Set all stones' visuals to their correct rotation.
  - Disconnect from `action_dispatched` if connected.
  - Hide the stones (or mark them visually inert) so they are not re-interactable.

- **Data/resource requirements:** `puzzle_sun_reflection.tres` from P33. Art paths may be placeholder colored rectangles.
- **UI requirements:** Reuses dialogue, hint button, action button. No new UI.
- **Save/load requirements:** `PuzzleBase.mark_solved()` calls `GameState.mark_puzzle_completed()` which triggers `SaveSystem` via `save_requested`.
- **Integration requirements:**
  - Instance `SunReflectionPuzzle` under the `Interactables` node in `zone_1_waterfall_entry.tscn`.
  - The puzzle auto-starts when zone 1 loads. HintButton becomes active. Hint text: `"Each stone bends the light..."` (from `data/hints/episode_2.json`).
  - After solving, `FragmentPickup` appears (from `PuzzleBase` emitting `fragment_revealed`). Player must manually collect it.
  - Collecting `frag_1` fills MiniFrame slot 0. Save fires.
- **Acceptance criteria:**
  - Tapping each stone and pressing "Rotate" increments its visual rotation by 90°.
  - Setting all three stones to their correct rotations solves the puzzle and reveals the fragment.
  - Wrong rotation combinations produce no error and no dialogue — player simply keeps rotating.
  - HintButton is active during the puzzle and shows the correct hint.
  - Reloading after collecting the fragment: puzzle is already solved, stones are inert, fragment is gone, MiniFrame slot 0 is filled.
- **Manual test steps:**
  1. Run `zone_1_waterfall_entry.tscn`; tap a stone; press Rotate multiple times; verify visual rotation.
  2. Set all three to correct values; verify fragment appears.
  3. Collect fragment; verify MiniFrame slot 0 fills and save fires.
  4. Restart; verify puzzle is already solved (stones are inert).
- **Common failure cases to avoid:**
  - Connecting to `action_dispatched` when `_state == State.SOLVED` (solved puzzles must not respond to new taps).
  - Using hardcoded correct rotation values instead of exported variables (correct values must be inspector-adjustable).
  - Calling `mark_solved()` more than once if the player rotates past a solved state (guard with `_state == State.ACTIVE`).
- **Git commit message:** `feat(ep2): sun reflection puzzle (P37)`

---

## Prompt 38 — Water Flow Path Puzzle (Episode 2, Zone 2)

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P38 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P38 prompt:

- **Prompt ID:** P38
- **Module name:** Episode 2 Puzzle 2 — Water Flow Path
- **Goal:** Implement the water flow path puzzle: three channels the player opens or closes, and a confirm interactable that sends water. Only one combination of open/closed channels is correct. Wrong combinations show gentle dialogue and reset nothing; the player adjusts channels and tries again.
- **Context from previous modules:** Same architecture as P37: auto-start in `_ready()`, connect to `InteractionManager.action_dispatched`. Definition resource: `puzzle_water_flow.tres`.
- **Files/folders to create or edit:**
  - `res://episodes/episode_2/puzzles/water_flow_path/water_flow_path_puzzle.tscn`
  - `res://episodes/episode_2/puzzles/water_flow_path/water_flow_path_puzzle.gd`
  - `res://episodes/episode_2/zones/zone_2_upper_stream.tscn` — instance the puzzle under `Interactables`.
- **Scene/node structure:**

  `water_flow_path_puzzle.tscn`:
  ```
  [Node2D "WaterFlowPathPuzzle"]  ← script: water_flow_path_puzzle.gd; definition = puzzle_water_flow.tres
    [Interactable "Channel1"]     ← interactable_id = &"ep2.water_flow.channel_1"; action_label updates dynamically
    [Interactable "Channel2"]     ← interactable_id = &"ep2.water_flow.channel_2"
    [Interactable "Channel3"]     ← interactable_id = &"ep2.water_flow.channel_3"
    [Interactable "ConfirmFlow"]  ← interactable_id = &"ep2.water_flow.confirm"; action_label = "Send Water"
    [Sprite2D "FlowIndicator"]   ← optional visual showing current flow direction
  ```

- **GDScript requirements:**

  `class_name WaterFlowPathPuzzle extends PuzzleBase`

  ```gdscript
  @export var expected_open: Array[StringName] = [
      &"ep2.water_flow.channel_1",
      &"ep2.water_flow.channel_3",
  ]
  ```
  (Default: channels 1 and 3 open, channel 2 closed. Override in inspector.)

  Internal state:
  ```gdscript
  var _channel_open: Dictionary = {
      &"ep2.water_flow.channel_1": false,
      &"ep2.water_flow.channel_2": false,
      &"ep2.water_flow.channel_3": false,
  }
  ```

  On `action_dispatched`:
  - If id is a channel id: toggle `_channel_open[id]`; update the channel's action_label to "Open" or "Close" to reflect new state; update `FlowIndicator` visual.
  - If id is `&"ep2.water_flow.confirm"`: check whether the set of open channels equals `expected_open`. If correct: `mark_solved()`. If wrong: `EventBus.dialogue_requested.emit(&"ep2.water_flow_wrong")`. No state reset.

  `_on_already_solved()`: hide channel interactables and ConfirmFlow. Show a "solved" visual state.

- **Data/resource requirements:** `puzzle_water_flow.tres` from P33.
- **UI requirements:** Action label on channel interactables must reflect current state ("Open" when closed, "Close" when open).
- **Save/load requirements:** PuzzleBase handles.
- **Integration requirements:** Instance in zone 2 under Interactables.
- **Acceptance criteria:**
  - Tapping a channel and pressing action toggles it and changes the action label.
  - Pressing "Send Water" with the wrong combination shows gentle dialogue; channels stay in their current state.
  - Pressing "Send Water" with the correct combination solves the puzzle and reveals frag_2.
  - Collecting frag_2 fills MiniFrame slot 1.
- **Manual test steps:**
  1. Run zone 2; toggle channels; verify action label changes.
  2. Press Send Water with wrong combo; verify dialogue, no reset.
  3. Set correct combo; press Send Water; verify solve and fragment.
- **Common failure cases to avoid:**
  - Resetting channel state on wrong answer (cozy design: no punishment).
  - Comparing channel sets as arrays (order matters in arrays but not in this puzzle — compare as sets or sort both before comparing).
- **Git commit message:** `feat(ep2): water flow path puzzle (P38)`

---

## Prompt 39 — Mist Symbol Puzzle (Episode 2, Zone 3)

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P39 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P39 prompt:

- **Prompt ID:** P39
- **Module name:** Episode 2 Puzzle 3 — Mist Symbol
- **Goal:** Four mist panels, each showing a different symbol. A static reference symbol is carved on a rock nearby. The player must examine the panel whose symbol matches the reference. Correct → solve. Wrong → gentle dialogue, no state change.
- **Context from previous modules:** Same auto-start and action_dispatched pattern. Definition resource: `puzzle_mist_symbol.tres`.
- **Files/folders to create or edit:**
  - `res://episodes/episode_2/puzzles/mist_symbol/mist_symbol_puzzle.tscn`
  - `res://episodes/episode_2/puzzles/mist_symbol/mist_symbol_puzzle.gd`
  - `res://episodes/episode_2/zones/zone_3_mist_pool.tscn` — instance puzzle under `Interactables`.
- **Scene/node structure:**

  `mist_symbol_puzzle.tscn`:
  ```
  [Node2D "MistSymbolPuzzle"]     ← script; definition = puzzle_mist_symbol.tres
    [Interactable "PanelA"]       ← interactable_id = &"ep2.mist_symbol.panel_a"; action_label = "Examine"
    [Interactable "PanelB"]       ← interactable_id = &"ep2.mist_symbol.panel_b"; action_label = "Examine"
    [Interactable "PanelC"]       ← interactable_id = &"ep2.mist_symbol.panel_c"; action_label = "Examine"
    [Interactable "PanelD"]       ← interactable_id = &"ep2.mist_symbol.panel_d"; action_label = "Examine"
    [Sprite2D "ReferenceSymbol"]  ← static; visually distinct; not an Interactable
  ```

- **GDScript requirements:**

  `class_name MistSymbolPuzzle extends PuzzleBase`

  ```gdscript
  @export var correct_panel: StringName = &"ep2.mist_symbol.panel_c"  # override in inspector
  ```

  On `action_dispatched`:
  - If id does not start with `"ep2.mist_symbol.panel_"`, return.
  - If `id == correct_panel`: `mark_solved()`.
  - Else: `EventBus.dialogue_requested.emit(&"ep2.mist_symbol_wrong")`.

  `_on_already_solved()`: hide or grey out all four panel interactables.

- **Data/resource requirements:** `puzzle_mist_symbol.tres`. Panel symbols may be distinct colored labels or placeholder sprites — must be visually distinguishable.
- **UI requirements:** `ReferenceSymbol` must be clearly different from a panel Interactable (no action button shown when tapping it — it is not an Interactable node).
- **Save/load requirements:** PuzzleBase handles.
- **Integration requirements:** Instance in zone 3.
- **Acceptance criteria:**
  - Tapping the wrong panel shows gentle dialogue; puzzle stays active.
  - Tapping the correct panel solves the puzzle and reveals frag_3.
  - `ReferenceSymbol` is not tappable (no action button appears).
  - Collecting frag_3 fills MiniFrame slot 2.
- **Manual test steps:**
  1. Run zone 3; tap each panel in turn; verify only correct one solves.
  2. Verify ReferenceSymbol has no action button.
  3. Collect frag_3; verify MiniFrame slot 2 fills.
- **Common failure cases to avoid:**
  - Making `ReferenceSymbol` an Interactable node (it must be purely visual).
  - Using the same placeholder color for multiple panels (they must be visually distinguishable).
- **Git commit message:** `feat(ep2): mist symbol puzzle (P39)`

---

## Prompt 40 — Rock Layer and Water Height Puzzle (Episode 2, Zone 4)

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P40 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P40 prompt:

- **Prompt ID:** P40
- **Module name:** Episode 2 Puzzle 4 — Rock Layer and Water Height
- **Goal:** Four erosion marks on a rock face at different heights. The player must touch them from lowest to highest (oldest to most recent water level). Tapping in the wrong order resets progress with gentle dialogue. Correct full sequence solves the puzzle.
- **Context from previous modules:** Same auto-start and action_dispatched pattern. Definition: `puzzle_rock_water.tres`. This is zone 4 — after solving, the compass completion (P41) fires.
- **Files/folders to create or edit:**
  - `res://episodes/episode_2/puzzles/rock_water/rock_water_puzzle.tscn`
  - `res://episodes/episode_2/puzzles/rock_water/rock_water_puzzle.gd`
  - `res://episodes/episode_2/zones/zone_4_rock_face.tscn` — instance puzzle under `Interactables`.
- **Scene/node structure:**

  `rock_water_puzzle.tscn`:
  ```
  [Node2D "RockWaterPuzzle"]    ← script; definition = puzzle_rock_water.tres
    [Interactable "MarkA"]      ← interactable_id = &"ep2.rock_water.mark_a"; action_label = "Touch"; lowest mark
    [Interactable "MarkB"]      ← interactable_id = &"ep2.rock_water.mark_b"; action_label = "Touch"
    [Interactable "MarkC"]      ← interactable_id = &"ep2.rock_water.mark_c"; action_label = "Touch"
    [Interactable "MarkD"]      ← interactable_id = &"ep2.rock_water.mark_d"; action_label = "Touch"; highest mark
  ```
  Visually: marks are at increasing heights on a rock sprite. Mark A is lowest (oldest); mark D is highest (most recent).

- **GDScript requirements:**

  `class_name RockWaterPuzzle extends PuzzleBase`

  ```gdscript
  @export var expected_order: Array[StringName] = [
      &"ep2.rock_water.mark_a",
      &"ep2.rock_water.mark_b",
      &"ep2.rock_water.mark_c",
      &"ep2.rock_water.mark_d",
  ]
  ```

  Internal state:
  ```gdscript
  var _tapped_sequence: Array[StringName] = []
  ```

  On `action_dispatched`:
  - If id does not start with `"ep2.rock_water.mark_"`, return.
  - Append id to `_tapped_sequence`.
  - Check whether `_tapped_sequence` is a valid prefix of `expected_order`:
    - If yes and `_tapped_sequence.size() == expected_order.size()`: `mark_solved()`.
    - If yes but not complete: do nothing (wait for next tap). Optionally highlight the tapped mark visually.
    - If no (diverges from expected order): `_tapped_sequence.clear()`; `EventBus.dialogue_requested.emit(&"ep2.rock_water_wrong")`.

  `_on_already_solved()`: show all marks as "highlighted/complete". Hide or grey interactables.

- **Data/resource requirements:** `puzzle_rock_water.tres`.
- **UI requirements:** No new UI. Consider a subtle highlight on each correctly tapped mark to give visual progress feedback (optional; use a `modulate` color change on the mark's sprite).
- **Save/load requirements:** PuzzleBase handles.
- **Integration requirements:** Instance in zone 4. After solve, MiniFrame slot 3 fills. All 4 slots filled → `key_item_completed(&"key.mixed_compass")`. P41 handles that event.
- **Acceptance criteria:**
  - Tapping A → B → C → D in order solves the puzzle.
  - Tapping A → C (wrong order) resets sequence and shows dialogue.
  - Correct solve reveals frag_4 and fills MiniFrame slot 3.
  - MiniFrame fires `key_item_completed(&"key.mixed_compass")` when slot 3 fills (this is MiniFrame's responsibility, not the puzzle's).
- **Manual test steps:**
  1. Run zone 4; tap marks in wrong order; verify reset dialogue.
  2. Tap A → B → C → D in order; verify puzzle solve and frag_4 reveals.
  3. Collect frag_4; verify MiniFrame slot 3 fills.
- **Common failure cases to avoid:**
  - Checking `_tapped_sequence == expected_order` directly with `==` — this works for Array in GDScript 4 but only if the types match. Use size-by-size element comparison or ensure the Array types match exactly.
  - Not clearing `_tapped_sequence` on wrong input (the reset must be complete).
- **Git commit message:** `feat(ep2): rock water height puzzle (P40)`

---

## Prompt 41 — Mixed Compass Completion and Episode 2 End Card

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P41 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P41 prompt:

- **Prompt ID:** P41
- **Module name:** Mixed Compass Completion and Episode 2 End Card
- **Goal:** When all 4 Mixed Compass fragments are collected, `key_item_completed(&"key.mixed_compass")` fires. Zone 4 plays a short celebration. An Episode 2 end card appears showing a poetic closing line and a "Play Again" button that resets the save and returns to Episode 1, zone 1.
- **Context from previous modules:** `MiniFrame` fires `key_item_completed` when all slots are filled. Phase 1's `MapCompletionTrigger` (P26) is the reference for the celebration pattern. The end card pattern is similar to `PrototypeEndCard` (P28). Zone 4's `.tscn` was created in P34.
- **Files/folders to create or edit:**
  - `res://ui/ep2_end_card.tscn`
  - `res://ui/ep2_end_card.gd`
  - `res://episodes/episode_2/zones/zone_4_rock_face.tscn` — add `Ep2CompletionLayer` (CanvasLayer) and `Ep2EndCard` instance; add a `CompletionTrigger` node.
- **Scene/node structure:**

  `ep2_end_card.tscn`:
  ```
  [Control "Ep2EndCard"]              ← script: ep2_end_card.gd; anchors: full rect
    [ColorRect "Background"]          ← dark overlay, alpha 0.85
    [VBoxContainer "Content"]
      [Label "OrangeLine"]            ← "RUUU!" (fictional speech)
      [Label "EnglishLine"]           ← "The compass is ready. The river awaits.\n\nTo be continued."
      [Button "PlayAgainButton"]      ← text: "Play Again"
    [ConfirmPanel "ConfirmPanel"]     ← shown only when PlayAgain is pressed; same yes/no pattern as PrototypeEndCard
      [Label "ConfirmLabel"]          ← "Erase save and play again?"
      [HBoxContainer "Buttons"]
        [Button "YesButton"]
        [Button "NoButton"]
  ```

  In `zone_4_rock_face.tscn`, add:
  ```
  [Node "CompletionTrigger"]          ← script: a simple Node that listens to key_item_completed
  [CanvasLayer "Ep2CompletionLayer"]  ← layer = 64
    [Ep2EndCard]                      ← instance of ep2_end_card.tscn; initially hidden
  ```

- **GDScript requirements:**

  `class_name Ep2EndCard extends Control`

  `_ready()`: hide self. Connect to `EventBus.key_item_completed`.

  On `key_item_completed(key_item_id)`:
  - If `key_item_id != &"key.mixed_compass"`: return.
  - Show self (fade in via `Tween`).
  - `EventBus.dialogue_requested.emit(&"ep2.compass_completed")`.

  `PlayAgainButton.pressed` → show `ConfirmPanel`.
  `YesButton.pressed` → `SaveSystem.wipe()`; `GameState.reset()`; `EventBus.zone_change_requested.emit(EpisodeController.zone_path_for_id(&"ep1.zone_1"))`.
  `NoButton.pressed` → hide `ConfirmPanel`.

  `CompletionTrigger` node (inline script on the Node in zone_4):
  - In `_ready()`: connect to `EventBus.key_item_completed`.
  - On `key_item_completed(&"key.mixed_compass")`: pause input briefly (2 seconds); call `EventBus.dialogue_requested.emit(&"ep2.compass_completed")` (the end card also does this, so either the CompletionTrigger or the Ep2EndCard does it — pick one to avoid duplicates).

  Simplest pattern: `CompletionTrigger` just blocks input for 1.5 seconds (to let the MiniFrame animation play), then the Ep2EndCard shows itself on `key_item_completed` independently.

- **Data/resource requirements:** `SaveSystem` must expose a `wipe()` method (check if P19 added it; if not, add it as a thin wrapper that deletes `user://save.json` and calls `GameState.reset()`).
- **UI requirements:**
  - End card must be on a `CanvasLayer` (layer 64) so it renders above gameplay.
  - End card must be hidden on scene load. Only appear after `key_item_completed`.
- **Save/load requirements:**
  - "Play Again" wipes the save file (with confirmation) and transitions to Episode 1, zone 1.
  - Completing the compass fires a final save before the end card appears (this happens automatically: fragment collection triggers save, and `key_item_completed` fires after the last fragment is collected).
- **Integration requirements:**
  - The end card must not appear during Episode 1 or the bridge zone.
  - `Ep2EndCard._ready()` must connect to `EventBus.key_item_completed` — not to `key_item_used` (that is the bridge's event).
- **Acceptance criteria:**
  - After collecting frag_4 and collecting the fragment pickup, `key_item_completed(&"key.mixed_compass")` fires.
  - The Ep2EndCard fades in with the Orange line and the English ending.
  - Pressing "Play Again" shows the confirm panel.
  - Pressing "Yes" wipes the save and lands on Episode 1, zone 1 with a fresh state.
  - Pressing "No" hides the confirm panel and keeps the end card visible.
- **Manual test steps:**
  1. Force-grant 3 compass fragments via `GameState`; collect the 4th via normal gameplay; collect the fragment pickup. Verify end card appears.
  2. Press "Play Again" → "Yes". Verify zone 1 loads and save is fresh (MiniFrame empty).
  3. Press "Play Again" → "No". Verify end card stays up.
- **Common failure cases to avoid:**
  - `Ep2EndCard` appearing in Episode 1 zones (guard: only react to `&"key.mixed_compass"`).
  - `SaveSystem.wipe()` crashing if the save file does not exist (use `FileAccess.file_exists` guard).
  - Duplicate dialogue line (only one of CompletionTrigger or Ep2EndCard should emit `ep2.compass_completed`).
- **Git commit message:** `feat(ep2): mixed compass completion and Episode 2 end card (P41)`

---

## Prompt 42 — Episode 2 Integration Pass

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md (Phase 1)
- phase2_prompts.md (this document, sections 1–9)
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the P42 prompt pasted below.

Do not implement future prompts.
Do not change architecture, autoload names, signal names, folder structure, or ids.
Do not edit files outside the prompt scope unless required, and explain why.
Use Godot 4.x + GDScript only.
Keep the implementation minimal, modular, and testable.

At the end, report:
- files created/edited
- what changed
- manual test steps
- acceptance criteria status
- suggested git commit message

P42 prompt:

- **Prompt ID:** P42
- **Module name:** Episode 2 Integration Pass
- **Goal:** Walk through the entire prototype end-to-end on a fresh save — Episode 1 through the bridge through Episode 2 through the Mixed Compass ending — and fix any rough edges found. No new systems; targeted fixes only.
- **Context from previous modules:** All P31–P41 complete.
- **Files/folders to create or edit:** Possibly small fixes only — no new systems or scenes.
- **Scene/node structure:** No new scenes.
- **GDScript requirements:** Targeted fixes only. Document every fix in the commit message body.
- **Data/resource requirements:** Final tone check: all Episode 2 dialogue lines must be short, poetic, and consistent with Episode 1 tone (cozy, curious, hopeful). Adjust wording only, never add new keys.
- **UI requirements:**
  - Confirm HUD scales correctly at 1280×720 and 844×390 in all four Episode 2 zones.
  - Confirm MiniFrame fills in correct slot order (0, 1, 2, 3).
  - Confirm HintButton is active only during an active puzzle.
- **Save/load requirements:**
  - Confirm save fires after each of the 4 compass fragment collections.
  - Confirm reloading mid-Episode-2 restores the correct zone, correct MiniFrame state, and correct puzzle completion state.
- **Integration requirements:**
  - Run a full fresh-save playthrough: Episode 1 zone 1 → zone 4 → bridge → Episode 2 zone 1 → zone 4 → Mixed Compass end card.
  - Confirm Episode 1 puzzles are unaffected by Phase 2 changes.
  - Confirm the bridge zone transitions correctly (no prototype end card).
  - Confirm Episode 2 zone exits work (zone 1→2→3→4).
- **Acceptance criteria:**
  - Full playthrough completes without errors on desktop.
  - Full playthrough completes on mobile-landscape simulation (or touch emulation).
  - MiniFrame fills four times (one per zone).
  - Compass completion end card appears and Play Again works.
  - No console errors or missing label warnings.
  - Saving and reloading at every fragment restores progress exactly.
- **Manual test steps:**
  1. Delete `user://save.json`.
  2. Run from Episode 1, zone 1 through to the Episode 2 end card.
  3. On mobile/touch simulation, repeat steps 1–2.
  4. Midpoint reload test: complete zone 1 and 2 puzzles; close; reopen; confirm zone 2 is restored with both slots filled.
- **Common failure cases to avoid:**
  - Adding new content or systems during the polish pass.
  - Renaming established files or signals.
  - Modifying Phase 1 puzzle logic to fix Episode 2 behavior.
- **Git commit message:** `chore: Episode 2 integration pass (P42)`

---

## Closing Notes

- After P42, Episode 2 is feature-complete for the *Orange* prototype.
- The full prototype covers: Episode 1 (Rain-Found Forest) → Episode 2 bridge (Sunlit Map Activation) → Episode 2 (Sunlit Waterfall) → Mixed Compass completion.
- Any further work — Episode 3 (River to the Ancient Tree), the Teleportation Door — is out of scope for this prompt set.
- Before sharing a build with playtesters, run `phase2_testprompt.md` end-to-end with Claude Opus.

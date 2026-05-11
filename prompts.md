# Orange — Implementation Prompts

This document is the canonical, ordered set of implementation prompts for building the first playable prototype of *Orange*. It is designed so a single solo developer can hand each prompt, one at a time, to a smaller coding agent (Claude Sonnet, Gemini, ChatGPT, etc.) and receive a self-contained module that integrates with all previous and future modules.

---

## 1. Project Summary

*Orange* is a 2D isometric cozy pixel-art puzzle adventure built in **Godot 4.x** with **GDScript**, targeting **responsive web** as its first platform. The protagonist is **Orange**, a curly orange-haired girl who explores a forest where rain, sunlight, water, wind, and roots form the language of the puzzles.

**Forest arc structure (reference only — full arc is documented in the Creative report):**

- **Episode 1: Rain-Found Forest** → reward: Secret Map Card (curiosity).
- **Episode 2: Sunlit Waterfall** → reward: Mixed Compass (hope).
- **Episode 3: River to the Ancient Tree** → reward: Teleportation Door (trust).

**First prototype scope (everything in this document):**

Episode 1 in full + the Episode 2 sunlight activation bridge that proves the Secret Map Card matters.

**Core loop the prototype must prove:**

Explore → notice nature data → solve puzzle → collect illustration fragment → complete key item → use key item in the next episode.

---

## 2. Global Development Rules

1. **One task, one module, one test, one commit.** Never bundle modules.
2. **Godot 4.x only.** Use Godot 4 APIs (`@onready`, typed signals, `Node2D`/`Node3D`-aware classes). Never use Godot 3 syntax.
3. **GDScript only.** Do not use C#.
4. **Touch-first design.** Every interaction must work with a single tap and also with a mouse click.
5. **Landscape-first responsive web.** Assume aspect ratios from 16:9 desktop down to 19.5:9 mobile landscape.
6. **No new systems unless this document says so.** Smaller agents must not invent inventory tabs, dialog trees, quest logs, settings menus, etc.
7. **Visual clarity beats decoration.** Puzzle clues must be readable; backgrounds must not compete with them.
8. **Sound supports, never gates.** No puzzle can be solvable only by sound. Visual clues must always exist.
9. **One-level hint only.** No tiered hint trees.
10. **Save after every fragment collection.** No mid-puzzle saves, no auto-save loops.
11. **Modularity over cleverness.** Every system is reachable as an autoload, a scene, or a resource — not as a buried script reference.
12. **Smaller agents may NOT change architecture.** Architectural decisions (autoloads, signal contracts, folder layout, naming) are fixed by this document.
13. **Smaller agents may NOT alter previously delivered modules** unless a prompt explicitly says so.
14. **Pixel art is the base. Lighting is the emotion.** Effects must support, never replace, pixel sprites.
15. **No unrequested polish.** No particle storms, no shaders, no menus, no animations beyond what a prompt names.

---

## 3. Naming Conventions

- **Folders:** `snake_case` (e.g. `puzzle_framework/`, `episode_1/`).
- **Scenes:** `snake_case.tscn` (e.g. `orange_character.tscn`).
- **Scripts:** `snake_case.gd` matching the scene name where applicable (e.g. `orange_character.gd`).
- **Classes (`class_name`):** `PascalCase` (e.g. `OrangeCharacter`, `PuzzleBase`, `FragmentReward`).
- **Resources (`.tres`):** `snake_case.tres` (e.g. `puzzle_mushroom_path.tres`).
- **Autoload singletons:** `PascalCase` names (e.g. `GameState`, `SaveSystem`, `EpisodeController`, `EventBus`).
- **Signals:** `snake_case`, past-tense or event-shaped (`puzzle_solved`, `fragment_collected`, `key_item_completed`).
- **Constants:** `UPPER_SNAKE_CASE` inside scripts; grouped in `constants.gd` for global use.
- **JSON keys:** `snake_case`.
- **Action names (`InputMap`):** `ui_tap`, `ui_back`, etc. — only add what is needed.

---

## 4. Suggested Folder Structure

```
res://
├── project.godot
├── globals/
│   ├── constants.gd
│   ├── event_bus.gd
│   ├── game_state.gd
│   ├── save_system.gd
│   └── episode_controller.gd
├── characters/
│   └── orange/
│       ├── orange_character.tscn
│       └── orange_character.gd
├── camera/
│   ├── follow_camera.tscn
│   └── follow_camera.gd
├── interaction/
│   ├── interactable.gd
│   ├── interactable_area.tscn
│   ├── interaction_manager.gd
│   └── walkable_area.gd
├── ui/
│   ├── hud.tscn
│   ├── hud.gd
│   ├── action_button.tscn
│   ├── action_button.gd
│   ├── dialogue_box.tscn
│   ├── dialogue_box.gd
│   ├── floating_label.tscn
│   ├── floating_label.gd
│   ├── hint_button.tscn
│   ├── hint_button.gd
│   ├── mini_frame.tscn
│   └── mini_frame.gd
├── puzzles/
│   ├── puzzle_base.gd
│   ├── puzzle_definition.gd        # Resource
│   └── fragment_reward.gd          # Resource
├── fragments/
│   ├── fragment_pickup.tscn
│   └── fragment_pickup.gd
├── key_items/
│   ├── key_item.gd                 # Resource
│   ├── key_item_inventory.gd       # Autoload-friendly
│   ├── secret_map_card.tres
│   └── mixed_compass.tres
├── data/
│   ├── dialogue/
│   │   ├── episode_1.json
│   │   └── episode_2_bridge.json
│   ├── hints/
│   │   ├── episode_1.json
│   │   └── episode_2_bridge.json
│   └── floating_labels/
│       └── episode_1.json
├── episodes/
│   ├── episode_1/
│   │   ├── zones/
│   │   │   ├── zone_1_forest_entry.tscn
│   │   │   ├── zone_2_mushroom_grove.tscn
│   │   │   ├── zone_3_muddy_path.tscn
│   │   │   └── zone_4_bark_clearing.tscn
│   │   ├── puzzles/
│   │   │   ├── mushroom_path/
│   │   │   ├── animal_tracks/
│   │   │   ├── raindrop_rhythm/
│   │   │   └── wet_bark_symbol/
│   │   ├── fragments/
│   │   └── definitions/
│   │       ├── puzzle_mushroom_path.tres
│   │       ├── puzzle_animal_tracks.tres
│   │       ├── puzzle_raindrop_rhythm.tres
│   │       └── puzzle_wet_bark.tres
│   └── episode_2_bridge/
│       ├── zones/
│       │   └── zone_sunlit_clearing.tscn
│       ├── puzzles/
│       │   └── sunlit_map_activation/
│       └── definitions/
│           └── puzzle_sunlit_map.tres
├── transitions/
│   ├── soft_transition.tscn
│   └── soft_transition.gd
├── art/                            # Imported Aseprite sprites & tiles
├── audio/
└── tests/                          # Optional manual test scenes
```

This layout is **fixed**. Smaller agents must place files according to it.

---

## 5. Shared Architecture Assumptions

These contracts are guaranteed by this document. Any prompt below may rely on them.

### 5.1 Autoload Singletons (registered in `project.godot`)

| Name | Script | Responsibility |
|------|--------|----------------|
| `Constants` | `globals/constants.gd` | Static enums, ids, config keys. |
| `EventBus` | `globals/event_bus.gd` | Global signals only — no logic. |
| `GameState` | `globals/game_state.gd` | Runtime state: current episode, current zone, completed puzzles, collected fragments, owned key items. |
| `SaveSystem` | `globals/save_system.gd` | Reads and writes `user://save.json`. |
| `EpisodeController` | `globals/episode_controller.gd` | Knows which episode/zone is active and triggers bridges/transitions. |
| `KeyItemInventory` | `key_items/key_item_inventory.gd` | Owns the very small fixed key item set. |

### 5.2 Global Signals (defined on `EventBus`)

```
signal puzzle_started(puzzle_id: StringName)
signal puzzle_solved(puzzle_id: StringName)
signal fragment_revealed(puzzle_id: StringName, fragment_id: StringName)
signal fragment_collected(fragment_id: StringName, key_item_id: StringName)
signal key_item_completed(key_item_id: StringName)
signal key_item_used(key_item_id: StringName, context: StringName)
signal dialogue_requested(line_id: StringName)
signal hint_requested()
signal zone_change_requested(zone_path: String)
signal save_requested(reason: StringName)
```

No system may invent new global signals without an explicit prompt.

### 5.3 Identifier Conventions

- `puzzle_id`: `&"ep1.mushroom_path"`, `&"ep1.animal_tracks"`, `&"ep1.raindrop_rhythm"`, `&"ep1.wet_bark_symbol"`, `&"ep2bridge.sunlit_map"`.
- `fragment_id`: `&"ep1.map.frag_1"` … `&"ep1.map.frag_4"` (Episode 1 fragments belong to the Secret Map Card).
- `key_item_id`: `&"key.secret_map_card"`, `&"key.mixed_compass"`.
- `zone_id`: `&"ep1.zone_1"` … `&"ep1.zone_4"`, `&"ep2bridge.zone_sunlit_clearing"`.

### 5.4 Save File Shape

`user://save.json`:

```json
{
  "version": 1,
  "current_episode": "ep1",
  "current_zone": "ep1.zone_1",
  "completed_puzzles": ["ep1.mushroom_path"],
  "collected_fragments": ["ep1.map.frag_1"],
  "owned_key_items": [],
  "completed_key_items": [],
  "flags": {}
}
```

### 5.5 Coordinate & Camera Conventions

- World uses `Node2D` with isometric tile alignment via `TileMap` in isometric mode.
- The follow camera is a child of the active zone scene and targets `OrangeCharacter`.
- All UI lives on a `CanvasLayer` named `HUD` above gameplay.

---

## 6. Git Workflow

- **One task, one commit.** Each prompt below ends with a suggested commit message.
- Branch model: `main` only is acceptable for the prototype, but each commit must be atomic and reversible.
- Never amend a prior commit; always add a new one.
- Never `git push --force` to `main`.
- The smaller agent must not modify `.gitignore` unless a prompt asks.

---

## 7. How To Use These Prompts With Coding Agents

1. **Pick the next prompt in order.** Do not skip; later prompts assume earlier ones.
2. **Paste the entire prompt block** (from `Prompt ID` through `Git commit message`) into the smaller agent.
3. **Also paste sections 1–6 above** the first time you use a new agent session. After that, you can reference them as "the project rules document".
4. **After the agent finishes**, manually run the listed test steps. If they pass, commit using the suggested message. If they fail, return the failure to the agent verbatim.
5. **Never let a smaller agent decide architecture.** If it asks "should I add system X?", the answer is "no, follow the prompt".
6. **Never let two prompts run in parallel.** They share contracts and will collide.
7. After all prompts are done, run `testprompt.md` against the repo with Claude Opus.

---

# Implementation Prompts

> Order rationale: prompts 1–6 stand up the engine, project, and Orange. Prompts 7–10 build the world & input frame. Prompts 11–13 layer narrative UI. Prompt 14 fixes the data formats *before* puzzles start consuming them. Prompts 15–19 build the reusable puzzle/reward/save spine. Prompt 20 wires the episode flow. Prompts 21–26 deliver Episode 1 content using the spine. Prompts 27–28 build the Episode 2 bridge and transition. Prompts 29–30 finish web export and integration.

---

## Prompt 01 — Base Godot 4.x Project Setup

- **Prompt ID:** P01
- **Module name:** Base Godot Project
- **Goal:** Create a clean Godot 4.x project configured for landscape-first responsive web with pixel-art rendering.
- **Context from previous modules:** None. This is the first task.
- **Files/folders to create or edit:**
  - `project.godot`
  - `icon.svg` (placeholder allowed)
  - `.gitignore` (Godot defaults)
  - `README.md` (one paragraph description)
- **Scene/node structure:** None.
- **GDScript requirements:** None yet.
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:**
  - Project name: `Orange`.
  - Renderer: `Compatibility` (for web export).
  - Default window: `1280×720`, stretch mode `viewport`, aspect `keep`.
  - Pixel snap and `texture_filter` default = `Nearest`.
  - Set base orientation: landscape.
- **Acceptance criteria:**
  - Project opens in Godot 4.x without errors.
  - Empty main scene runs and shows a black `1280×720` window.
  - `.gitignore` excludes `.godot/`, `.import/`, `*.translation`, `export.cfg`, `export_presets.cfg`, `builds/`.
- **Manual test steps:**
  1. Open the project in Godot 4.x.
  2. Press F5; pick any empty scene as main; confirm it runs without errors.
  3. Resize the window; confirm aspect is preserved.
- **Common failure cases to avoid:**
  - Choosing the Forward+ renderer (will not run cleanly on web).
  - Using linear texture filtering (will blur pixel art).
- **Git commit message:** `chore: initialize Godot 4.x project for Orange (P01)`

---

## Prompt 02 — Folder Structure and Naming Conventions

- **Prompt ID:** P02
- **Module name:** Folder Skeleton
- **Goal:** Create the full folder skeleton from section 4 of the project rules so all later prompts have a stable home.
- **Context from previous modules:** P01 created the project.
- **Files/folders to create or edit:** Create every folder listed in section 4 (Suggested Folder Structure). Add an empty `.gdkeep` file inside each empty folder so Git tracks it.
- **Scene/node structure:** None.
- **GDScript requirements:** None.
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:** Folder names must match section 4 exactly. Do not invent new folders.
- **Acceptance criteria:**
  - `res://globals/`, `res://characters/orange/`, `res://camera/`, `res://interaction/`, `res://ui/`, `res://puzzles/`, `res://fragments/`, `res://key_items/`, `res://data/dialogue/`, `res://data/hints/`, `res://data/floating_labels/`, `res://episodes/episode_1/zones/`, `res://episodes/episode_1/puzzles/`, `res://episodes/episode_1/fragments/`, `res://episodes/episode_1/definitions/`, `res://episodes/episode_2_bridge/zones/`, `res://episodes/episode_2_bridge/puzzles/`, `res://episodes/episode_2_bridge/definitions/`, `res://transitions/`, `res://art/`, `res://audio/`, `res://tests/` all exist.
- **Manual test steps:**
  1. Open Godot's FileSystem dock.
  2. Confirm every folder listed appears.
- **Common failure cases to avoid:**
  - Using `PascalCase` or `kebab-case` folders.
  - Creating extra "common", "misc", or "utils" folders.
- **Git commit message:** `chore: scaffold project folder structure (P02)`

---

## Prompt 03 — Global Project Constants and Autoload Plan

- **Prompt ID:** P03
- **Module name:** Globals & Autoloads
- **Goal:** Create the autoload singletons named in section 5.1 with empty-but-valid implementations and the global signal list from section 5.2.
- **Context from previous modules:** P02 created `res://globals/`.
- **Files/folders to create or edit:**
  - `res://globals/constants.gd`
  - `res://globals/event_bus.gd`
  - `res://globals/game_state.gd`
  - `res://globals/save_system.gd` (stub OK)
  - `res://globals/episode_controller.gd` (stub OK)
  - Update `project.godot` autoload list.
- **Scene/node structure:** None — pure scripts.
- **GDScript requirements:**
  - All scripts `extends Node` and use `class_name` matching their autoload name.
  - `constants.gd`: declare puzzle ids, fragment ids, key item ids, zone ids as `const StringName`s exactly as listed in section 5.3.
  - `event_bus.gd`: declare every signal listed in section 5.2 with the exact signatures.
  - `game_state.gd`: hold `current_episode: StringName`, `current_zone: StringName`, `completed_puzzles: Array[StringName]`, `collected_fragments: Array[StringName]`, `owned_key_items: Array[StringName]`, `completed_key_items: Array[StringName]`, plus typed getters/setters and a `reset()` method.
  - `save_system.gd` and `episode_controller.gd`: empty stubs with TODO comments — they will be filled in P19 and P20.
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None yet.
- **Integration requirements:**
  - Autoload order: `Constants`, `EventBus`, `GameState`, `SaveSystem`, `EpisodeController`, then later `KeyItemInventory` (added in P18).
  - Do not import these scripts manually — rely on autoload names.
- **Acceptance criteria:**
  - Project runs with autoloads enabled and zero parser errors.
  - `print(EventBus.has_signal("puzzle_solved"))` prints `true`.
  - `print(GameState.completed_puzzles.size())` prints `0`.
- **Manual test steps:**
  1. Add a temporary `Node` scene with a script that prints the values above on `_ready`.
  2. Run; confirm both prints; remove the temp scene.
- **Common failure cases to avoid:**
  - Putting logic inside `EventBus`. It must hold only signals.
  - Auto-saving from inside `GameState`.
- **Git commit message:** `feat(globals): add constants, event bus, and core autoloads (P03)`

---

## Prompt 04 — Orange Character Scene

- **Prompt ID:** P04
- **Module name:** Orange Character
- **Goal:** Create the Orange character scene with placeholder sprite, idle animation, and a clean public API for movement.
- **Context from previous modules:** Globals exist. No movement yet.
- **Files/folders to create or edit:**
  - `res://characters/orange/orange_character.tscn`
  - `res://characters/orange/orange_character.gd`
  - Optional placeholder PNG in `res://art/orange/` (a 32×48 magenta block is fine).
- **Scene/node structure:**
  ```
  OrangeCharacter (CharacterBody2D)
  ├── Sprite2D
  ├── CollisionShape2D (small ellipse near feet)
  └── AnimationPlayer (idle anim with subtle bob)
  ```
- **GDScript requirements:**
  - `class_name OrangeCharacter extends CharacterBody2D`.
  - Public `walk_speed: float = 90.0` (export).
  - Public `move_to(target: Vector2)` method that stores a target.
  - Public `is_moving: bool` getter.
  - Internal `_physics_process` that moves toward `_target` and stops within `2.0` px.
  - Emits a local signal `arrived_at_target`.
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:** Must not depend on cameras, zones, or input — only respond to `move_to`.
- **Acceptance criteria:**
  - Adding `OrangeCharacter` to a blank scene and calling `move_to(Vector2(200,100))` makes her walk and stop, then emit `arrived_at_target`.
  - Idle animation loops.
- **Manual test steps:**
  1. Add `OrangeCharacter` to a temporary test scene at `res://tests/test_orange.tscn`.
  2. Add a script that calls `move_to(Vector2(200,100))` after 1s and prints on arrival.
  3. Run and verify motion and signal.
- **Common failure cases to avoid:**
  - Using `_process` instead of `_physics_process` for movement.
  - Hardcoding sprite dimensions in scripts.
- **Git commit message:** `feat(character): add Orange character scene with move_to API (P04)`

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

## Prompt 05 — Free Tap/Click Movement

- **Prompt ID:** P05
- **Module name:** Tap/Click Movement
- **Goal:** Make the player tap or click anywhere on a walkable area to move Orange to that point.
- **Context from previous modules:** P04 provides `OrangeCharacter.move_to`.
- **Files/folders to create or edit:**
  - `res://interaction/walkable_area.gd`
  - `res://tests/test_movement.tscn`
- **Scene/node structure:** `WalkableArea` is an `Area2D` with a `CollisionShape2D` defining the walkable polygon for a zone.
- **GDScript requirements:**
  - `class_name WalkableArea extends Area2D`.
  - Holds an exported `NodePath` to the Orange character.
  - On `_unhandled_input`, listens for `InputEventScreenTouch` (pressed) and `InputEventMouseButton` (left, pressed).
  - Converts the event position to world coordinates via the active camera and calls `OrangeCharacter.move_to`.
  - Ignores taps that fall outside its own collision shape.
- **Data/resource requirements:** None.
- **UI requirements:** None — but the script must respect `Input.is_action_pressed` so HUD buttons can consume events first (later modules may add `accept_event()`).
- **Save/load requirements:** None.
- **Integration requirements:** Must not move Orange if a UI element handled the event. Use `set_input_as_handled()` after issuing a move.
- **Acceptance criteria:**
  - Clicking inside the walkable area moves Orange there.
  - Clicking outside it does nothing.
  - Works with both mouse click and touch events.
- **Manual test steps:**
  1. Open `test_movement.tscn`.
  2. Click various points; confirm motion.
  3. Click outside the area; confirm no motion.
- **Common failure cases to avoid:**
  - Reading `event.position` directly without camera transform.
  - Forgetting to handle touch events for web/mobile.
- **Git commit message:** `feat(interaction): add tap/click walkable movement (P05)`

---

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

## Prompt 06 — Camera Follow System

- **Prompt ID:** P06
- **Module name:** Follow Camera
- **Goal:** Provide a smooth follow camera for isometric zones.
- **Context from previous modules:** Orange and tap movement exist.
- **Files/folders to create or edit:**
  - `res://camera/follow_camera.tscn`
  - `res://camera/follow_camera.gd`
- **Scene/node structure:** `FollowCamera (Camera2D)` with `enabled = true`, `position_smoothing_enabled = true`, smoothing speed `5.0`.
- **GDScript requirements:**
  - `class_name FollowCamera extends Camera2D`.
  - Exported `target_path: NodePath`.
  - In `_process`, set `global_position` toward target's `global_position`.
  - Optional exported `bounds: Rect2` to clamp.
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:** Must be addable as a child of any zone scene without coupling.
- **Acceptance criteria:**
  - Camera smoothly follows Orange.
  - Camera respects bounds when set.
- **Manual test steps:**
  1. Add `FollowCamera` as a child of `test_movement.tscn` and assign Orange as target.
  2. Move Orange around; verify smooth follow.
- **Common failure cases to avoid:**
  - Forgetting `current = true` (Godot 4 uses the `Camera2D` `enabled`/`current` semantics — confirm correct one).
  - Snapping abruptly because of zero smoothing speed.
- **Git commit message:** `feat(camera): add smooth follow camera (P06)`

---
---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

## Prompt 07 — Zone Scene Prototype

- **Prompt ID:** P07
- **Module name:** Zone Scene Template
- **Goal:** Define the standard structure of a zone scene that Orange, the camera, walkable area, and interactables share.
- **Context from previous modules:** P04–P06 ready.
- **Files/folders to create or edit:**
  - `res://episodes/episode_1/zones/zone_1_forest_entry.tscn`
  - Optional placeholder isometric tilemap or background image.
- **Scene/node structure:**
  ```
  Zone1ForestEntry (Node2D)
  ├── Background (TileMap or Sprite2D placeholder)
  ├── WalkableArea (Area2D)
  ├── Interactables (Node2D)
  ├── OrangeCharacter (instanced)
  └── FollowCamera (instanced, target = OrangeCharacter)
  ```
- **GDScript requirements:** Optional `zone.gd` with `class_name Zone extends Node2D` exposing `zone_id: StringName` (export). On `_ready`, set `GameState.current_zone = zone_id`.
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** Setting `current_zone` only — actual save happens later.
- **Integration requirements:** All later zones must follow this template exactly.
- **Acceptance criteria:**
  - Zone scene runs standalone.
  - Orange spawns; camera follows; tap-to-move works.
  - `GameState.current_zone == &"ep1.zone_1"` while running.
- **Manual test steps:**
  1. Run `zone_1_forest_entry.tscn`.
  2. Verify movement and camera.
  3. Verify `GameState.current_zone` via a temporary print.
- **Common failure cases to avoid:**
  - Hardcoding camera or character paths inside zone logic.
- **Git commit message:** `feat(zones): add zone scene template and Episode 1 zone 1 (P07)`

---

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

## Prompt 08 — Walkable Area and Interaction Target Basics

- **Prompt ID:** P08
- **Module name:** Interactable Foundation
- **Goal:** Provide a reusable `Interactable` node so any object in any zone can be tapped/clicked to trigger context-specific behavior later.
- **Context from previous modules:** Movement & zones exist.
- **Files/folders to create or edit:**
  - `res://interaction/interactable.gd`
  - `res://interaction/interactable_area.tscn`
- **Scene/node structure:** `InteractableArea (Area2D)` with a `CollisionShape2D` and an optional `Sprite2D`.
- **GDScript requirements:**
  - `class_name Interactable extends Area2D`.
  - Exported `interactable_id: StringName`, `display_label: String`, `action_label: String` (e.g. "Inspect", "Rotate"), `interaction_position: Vector2` (where Orange should stand).
  - Exposes signal `interaction_triggered(interactable: Interactable)`.
  - Exposes method `request_interaction(orange: OrangeCharacter)` that:
    1. Calls `orange.move_to(global_position + interaction_position)`.
    2. Awaits `orange.arrived_at_target`.
    3. Emits `interaction_triggered`.
- **Data/resource requirements:** None.
- **UI requirements:** None yet.
- **Save/load requirements:** None.
- **Integration requirements:** Must not assume an `InteractionManager` exists yet — it just emits signals.
- **Acceptance criteria:**
  - Adding two `Interactable`s to a zone and calling `request_interaction` walks Orange to each correctly and fires the signal.
- **Manual test steps:**
  1. Place two `Interactable` nodes in zone 1.
  2. Connect `interaction_triggered` to a temporary `print`.
  3. Tap each via a temp script; verify movement and signals.
- **Common failure cases to avoid:**
  - Using global signals here (use the local node signal — global flow is in P09).
- **Git commit message:** `feat(interaction): add Interactable base node (P08)`

---

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

## Prompt 09 — Contextual One-Button Interaction System

- **Prompt ID:** P09
- **Module name:** Interaction Manager + Action Button
- **Goal:** When the player taps an `Interactable`, walk Orange there, show a single contextual action button, and dispatch the action when pressed.
- **Context from previous modules:** P08 provides `Interactable`. P05 handles general taps.
- **Files/folders to create or edit:**
  - `res://interaction/interaction_manager.gd`
  - `res://ui/action_button.tscn`
  - `res://ui/action_button.gd`
- **Scene/node structure:** `ActionButton (Control)` containing a `TextureButton` and a `Label`.
- **GDScript requirements:**
  - `InteractionManager` is a node (not autoload) placed in the zone or HUD that:
    1. Connects to all `Interactable` nodes in the current scene.
    2. Listens for tap input on `Interactable` collisions.
    3. On tap, calls `request_interaction`, awaits arrival, then shows the `ActionButton` with `action_label`.
    4. On button press, emits `EventBus.puzzle_started(interactable.interactable_id)` if the interactable maps to a puzzle, or directly emits a custom local signal otherwise.
  - `ActionButton.show_for(interactable: Interactable)` and `hide_button()` methods.
- **Data/resource requirements:** None.
- **UI requirements:**
  - One button only.
  - Large, touch-friendly (min 64×64 px).
  - Anchored bottom-center of the `HUD` `CanvasLayer` (HUD comes from P10; design the API so the action button can be added to it in P10).
- **Save/load requirements:** None.
- **Integration requirements:** Must consume the input event so `WalkableArea` does not double-handle it.
- **Acceptance criteria:**
  - Tapping an interactable walks Orange there and shows the action button.
  - Tapping elsewhere hides the action button.
  - Pressing the button fires the appropriate signal.
- **Manual test steps:**
  1. In zone 1, place an `Interactable` with `action_label = "Inspect"`.
  2. Tap it; confirm Orange walks and button appears.
  3. Tap button; confirm signal fires (use a temp print).
- **Common failure cases to avoid:**
  - Multiple action buttons stacking when tapping rapidly.
  - Button surviving across zone transitions.
- **Git commit message:** `feat(interaction): add contextual one-button interaction (P09)`

---

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

## Prompt 10 — Minimal Cozy UI Layer

- **Prompt ID:** P10
- **Module name:** HUD Skeleton
- **Goal:** Provide a single `HUD` `CanvasLayer` scene that hosts the action button (P09), dialogue box (P11), floating labels (P12), hint button (P13), and mini picture frame (P17).
- **Context from previous modules:** Interaction system needs a host.
- **Files/folders to create or edit:**
  - `res://ui/hud.tscn`
  - `res://ui/hud.gd`
- **Scene/node structure:**
  ```
  HUD (CanvasLayer, layer = 10)
  ├── Bottom (Control, anchor bottom-stretch)
  │   ├── DialogueBoxSlot
  │   └── ActionButtonSlot
  ├── TopRight (Control)
  │   └── HintButtonSlot
  ├── TopLeft (Control)
  │   └── MiniFrameSlot
  └── FloatingLabels (Control, full-rect)
  ```
- **GDScript requirements:**
  - `class_name Hud extends CanvasLayer`.
  - Public methods: `mount_action_button(node)`, `mount_dialogue_box(node)`, `mount_hint_button(node)`, `mount_mini_frame(node)`, `add_floating_label(node)`.
- **Data/resource requirements:** None.
- **UI requirements:**
  - Empty pixel-cozy style. No backgrounds; slots are transparent until populated.
  - Landscape-first layout that scales with viewport.
- **Save/load requirements:** None.
- **Integration requirements:** Each zone scene must include exactly one instance of `HUD`. Update the zone template (P07) to include it.
- **Acceptance criteria:**
  - Zone 1 runs and shows an empty HUD.
  - The action button from P09 mounts inside `ActionButtonSlot` cleanly.
- **Manual test steps:**
  1. Open zone 1 with HUD instanced.
  2. Trigger an interaction; confirm action button shows in the right slot.
- **Common failure cases to avoid:**
  - Putting gameplay logic in HUD; it is a host only.
- **Git commit message:** `feat(ui): add minimal cozy HUD skeleton (P10)`

---

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

## Prompt 11 — Dialogue System: Fictional Orange Language + English Bottom Text

- **Prompt ID:** P11
- **Module name:** Dialogue Box
- **Goal:** Show Orange's fictional speech (e.g. "Mimi ruu?") and an English translation in a small bottom text box.
- **Context from previous modules:** HUD ready; data folder ready.
- **Files/folders to create or edit:**
  - `res://ui/dialogue_box.tscn`
  - `res://ui/dialogue_box.gd`
  - `res://data/dialogue/episode_1.json` (seed with 4–6 lines)
- **Scene/node structure:** `DialogueBox (PanelContainer)` with `OrangeLine: Label`, `EnglishLine: Label`.
- **GDScript requirements:**
  - `class_name DialogueBox extends PanelContainer`.
  - Loads the appropriate JSON based on `GameState.current_episode`.
  - Method `show_line(line_id: StringName, duration: float = 3.0)` that animates in, displays both lines, then fades out.
  - Subscribes to `EventBus.dialogue_requested(line_id)`.
- **Data/resource requirements:**
  ```json
  {
    "ep1.intro": { "orange": "Mimi ruu?", "english": "The mushrooms are trying to show me something." },
    "ep1.mushroom_solved": { "orange": "...", "english": "..." }
  }
  ```
- **UI requirements:**
  - Bottom-center, max 60% width.
  - Short lines, no scroll.
- **Save/load requirements:** None.
- **Integration requirements:** Mount via `Hud.mount_dialogue_box`.
- **Acceptance criteria:**
  - Calling `EventBus.dialogue_requested.emit(&"ep1.intro")` shows both lines and fades out after `duration`.
  - Missing keys log a warning instead of crashing.
- **Manual test steps:**
  1. Run zone 1.
  2. Trigger the signal via a temp script; confirm display.
- **Common failure cases to avoid:**
  - Long blocking text walls. Lines must be short and poetic.
- **Git commit message:** `feat(ui): add dialogue box with fictional + English lines (P11)`

---

## Prompt 12 — Floating Object Labels
---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P12
- **Module name:** Floating Labels
- **Goal:** Show short floating text near interactable objects on hover/tap (e.g. "Mushroom Cluster").
- **Context from previous modules:** HUD and Interactables ready.
- **Files/folders to create or edit:**
  - `res://ui/floating_label.tscn`
  - `res://ui/floating_label.gd`
  - `res://data/floating_labels/episode_1.json`
- **Scene/node structure:** `FloatingLabel (Control)` with a `Label` and a small fade animation.
- **GDScript requirements:**
  - `class_name FloatingLabel extends Control`.
  - `show_label(text: String, world_pos: Vector2)` converts world to screen via the active `Camera2D` and positions itself above the object.
  - Auto-fades after 1.5s.
- **Data/resource requirements:** JSON map of `interactable_id → label string` for Episode 1.
- **UI requirements:** Small, soft, no panel background.
- **Save/load requirements:** None.
- **Integration requirements:** `Interactable` emits a tap event; `InteractionManager` (or a new small `LabelController`) calls `Hud.add_floating_label`.
- **Acceptance criteria:**
  - Tapping an interactable shows a floating label briefly.
  - Multiple labels do not stack indefinitely.
- **Manual test steps:**
  1. Tap two interactables in zone 1; verify labels appear and fade.
- **Common failure cases to avoid:**
  - Labels stuck on screen because of an unset timer.
- **Git commit message:** `feat(ui): add floating object labels (P12)`

---

## Prompt 13 — One-Level Gentle Hint System
---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P13
- **Module name:** Hint Button
- **Goal:** Provide one soft hint per active puzzle. Pressing the hint button shows a poetic clue, never the solution.
- **Context from previous modules:** HUD, dialogue, interactables ready.
- **Files/folders to create or edit:**
  - `res://ui/hint_button.tscn`
  - `res://ui/hint_button.gd`
  - `res://data/hints/episode_1.json`
  - `res://data/hints/episode_2_bridge.json`
- **Scene/node structure:** `HintButton (TextureButton)` with a small leaf icon.
- **GDScript requirements:**
  - `class_name HintButton extends TextureButton`.
  - On press, emits `EventBus.hint_requested`.
  - Subscribes to `EventBus.puzzle_started` to know which puzzle's hint to load and `puzzle_solved` to disable until next puzzle.
  - Looks up `hint_for(puzzle_id)` from JSON; on `hint_requested`, calls `EventBus.dialogue_requested` with a temporary line built from the hint text (or call a separate `DialogueBox.show_text(text)` method — pick one and stay consistent).
- **Data/resource requirements:** One hint per puzzle id.
- **UI requirements:** Top-right, small, low-contrast when no puzzle active.
- **Save/load requirements:** None.
- **Integration requirements:** Mount via `Hud.mount_hint_button`.
- **Acceptance criteria:**
  - With no active puzzle, the button is visually disabled.
  - With an active puzzle, pressing it shows exactly one gentle hint — never the answer.
- **Manual test steps:**
  1. Start a fake puzzle via `EventBus.puzzle_started.emit(&"ep1.mushroom_path")`.
  2. Press the hint button; confirm hint shows.
  3. Solve via `puzzle_solved`; confirm button greys out.
- **Common failure cases to avoid:**
  - Multi-tier hints. Reject any temptation to add levels.
- **Git commit message:** `feat(ui): add one-level gentle hint button (P13)`

---

## Prompt 14 — Hybrid Data Setup

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P14
- **Module name:** Data Conventions (JSON + Godot Resources)
- **Goal:** Lock the data formats: JSON for narrative text (already used in P11–P13), Godot Resources for gameplay data (puzzles, key items, fragment rewards).
- **Context from previous modules:** P11–P13 introduced JSON. We now add Godot Resources.
- **Files/folders to create or edit:**
  - `res://puzzles/puzzle_definition.gd` (Resource)
  - `res://puzzles/fragment_reward.gd` (Resource)
  - `res://key_items/key_item.gd` (Resource)
  - `res://key_items/secret_map_card.tres`
  - `res://key_items/mixed_compass.tres`
- **Scene/node structure:** None — pure resources.
- **GDScript requirements:**
  - `PuzzleDefinition extends Resource`: `puzzle_id: StringName`, `display_name: String`, `episode_id: StringName`, `fragment_reward: FragmentReward`, `hint_text_key: StringName`, `intro_dialogue_key: StringName`, `solved_dialogue_key: StringName`.
  - `FragmentReward extends Resource`: `fragment_id: StringName`, `key_item_id: StringName`, `frame_slot: int`, `art_path: String`.
  - `KeyItem extends Resource`: `key_item_id: StringName`, `display_name: String`, `total_fragments: int`, `frame_image_path: String`, `description_key: StringName`.
- **Data/resource requirements:**
  - `secret_map_card.tres`: `key_item_id = &"key.secret_map_card"`, `total_fragments = 4`.
  - `mixed_compass.tres`: `key_item_id = &"key.mixed_compass"`, `total_fragments = 4` (used only as a forward-declared placeholder for the bridge).
- **UI requirements:** None.
- **Save/load requirements:** None.
- **Integration requirements:** All puzzles created from P22 onward must use `PuzzleDefinition`.
- **Acceptance criteria:**
  - Both `.tres` files load without errors.
  - `load("res://key_items/secret_map_card.tres")` returns a `KeyItem` with `total_fragments == 4`.
- **Manual test steps:**
  1. Add a temp print loading both `.tres` files; verify properties.
- **Common failure cases to avoid:**
  - Stuffing narrative text into resources. Text stays in JSON.
- **Git commit message:** `feat(data): add puzzle, fragment, and key item resource schemas (P14)`

---

## Prompt 15 — Puzzle Base System

---

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P15
- **Module name:** Puzzle Framework
- **Goal:** Provide `PuzzleBase`, the shared lifecycle every puzzle inherits.
- **Context from previous modules:** Resources exist. EventBus exists.
- **Files/folders to create or edit:**
  - `res://puzzles/puzzle_base.gd`
- **Scene/node structure:** None — `PuzzleBase` is a script. Concrete puzzles will be `Node2D` scenes that `extends PuzzleBase`.
- **GDScript requirements:**
  - `class_name PuzzleBase extends Node2D`.
  - Exported `definition: PuzzleDefinition`.
  - State enum: `INACTIVE`, `ACTIVE`, `SOLVED`.
  - Lifecycle:
    - `start_puzzle()`: sets `ACTIVE`, emits `EventBus.puzzle_started(definition.puzzle_id)`, optionally requests intro dialogue.
    - `_on_solution_attempt()`: virtual; subclasses call `mark_solved()` when valid.
    - `mark_solved()`: sets `SOLVED`, emits `EventBus.puzzle_solved`, then `EventBus.fragment_revealed`, optionally `dialogue_requested(definition.solved_dialogue_key)`.
  - Built-in idempotency: calling `mark_solved` twice is a no-op.
  - Reads `GameState.completed_puzzles` on `_ready` to skip already-solved puzzles.
- **Data/resource requirements:** Uses `PuzzleDefinition`.
- **UI requirements:** None.
- **Save/load requirements:** Marks puzzle ids in `GameState.completed_puzzles` upon `mark_solved`. Does not write to disk — that is the save system's job (P19).
- **Integration requirements:** All Episode 1 puzzles will inherit this.
- **Acceptance criteria:**
  - A trivial subclass that solves on a key press fires `puzzle_started`, `puzzle_solved`, `fragment_revealed` in order.
  - Re-loading the scene with the puzzle already in `completed_puzzles` skips activation.
- **Manual test steps:**
  1. Create a temp `dummy_puzzle.tscn` extending `PuzzleBase`.
  2. Trigger and verify signals; reload scene with state set; verify skip.
- **Common failure cases to avoid:**
  - Coupling `PuzzleBase` to a specific puzzle's logic (e.g. mushrooms).
- **Git commit message:** `feat(puzzle): add PuzzleBase lifecycle (P15)`

---

## Prompt 16 — Manual Illustration Fragment Collection System

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P16
- **Module name:** Fragment Pickup
- **Goal:** When a puzzle is solved, an illustration fragment appears in the world. The player must walk Orange to it and tap to collect.
- **Context from previous modules:** PuzzleBase emits `fragment_revealed`.
- **Files/folders to create or edit:**
  - `res://fragments/fragment_pickup.tscn`
  - `res://fragments/fragment_pickup.gd`
- **Scene/node structure:** `FragmentPickup (Area2D)` with a `Sprite2D`, a small float animation, and a `CollisionShape2D`.
- **GDScript requirements:**
  - `class_name FragmentPickup extends Area2D`.
  - Exported `reward: FragmentReward`.
  - Listens to `EventBus.fragment_revealed`. If the revealed fragment matches `reward.fragment_id`, appears with a soft fade-in.
  - Behaves like an `Interactable` (P08): tap → walk → action button "Collect".
  - On collect: emits `EventBus.fragment_collected(reward.fragment_id, reward.key_item_id)`, despawns.
- **Data/resource requirements:** Uses `FragmentReward`.
- **UI requirements:** Reuses the `ActionButton`.
- **Save/load requirements:** Marks `GameState.collected_fragments` and triggers `EventBus.save_requested(&"fragment_collected")`.
- **Integration requirements:** A single zone may contain multiple `FragmentPickup` nodes pre-placed but hidden until their puzzle is solved.
- **Acceptance criteria:**
  - On `fragment_revealed`, the matching pickup appears.
  - Tapping it walks Orange there and shows "Collect".
  - Pressing collect fires `fragment_collected`, updates `GameState`, and removes the pickup.
- **Manual test steps:**
  1. In a test zone, place one `FragmentPickup` keyed to `&"ep1.map.frag_1"`.
  2. Emit `fragment_revealed`; verify appearance.
  3. Tap → collect; verify state updates and despawn.
- **Common failure cases to avoid:**
  - Auto-collecting fragments. Collection must be manual.
- **Git commit message:** `feat(fragments): add manual fragment pickup (P16)`

---

## Prompt 17 — Mini Picture Frame Progress UI

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P17
- **Module name:** Mini Frame
- **Goal:** Show progress on the current key item as a small picture frame that fills as fragments are collected.
- **Context from previous modules:** Fragments now emit `fragment_collected`.
- **Files/folders to create or edit:**
  - `res://ui/mini_frame.tscn`
  - `res://ui/mini_frame.gd`
- **Scene/node structure:** `MiniFrame (Control)` with a frame border `TextureRect` and `N` slot rects (configurable up to 4 for the prototype) showing partial fragments of the target image.
- **GDScript requirements:**
  - `class_name MiniFrame extends Control`.
  - `set_key_item(item: KeyItem)` initializes slots based on `total_fragments` and shows the underlying `frame_image_path` masked by collected slots.
  - Subscribes to `EventBus.fragment_collected`. If `key_item_id` matches the active key item, fills the next slot and animates softly.
  - When all slots fill, emits `EventBus.key_item_completed(key_item_id)`.
- **Data/resource requirements:** Uses `KeyItem` and `FragmentReward.frame_slot`.
- **UI requirements:** Top-left, small, decorative pixel frame.
- **Save/load requirements:** Reads `GameState` to restore filled slots after load. Triggers a save indirectly via the chain.
- **Integration requirements:** Mount via `Hud.mount_mini_frame`. Updated by `EpisodeController` when episode changes.
- **Acceptance criteria:**
  - Collecting `frag_1` fills slot 1.
  - Collecting all 4 fragments fills the frame and emits `key_item_completed(&"key.secret_map_card")`.
- **Manual test steps:**
  1. Manually emit `fragment_collected` four times in a row with the four ids.
  2. Verify slots fill and `key_item_completed` fires once.
- **Common failure cases to avoid:**
  - Filling slots out of order; use `frame_slot`, not collection order.
- **Git commit message:** `feat(ui): add mini picture frame progress (P17)`

---

## Prompt 18 — Very Small Fixed Key Item System

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P18
- **Module name:** Key Item Inventory
- **Goal:** Maintain a tiny fixed inventory of story-critical key items (Secret Map Card, Mixed Compass).
- **Context from previous modules:** Resources, mini frame, fragments ready.
- **Files/folders to create or edit:**
  - `res://key_items/key_item_inventory.gd` (autoload `KeyItemInventory`).
  - Update `project.godot` autoloads.
- **Scene/node structure:** None.
- **GDScript requirements:**
  - `class_name KeyItemInventory extends Node`.
  - Holds `owned: Array[KeyItem]`.
  - Methods: `grant(item: KeyItem)`, `has(id: StringName) -> bool`, `get_item(id: StringName) -> KeyItem`.
  - Subscribes to `EventBus.key_item_completed`: looks up the resource by id, calls `grant`, appends to `GameState.completed_key_items`, emits `EventBus.save_requested(&"key_item_completed")`.
  - Provides `use(id: StringName, context: StringName)`: emits `EventBus.key_item_used(id, context)` if owned; otherwise no-op.
- **Data/resource requirements:** A simple registry mapping `key_item_id` → `.tres` path. Hardcode `&"key.secret_map_card"` and `&"key.mixed_compass"`.
- **UI requirements:** None.
- **Save/load requirements:** Reads/writes through `GameState`.
- **Integration requirements:** No "open inventory" menu. The player never sees a list — only the mini frame and the action button.
- **Acceptance criteria:**
  - Emitting `key_item_completed(&"key.secret_map_card")` adds it to the inventory and triggers a save request.
  - `KeyItemInventory.has(&"key.secret_map_card")` is `true` after.
- **Manual test steps:**
  1. Emit the signal; verify inventory and save request via prints.
- **Common failure cases to avoid:**
  - Building a generic inventory UI. The system is intentionally tiny.
- **Git commit message:** `feat(items): add fixed key item inventory (P18)`

---

## Prompt 19 — Save System After Every Puzzle Reward

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P19
- **Module name:** Save System
- **Goal:** Persist game state to `user://save.json` whenever `EventBus.save_requested` fires (typically after a fragment is collected or a key item completes).
- **Context from previous modules:** Most state lives in `GameState` and `KeyItemInventory`.
- **Files/folders to create or edit:**
  - `res://globals/save_system.gd` (replace stub).
- **Scene/node structure:** None.
- **GDScript requirements:**
  - `class_name SaveSystem extends Node`.
  - On `_ready`, connects to `EventBus.save_requested` and `EventBus.fragment_collected`.
  - `save() -> void`: writes the structure from section 5.4 to `user://save.json`.
  - `load() -> bool`: reads the file (if any) and applies values to `GameState` and `KeyItemInventory`.
  - `version: int = 1`. Refuse to load mismatched versions and log a warning.
- **Data/resource requirements:** None.
- **UI requirements:** None.
- **Save/load requirements:** This is the save module.
- **Integration requirements:** Triggered automatically by the existing signal chain. `EpisodeController` (P20) calls `SaveSystem.load()` on startup.
- **Acceptance criteria:**
  - Solving and collecting a fragment writes a save file with `collected_fragments` containing the new id.
  - Restarting the game loads the same fragments back into `GameState`.
- **Manual test steps:**
  1. Solve dummy puzzle, collect fragment.
  2. Inspect `user://save.json`.
  3. Restart project; verify state restored.
- **Common failure cases to avoid:**
  - Saving on every frame (must only save on the listed signals).
  - Crashing if save file is missing on first run.
- **Git commit message:** `feat(save): persist progress after every puzzle reward (P19)`

---

## Prompt 20 — Episode Controller

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P20
- **Module name:** Episode Controller
- **Goal:** Orchestrate which episode and zone is active, transition between them, and manage which `KeyItem` the mini frame currently tracks.
- **Context from previous modules:** All systems above.
- **Files/folders to create or edit:**
  - `res://globals/episode_controller.gd` (replace stub).
- **Scene/node structure:** None.
- **GDScript requirements:**
  - `class_name EpisodeController extends Node`.
  - Tracks `current_episode_id: StringName`.
  - On `_ready`: calls `SaveSystem.load()`. If state is empty, sets `&"ep1"` and zone `&"ep1.zone_1"`.
  - Subscribes to `EventBus.zone_change_requested(path)` and changes scenes via `get_tree().change_scene_to_file(path)`.
  - On `EventBus.key_item_completed(&"key.secret_map_card")`, prepares a transition into the Episode 2 bridge (loads its zone, but actual scene change is requested via `zone_change_requested`).
  - Provides `set_episode(episode_id)` which updates `GameState.current_episode` and re-binds the `MiniFrame` to the matching `KeyItem`.
- **Data/resource requirements:** Mapping table:
  - `&"ep1"` → `secret_map_card.tres`.
  - `&"ep2bridge"` → `mixed_compass.tres` (shown only as a forward hint; the bridge does not complete it).
- **UI requirements:** Coordinates with `Hud.mount_mini_frame`.
- **Save/load requirements:** Loads and respects saved current episode.
- **Integration requirements:** All zone scenes must declare `zone_id` so the controller can validate transitions.
- **Acceptance criteria:**
  - On a fresh project, launching the game starts in Episode 1, zone 1, with the Secret Map Card frame mounted.
  - Completing all 4 Episode 1 fragments triggers `key_item_completed`, then a transition to the Episode 2 bridge zone.
- **Manual test steps:**
  1. Fresh save; run; verify start state.
  2. Force-emit four `fragment_collected` signals; verify episode bridge transition.
- **Common failure cases to avoid:**
  - Hardcoding scene paths in scattered scripts. Centralize them here.
- **Git commit message:** `feat(episodes): add episode controller and bridge orchestration (P20)`

---

## Prompt 21 — Episode 1 Zone Structure

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P21
- **Module name:** Episode 1 Zones
- **Goal:** Build the four Episode 1 zones using the zone template (P07) with placeholder visuals.
- **Context from previous modules:** Zone template ready.
- **Files/folders to create or edit:**
  - `res://episodes/episode_1/zones/zone_1_forest_entry.tscn` (already from P07 — finalize)
  - `res://episodes/episode_1/zones/zone_2_mushroom_grove.tscn`
  - `res://episodes/episode_1/zones/zone_3_muddy_path.tscn`
  - `res://episodes/episode_1/zones/zone_4_bark_clearing.tscn`
- **Scene/node structure:** Each zone follows the P07 template exactly. Each has at least one walkable area and an empty `Interactables` node ready for puzzles.
- **GDScript requirements:** Each zone exports its `zone_id`:
  - `&"ep1.zone_1"`, `&"ep1.zone_2"`, `&"ep1.zone_3"`, `&"ep1.zone_4"`.
- **Data/resource requirements:** None.
- **UI requirements:** Each zone instances the HUD.
- **Save/load requirements:** Zone change sets `current_zone`.
- **Integration requirements:** Zones connect via simple `ZoneExit` `Area2D` triggers that call `EventBus.zone_change_requested(path)`. Place one exit between consecutive zones.
- **Acceptance criteria:**
  - Walking Orange to a zone exit transitions to the next zone scene with HUD intact.
  - The hint button and mini frame remain mounted.
- **Manual test steps:**
  1. Run zone 1; walk to its exit; confirm zone 2 loads.
  2. Repeat through zone 4.
- **Common failure cases to avoid:**
  - Persistence loss across scene change. The HUD is per-zone; state lives in autoloads.
- **Git commit message:** `feat(ep1): add four Episode 1 zones with exits (P21)`

---

## Prompt 22 — Mushroom Path Puzzle Prototype

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P22
- **Module name:** Episode 1 Puzzle 1 — Mushroom Path
- **Goal:** Implement the mushroom path puzzle: the player follows mushroom clusters in a hidden order (e.g. smallest to largest, or orange-tinted side).
- **Context from previous modules:** PuzzleBase, fragments, interactables ready.
- **Files/folders to create or edit:**
  - `res://episodes/episode_1/puzzles/mushroom_path/mushroom_path_puzzle.tscn`
  - `res://episodes/episode_1/puzzles/mushroom_path/mushroom_path_puzzle.gd`
  - `res://episodes/episode_1/definitions/puzzle_mushroom_path.tres`
- **Scene/node structure:** Root extends `PuzzleBase`. Children: 5 `MushroomCluster` `Interactable` nodes with sizes 1..5 (or with tint markers).
- **GDScript requirements:**
  - `class_name MushroomPathPuzzle extends PuzzleBase`.
  - Maintains an expected order array (e.g. `[1,2,3,4,5]`).
  - On each interaction, appends the cluster's index. If it ever diverges from the expected prefix, reset progress and show a gentle dialogue line.
  - On full match, calls `mark_solved()`.
- **Data/resource requirements:** `puzzle_mushroom_path.tres` references `frag_1` reward.
- **UI requirements:** Reuses dialogue/hint/action button.
- **Save/load requirements:** PuzzleBase handles state.
- **Integration requirements:** Lives in zone 2.
- **Acceptance criteria:**
  - Tapping clusters in correct order solves the puzzle and reveals fragment 1.
  - Wrong order resets progress with a gentle hint dialogue.
- **Manual test steps:**
  1. Open zone 2; solve in correct order; verify fragment 1 appears.
  2. Restart; solve in wrong order first; verify reset.
- **Common failure cases to avoid:**
  - Allowing partial-credit completion.
- **Git commit message:** `feat(ep1): mushroom path puzzle prototype (P22)`

---

## Prompt 23 — Animal Tracks Puzzle Prototype

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P23
- **Module name:** Episode 1 Puzzle 2 — Animal Tracks
- **Goal:** Implement the animal tracks puzzle: choose the correct trail (rabbit, deer, fox, bird) based on a nearby symbol/hint.
- **Context from previous modules:** PuzzleBase + zone 3.
- **Files/folders to create or edit:**
  - `res://episodes/episode_1/puzzles/animal_tracks/animal_tracks_puzzle.tscn`
  - `res://episodes/episode_1/puzzles/animal_tracks/animal_tracks_puzzle.gd`
  - `res://episodes/episode_1/definitions/puzzle_animal_tracks.tres`
- **Scene/node structure:** Root extends `PuzzleBase`. Children: 4 trail `Interactable`s (rabbit/deer/fox/bird) plus a `HintSymbol` static sprite that indicates the correct choice.
- **GDScript requirements:**
  - `class_name AnimalTracksPuzzle extends PuzzleBase`.
  - Exported `correct_trail: StringName` (e.g. `&"deer"`).
  - On a trail tap, compare to `correct_trail`. Correct → `mark_solved`. Incorrect → gentle dialogue line, no progress.
- **Data/resource requirements:** Resource references `frag_2`.
- **UI requirements:** Action button label "Follow".
- **Save/load requirements:** PuzzleBase handles.
- **Integration requirements:** Lives in zone 3.
- **Acceptance criteria:**
  - Choosing the correct trail reveals fragment 2.
  - Wrong trails show different gentle dialogues but never block.
- **Manual test steps:**
  1. Open zone 3; verify each trail's reaction.
- **Common failure cases to avoid:**
  - Punishing the player for exploration.
- **Git commit message:** `feat(ep1): animal tracks puzzle prototype (P23)`

---

## Prompt 24 — Raindrop Rhythm Puzzle Prototype

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P24
- **Module name:** Episode 1 Puzzle 3 — Raindrop Rhythm
- **Goal:** Player repeats a short rhythm pattern by tapping objects (Leaf → Puddle → Leaf → Log). **Must remain visually solvable** — sound is supportive only.
- **Context from previous modules:** PuzzleBase, dialogue, action button ready.
- **Files/folders to create or edit:**
  - `res://episodes/episode_1/puzzles/raindrop_rhythm/raindrop_rhythm_puzzle.tscn`
  - `res://episodes/episode_1/puzzles/raindrop_rhythm/raindrop_rhythm_puzzle.gd`
  - `res://episodes/episode_1/definitions/puzzle_raindrop_rhythm.tres`
- **Scene/node structure:** Root extends `PuzzleBase`. Children: 4 rhythm `Interactable`s (Leaf, Puddle, Log, Stone). A `RhythmDemonstrator` node animates the pattern visually (highlights flash in order, repeating slowly).
- **GDScript requirements:**
  - `class_name RaindropRhythmPuzzle extends PuzzleBase`.
  - Exported `pattern: Array[StringName]` (e.g. `[&"leaf", &"puddle", &"leaf", &"log"]`).
  - Player taps; correct prefix → progress; wrong tap → reset + gentle dialogue.
  - Visual demo loops every 6 seconds.
- **Data/resource requirements:** Resource references `frag_3`.
- **UI requirements:** No sound-only solution. The flash sequence is the canonical clue. Optional sound supports.
- **Save/load requirements:** PuzzleBase handles.
- **Integration requirements:** Lives in zone 3 or 4 (place in zone 3 — keep it discoverable). The hint text in `episode_1.json` already covers it.
- **Acceptance criteria:**
  - Player can solve fully muted.
  - Tapping the correct pattern reveals fragment 3.
- **Manual test steps:**
  1. Mute audio; solve via the visual flash sequence; verify success.
- **Common failure cases to avoid:**
  - Hiding the pattern too fast or only in audio.
- **Git commit message:** `feat(ep1): raindrop rhythm puzzle prototype (P24)`

---

## Prompt 25 — Wet Bark Symbol Puzzle Prototype

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P25
- **Module name:** Episode 1 Puzzle 4 — Wet Bark Symbol
- **Goal:** Match wet bark symbols on three trees to a target shape derived from earlier fragments (rotation puzzle).
- **Context from previous modules:** PuzzleBase ready; fragments 1–3 collected when this puzzle is reached.
- **Files/folders to create or edit:**
  - `res://episodes/episode_1/puzzles/wet_bark_symbol/wet_bark_symbol_puzzle.tscn`
  - `res://episodes/episode_1/puzzles/wet_bark_symbol/wet_bark_symbol_puzzle.gd`
  - `res://episodes/episode_1/definitions/puzzle_wet_bark.tres`
- **Scene/node structure:** Root extends `PuzzleBase`. Children: 3 `BarkSymbol` `Interactable`s, each rotatable in 90° steps; a `TargetSymbol` showing the goal pose composed from fragments.
- **GDScript requirements:**
  - `class_name WetBarkSymbolPuzzle extends PuzzleBase`.
  - Each bark symbol exposes `rotation_step: int` 0..3.
  - Action button label "Rotate".
  - On every rotation, check whether all three rotations match the expected combination. If so, `mark_solved`.
- **Data/resource requirements:** Resource references `frag_4`.
- **UI requirements:** None new.
- **Save/load requirements:** Optional: persist current rotation steps per zone load. Acceptable if rotations reset on reload.
- **Integration requirements:** Lives in zone 4.
- **Acceptance criteria:**
  - Rotating the three symbols into the goal pose reveals fragment 4.
- **Manual test steps:**
  1. Open zone 4; rotate randomly; never auto-completes.
  2. Rotate to goal; verify completion.
- **Common failure cases to avoid:**
  - Allowing free rotation to land on the goal pose by accident on first tap (acceptable, but ensure success only fires once).
- **Git commit message:** `feat(ep1): wet bark symbol puzzle prototype (P25)`

---

## Prompt 26 — Secret Map Card Assembly and Completion

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P26
- **Module name:** Secret Map Card Completion
- **Goal:** When all 4 Episode 1 fragments are collected, the mini frame fills, `key_item_completed(&"key.secret_map_card")` fires, and a short cinematic moment plays (zoom on frame + dialogue line).
- **Context from previous modules:** Mini frame and key item inventory already wired.
- **Files/folders to create or edit:**
  - `res://ui/mini_frame.gd` — extend with a `play_completion_animation()` method (only if needed).
  - `res://episodes/episode_1/zones/zone_4_bark_clearing.tscn` — add a `MapCompletionTrigger` node that plays the moment.
  - `res://data/dialogue/episode_1.json` — add `&"ep1.map_completed"` line.
- **Scene/node structure:** A simple `Node` with a script that listens to `key_item_completed` and runs a short tween.
- **GDScript requirements:**
  - On `key_item_completed(&"key.secret_map_card")`: pause input briefly, play a tween that scales the mini frame, request the dialogue line, then unpause and emit `EventBus.zone_change_requested(<bridge zone path>)`.
- **Data/resource requirements:** Uses `secret_map_card.tres`.
- **UI requirements:** Reuses existing UI.
- **Save/load requirements:** State already saves through prior modules.
- **Integration requirements:** The actual transition is delegated to `EpisodeController` — this prompt only triggers the request after the celebration tween.
- **Acceptance criteria:**
  - Collecting fragment 4 plays the celebration and transitions to the bridge zone.
- **Manual test steps:**
  1. Force-collect 3 fragments via `GameState`; collect the 4th in-game; verify celebration and transition.
- **Common failure cases to avoid:**
  - Triggering twice if the player reloads after completion.
- **Git commit message:** `feat(ep1): secret map card completion moment (P26)`

---

## Prompt 27 — Episode 2 Sunlight Map Activation Bridge

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P27
- **Module name:** Episode 2 Bridge — Sunlit Map Activation
- **Goal:** In a single sunlit clearing zone, the player uses the Secret Map Card to reveal the route to the waterfall. This is the bridge puzzle that proves the key item from Episode 1 matters.
- **Context from previous modules:** Bridge zone exists at `episode_2_bridge/zones/zone_sunlit_clearing.tscn`.
- **Files/folders to create or edit:**
  - `res://episodes/episode_2_bridge/zones/zone_sunlit_clearing.tscn`
  - `res://episodes/episode_2_bridge/puzzles/sunlit_map_activation/sunlit_map_activation_puzzle.tscn`
  - `res://episodes/episode_2_bridge/puzzles/sunlit_map_activation/sunlit_map_activation_puzzle.gd`
  - `res://episodes/episode_2_bridge/definitions/puzzle_sunlit_map.tres`
  - `res://data/dialogue/episode_2_bridge.json`
  - `res://data/hints/episode_2_bridge.json`
- **Scene/node structure:** Root extends `PuzzleBase`. Children:
  - A `Sunbeam` `Sprite2D` with a moving direction.
  - A `MapCardSpot` `Interactable` (action label "Use Map") that requires `KeyItemInventory.has(&"key.secret_map_card")`.
  - A rotation control to align the map with the sunbeam.
- **GDScript requirements:**
  - `class_name SunlitMapActivationPuzzle extends PuzzleBase`.
  - On `MapCardSpot` interaction: if the player owns the card, switch into a "rotate map" sub-state; otherwise show a gentle dialogue ("I need the map first").
  - On reaching the correct alignment angle, `mark_solved` and emit `EventBus.key_item_used(&"key.secret_map_card", &"sunlit_clearing")`.
- **Data/resource requirements:** Resource references no Episode 2 fragments — the bridge ends with route revealed, not a new fragment.
- **UI requirements:** Reuses dialogue, hint, action button.
- **Save/load requirements:** Setting `completed_puzzles` and `flags["episode_2_route_revealed"] = true`.
- **Integration requirements:** This is the proof of the core loop. After success, the screen reveals a poetic glimpse of the waterfall route and ends the prototype gracefully (handled in P28).
- **Acceptance criteria:**
  - Without the Secret Map Card, the puzzle blocks with dialogue.
  - With the card, rotating to the correct angle reveals the route and emits `key_item_used`.
- **Manual test steps:**
  1. Force-clear the inventory and try the puzzle — should block.
  2. Grant the card and complete — should succeed.
- **Common failure cases to avoid:**
  - Allowing solving without the key item.
- **Git commit message:** `feat(ep2bridge): sunlit map activation bridge puzzle (P27)`

---

## Prompt 28 — Soft Zone Transition and Prototype Ending Card

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P28
- **Module name:** Soft Transitions & Ending Card
- **Goal:** Provide a reusable soft fade transition between zones and a final "prototype end" card after the bridge succeeds.
- **Context from previous modules:** Zone changes already happen via `EpisodeController`.
- **Files/folders to create or edit:**
  - `res://transitions/soft_transition.tscn`
  - `res://transitions/soft_transition.gd`
  - `res://ui/prototype_end_card.tscn`
  - `res://ui/prototype_end_card.gd`
- **Scene/node structure:**
  - `SoftTransition (CanvasLayer)` with a `ColorRect` for fade in/out.
  - `PrototypeEndCard (Control)` showing a poetic line such as "The forest remembers you. To be continued."
- **GDScript requirements:**
  - `SoftTransition` exposes async `play_out()` and `play_in()` and is invoked by `EpisodeController` around scene changes.
  - `PrototypeEndCard` shows after `key_item_used(&"key.secret_map_card", &"sunlit_clearing")`.
- **Data/resource requirements:** End line stored in `episode_2_bridge.json`.
- **UI requirements:** Single "Restart Prototype" button on the end card that resets `GameState` and reloads zone 1.
- **Save/load requirements:** Restart wipes the save file (with a confirmation dialog — use a single yes/no step).
- **Integration requirements:** Transitions are used by every zone change; ending card is shown only after the bridge.
- **Acceptance criteria:**
  - Zone changes fade smoothly.
  - The bridge ends with the end card; restart returns to zone 1 with a fresh save.
- **Manual test steps:**
  1. Walk through any zone exit; verify fade.
  2. Complete the bridge; verify ending card; press restart; verify reset.
- **Common failure cases to avoid:**
  - Leaving a black overlay if fade-in fails.
- **Git commit message:** `feat(transitions): soft transitions and prototype end card (P28)`

---

## Prompt 29 — Responsive Web Export Check

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P29
- **Module name:** Web Export Validation
- **Goal:** Configure and validate a Godot 4.x web export of the prototype.
- **Context from previous modules:** Prototype is fully playable.
- **Files/folders to create or edit:**
  - `export_presets.cfg` (Web export preset).
  - Optional `builds/` ignored folder.
- **Scene/node structure:** None.
- **GDScript requirements:** None.
- **Data/resource requirements:** None.
- **UI requirements:** Verify HUD scales correctly across `1920×1080`, `1280×720`, and `844×390` (mobile landscape).
- **Save/load requirements:** Confirm `user://save.json` works in browser via IndexedDB.
- **Integration requirements:**
  - Stretch mode: `viewport`. Aspect: `keep` or `expand` — pick the one that respects landscape.
  - Touch input enabled.
- **Acceptance criteria:**
  - Web build runs in Chrome desktop and Chrome mobile (or simulated touch).
  - Tap movement, action button, fragment collection, and save all work in browser.
- **Manual test steps:**
  1. Export Web build; serve via `python -m http.server` from the export folder.
  2. Play through Episode 1 puzzle 1 → fragment collection on desktop.
  3. Open the same URL on a mobile browser (or DevTools touch emulation); verify tap works.
- **Common failure cases to avoid:**
  - Using audio APIs that fail without user gesture (defer audio start until first input).
  - Persistent save failure due to filesystem permissions in browser.
- **Git commit message:** `chore(web): configure and validate web export (P29)`

---

## Prompt 30 — Final Prototype Integration Pass

Read the workspace documentation first:
- CLAUDE.md
- prompts.md
- docs/ai/PROMPTS_CLARIFICATIONS.md
- docs/ai/ARCHITECTURE.md
- docs/ai/TECHNICAL_RULES.md

Implement ONLY the PXX prompt pasted below.

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

PXX prompt:

- **Prompt ID:** P30
- **Module name:** Integration & Polish Pass
- **Goal:** Walk through the entire prototype end-to-end on a fresh save, fix any rough edges, and confirm it proves the core loop.
- **Context from previous modules:** Everything above.
- **Files/folders to create or edit:** Possibly small fixes only — no new systems.
- **Scene/node structure:** No new scenes.
- **GDScript requirements:** Targeted fixes only.
- **Data/resource requirements:** Final pass on dialogue, hints, and labels for tone consistency.
- **UI requirements:** Confirm slot positions on desktop and mobile landscape.
- **Save/load requirements:** Confirm save survives every step.
- **Integration requirements:**
  - Run a fresh save from `zone_1_forest_entry` through the bridge end card.
  - Confirm the mini frame fills exactly four times.
  - Confirm the hint button is enabled only during active puzzles.
- **Acceptance criteria:**
  - End-to-end playthrough succeeds on desktop web build.
  - End-to-end playthrough succeeds on mobile-landscape simulation.
  - No console errors, no missing labels, no broken hints.
- **Manual test steps:**
  1. Delete `user://save.json`.
  2. Play from start to end card on desktop.
  3. Repeat on mobile/touch emulator.
  4. Verify save persists across reloads at every fragment.
- **Common failure cases to avoid:**
  - Adding new content during the polish pass.
  - Renaming established files or signals (would silently break references).
- **Git commit message:** `chore: final prototype integration pass (P30)`

---

## Closing Notes

- After P30, the prototype is feature-complete for Episode 1 + the Episode 2 sunlight bridge.
- Any further work — full Episode 2, Episode 3, the Mixed Compass, the Teleportation Door — is **out of scope** for this prompt set.
- Before shipping a build to playtesters, run the QA prompt in `testprompt.md` end-to-end.

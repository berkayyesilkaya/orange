# Orange — Implementation Report
**Prompts completed:** P01 – P14 (P05 skipped by design)
**Date:** 2026-05-06
**Engine:** Godot 4.x / GDScript
**Branch:** main

---

## Table of Contents

1. [P01 — Base Godot Project](#p01--base-godot-project)
2. [P02 — Folder Skeleton](#p02--folder-skeleton)
3. [P03 — Globals & Autoloads](#p03--globals--autoloads)
4. [P04 — Orange Character Scene](#p04--orange-character-scene)
5. [P05 — SKIPPED](#p05--skipped)
6. [P06 — Follow Camera](#p06--follow-camera)
7. [P07 — Zone Scene Template](#p07--zone-scene-template)
8. [P08 — Interactable Foundation](#p08--interactable-foundation)
9. [P09 — Interaction Manager + Action Button](#p09--interaction-manager--action-button)
10. [P10 — HUD Skeleton](#p10--hud-skeleton)
11. [P11 — Dialogue Box](#p11--dialogue-box)
12. [P12 — Floating Object Labels](#p12--floating-object-labels)
13. [P13 — Hint Button](#p13--hint-button)
14. [P14 — Data Conventions (Resources)](#p14--data-conventions-resources)
15. [Cross-Cutting Decisions](#cross-cutting-decisions)
16. [Pending Prompts](#pending-prompts)

---

## P01 — Base Godot Project

**Commit:** `chore: initialize Godot 4.x project for Orange (P01)`

### Files Created
| File | Purpose |
|------|---------|
| `project.godot` | Engine config |
| `icon.svg` | Placeholder project icon |
| `.gitignore` | Excludes `.godot/`, `*.import`, `builds/`, etc. |
| `README.md` | One-paragraph project description |

### Key Configuration (`project.godot`)
```ini
[application]
config/name="Orange"
config/features=PackedStringArray("4.3", "Compatibility")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="viewport"
window/stretch/aspect="keep"
window/handheld/orientation=0   ; landscape

[rendering]
renderer/rendering_method="gl_compatibility"
textures/canvas_textures/default_texture_filter=0   ; Nearest (pixel-art)
2d/snap/snap_2d_transforms_to_pixel=true
2d/snap/snap_2d_vertices_to_pixel=true
```

### Decisions
- **Compatibility renderer** chosen over Forward+ for safe web export.
- **Nearest texture filter** set globally so pixel art is never blurred.
- **Viewport stretch + keep aspect** maintains 1280×720 regardless of window size.

---

## P02 — Folder Skeleton

**Commit:** `chore: scaffold project folder structure (P02)`

### Files Created
Empty `.gdkeep` files placed inside every folder so Git tracks the full tree.

### Folder Tree Created
```
res://
├── globals/
├── characters/orange/
├── camera/
├── interaction/
├── ui/
├── puzzles/
├── fragments/
├── key_items/
├── data/dialogue/
├── data/hints/
├── data/floating_labels/
├── episodes/episode_1/zones/
├── episodes/episode_1/puzzles/
├── episodes/episode_1/fragments/
├── episodes/episode_1/definitions/
├── episodes/episode_2_bridge/zones/
├── episodes/episode_2_bridge/puzzles/
├── episodes/episode_2_bridge/definitions/
├── transitions/
├── art/orange/
├── audio/
└── tests/
```

### Decisions
- Strictly followed `prompts.md` section 4. No extra folders created.

---

## P03 — Globals & Autoloads

**Commit:** `feat(globals): add constants, event bus, and core autoloads (P03)`

### Files Created
| File | Class | Role |
|------|-------|------|
| `globals/constants.gd` | `Constants` | All canonical IDs as typed `StringName` constants |
| `globals/event_bus.gd` | `EventBus` | Global signals only — zero logic |
| `globals/game_state.gd` | `GameState` | Runtime mutable state + typed helpers |
| `globals/save_system.gd` | `SaveSystem` | Stub — implemented in P19 |
| `globals/episode_controller.gd` | `EpisodeController` | Stub — implemented in P20 |

### Autoload Registration (`project.godot`)
```ini
[autoload]
Constants="*res://globals/constants.gd"
EventBus="*res://globals/event_bus.gd"
GameState="*res://globals/game_state.gd"
SaveSystem="*res://globals/save_system.gd"
EpisodeController="*res://globals/episode_controller.gd"
```
`KeyItemInventory` will be added in P18.

### `constants.gd` — All IDs
```gdscript
# Puzzle IDs
const PUZZLE_MUSHROOM_PATH:  StringName = &"ep1.mushroom_path"
const PUZZLE_ANIMAL_TRACKS:  StringName = &"ep1.animal_tracks"
const PUZZLE_RAINDROP_RHYTHM: StringName = &"ep1.raindrop_rhythm"
const PUZZLE_WET_BARK_SYMBOL: StringName = &"ep1.wet_bark_symbol"
const PUZZLE_SUNLIT_MAP:     StringName = &"ep2bridge.sunlit_map"

# Fragment IDs
const FRAGMENT_EP1_MAP_1: StringName = &"ep1.map.frag_1"
const FRAGMENT_EP1_MAP_2: StringName = &"ep1.map.frag_2"
const FRAGMENT_EP1_MAP_3: StringName = &"ep1.map.frag_3"
const FRAGMENT_EP1_MAP_4: StringName = &"ep1.map.frag_4"

# Key Item IDs
const KEY_SECRET_MAP_CARD: StringName = &"key.secret_map_card"
const KEY_MIXED_COMPASS:   StringName = &"key.mixed_compass"

# Zone IDs
const ZONE_EP1_1: StringName = &"ep1.zone_1"
const ZONE_EP1_2: StringName = &"ep1.zone_2"
const ZONE_EP1_3: StringName = &"ep1.zone_3"
const ZONE_EP1_4: StringName = &"ep1.zone_4"
const ZONE_EP2BRIDGE_SUNLIT: StringName = &"ep2bridge.zone_sunlit_clearing"
```

### `event_bus.gd` — All Global Signals
```gdscript
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

### `game_state.gd` — Runtime State
```gdscript
var current_episode: StringName = &"ep1"
var current_zone: StringName = &"ep1.zone_1"
var completed_puzzles: Array[StringName] = []
var collected_fragments: Array[StringName] = []
var owned_key_items: Array[StringName] = []
var completed_key_items: Array[StringName] = []
var flags: Dictionary = {}
```
Helper methods: `reset()`, `is_puzzle_completed()`, `mark_puzzle_completed()`, `is_fragment_collected()`, `mark_fragment_collected()`, `is_key_item_owned()`, `grant_key_item()`, `is_key_item_completed()`, `mark_key_item_completed()`, `get_flag()`, `set_flag()`.

---

## P04 — Orange Character Scene

**Commit:** `feat(character): add Orange character scene with move_to API (P04)`

### Files Created
| File | Purpose |
|------|---------|
| `characters/orange/orange_character.gd` | Character logic |
| `characters/orange/orange_character.tscn` | Scene definition |
| `art/orange/orange_placeholder.svg` | 32×48 magenta block placeholder |

### Scene Hierarchy
```
OrangeCharacter (CharacterBody2D)
├── Sprite2D          — displays orange_placeholder.svg
├── CollisionShape2D  — CapsuleShape2D (radius=8, height=6) at offset (0, 16)
└── AnimationPlayer   — plays the idle bob animation
```

### Public API (`orange_character.gd`)
```gdscript
class_name OrangeCharacter extends CharacterBody2D

signal arrived_at_target

@export var walk_speed: float = 90.0
var is_moving: bool: get: return _has_target

func move_to(target: Vector2) -> void
```

### Movement Logic
- `_physics_process` moves toward `_target` each frame using `velocity = direction.normalized() * walk_speed` then `move_and_slide()`.
- Stops and emits `arrived_at_target` when within **2 px** of target.
- Setting a new `move_to` mid-walk simply overwrites `_target`.

### Idle Animation
Built **programmatically** in `_setup_idle_animation()` — avoids complex `.tscn` animation serialisation. Uses `AnimationLibrary` + `Animation` with a cubic-interpolated vertical bob: `0 → -3px → 0` over 1.2 seconds, looped.

---

## P05 — SKIPPED

P05 (Tap/Click Walkable Movement via `WalkableArea`) was intentionally skipped in this session. `walkable_area.gd` is not present.

**Impact:** `InteractionManager` (P09) handles its own tap-detection via physics point query rather than relying on `WalkableArea` consuming input first. The `WalkableArea` node in `zone_1_forest_entry.tscn` is a plain `Area2D` with no script.

---

## P06 — Follow Camera

**Commit:** `feat(camera): add smooth follow camera (P06)`

### Files Created
| File | Purpose |
|------|---------|
| `camera/follow_camera.gd` | Camera logic |
| `camera/follow_camera.tscn` | Camera scene |

### Scene Properties
```
FollowCamera (Camera2D)
  enabled = true
  position_smoothing_enabled = true
  position_smoothing_speed = 5.0
```

### Public API (`follow_camera.gd`)
```gdscript
class_name FollowCamera extends Camera2D

@export var target_path: NodePath
@export var bounds: Rect2 = Rect2()   # clamping; ignored when size == Vector2.ZERO
```

### Logic
- `_ready` resolves `target_path` via `get_node_or_null` cast to `Node2D`.
- `_process` sets `global_position = target.global_position`, optionally clamped to `bounds` using `Vector2.clamp(bounds.position, bounds.end)`.
- Safe against invalid targets: guarded with `is_instance_valid`.

### Decisions
- Smoothing is left to Camera2D's built-in `position_smoothing` rather than lerp in script — one source of truth, no drift.
- `bounds` ignored when `Rect2` is zero-size so zones without limits work without extra setup.

---

## P07 — Zone Scene Template

**Commit:** `feat(zones): add zone scene template and Episode 1 zone 1 (P07)`

### Files Created
| File | Purpose |
|------|---------|
| `episodes/zone.gd` | Reusable zone base script |
| `episodes/episode_1/zones/zone_1_forest_entry.tscn` | Episode 1 Zone 1 scene |

### Zone Script (`zone.gd`)
```gdscript
class_name Zone extends Node2D

@export var zone_id: StringName = &""

func _ready() -> void:
    if zone_id != &"": GameState.current_zone = zone_id
    _setup_hud()
```

`_setup_hud()` wires all sibling UI nodes into HUD slots by name using `get_node_or_null` — **no hardcoded paths**, no crash if a component is absent. This method grew across P10–P13 as more components were added.

### Zone 1 Scene Hierarchy
```
Zone1ForestEntry (Node2D, zone.gd, zone_id=&"ep1.zone_1")
├── Background (Node2D — placeholder)
├── WalkableArea (Area2D)
│   └── CollisionShape2D (RectangleShape2D 2560×1440)
├── Interactables (Node2D — container for future objects)
├── OrangeCharacter (instanced)
├── FollowCamera (instanced, target_path="../OrangeCharacter")
├── HUD (instanced)            ← added P10
├── ActionButton (instanced)   ← added P10
├── DialogueBox (instanced)    ← added P11
├── HintButton (instanced)     ← added P13
└── InteractionManager (Node, interaction_manager.gd)  ← added P10
        orange = NodePath("OrangeCharacter")
```

`load_steps` in the `.tscn` header tracks every `ext_resource` reference: ended at **10** after P13.

---

## P08 — Interactable Foundation

**Commit:** `feat(interaction): add Interactable base node (P08)`

### Files Created
| File | Purpose |
|------|---------|
| `interaction/interactable.gd` | Reusable interactable node |
| `interaction/interactable_area.tscn` | Template scene for placing in zones |

### Scene Hierarchy
```
InteractableArea (Area2D, interactable.gd)
├── CollisionShape2D (RectangleShape2D 48×48)
└── Sprite2D (visual placeholder)
```

### Public API (`interactable.gd`)
```gdscript
class_name Interactable extends Area2D

signal interaction_triggered(interactable: Interactable)

@export var interactable_id: StringName = &""
@export var display_label: String = ""
@export var action_label: String = "Inspect"
@export var interaction_position: Vector2 = Vector2.ZERO

func request_interaction(orange: OrangeCharacter) -> void:
    orange.move_to(global_position + interaction_position)
    await orange.arrived_at_target
    interaction_triggered.emit(self)
```

### Decisions
- `interaction_position` is a **local offset** added to `global_position` — lets designers position the "stand here" point per-object in the inspector.
- No global signals here; `interaction_triggered` is a local node signal. Global event dispatch is handled by `InteractionManager` (P09).

---

## P09 — Interaction Manager + Action Button

**Commit:** `feat(interaction): add contextual one-button interaction (P09)`

### Files Created
| File | Purpose |
|------|---------|
| `interaction/interaction_manager.gd` | Tap detection + interaction orchestration |
| `ui/action_button.gd` | Single contextual action button |
| `ui/action_button.tscn` | Action button scene |
| `tests/test_interactable.gd` | Manual test helper |

### Action Button Scene
```
ActionButton (Control, min_size=128×64)
└── TextureButton (full-rect anchor)
    └── Label (centered)
```

### Action Button API (`action_button.gd`)
```gdscript
class_name ActionButton extends Control

signal confirmed(interactable: Interactable)

func show_for(interactable: Interactable) -> void   # sets label text, shows
func hide_button() -> void                           # hides, clears interactable
```

### Interaction Manager (`interaction_manager.gd`)
Receives tap/click input via `_unhandled_input`, runs a **physics point query** to check whether the tapped world position overlaps an `Interactable` `Area2D`, and orchestrates the full interaction flow.

```
Tap event
  └─► _get_interactable_at(screen_pos)
        └─► canvas_transform.affine_inverse() * screen_pos  →  world_pos
            PhysicsPointQueryParameters2D (areas only)
              └─► returns Interactable or null
  ├─ hit: consume input, _handle_tap(interactable)
  │         └─► await request_interaction → show ActionButton
  └─ miss: hide ActionButton (if visible)
```

**Puzzle dispatch in `_dispatch_action`:** checks `interactable_id` against all five `Constants.PUZZLE_*` values → emits `EventBus.puzzle_started`. Non-puzzle interactables emit local signal `action_dispatched`.

### Key Design Decisions
- `_is_busy` flag prevents double-handling rapid taps.
- `is_instance_valid(self)` guard after `await` protects against scene changes mid-interaction.
- Handles both `InputEventScreenTouch` and `InputEventMouseButton` for web/desktop.
- `get_viewport().set_input_as_handled()` on interactable taps prevents `WalkableArea` from also responding.

### Evolution of `interaction_manager.gd`
The file was extended across later prompts:
- **P12** added `set_hud()`, `_show_floating_label()`, `_load_label_data()`.
- **P13** wiring via `zone.gd._setup_hud()` calls `set_hud(hud)`.

---

## P10 — HUD Skeleton

**Commit:** `feat(ui): add minimal cozy HUD skeleton (P10)`

### Files Created
| File | Purpose |
|------|---------|
| `ui/hud.gd` | HUD host with mount methods |
| `ui/hud.tscn` | HUD scene with named slots |

### Scene Hierarchy
```
HUD (CanvasLayer, layer=10)
├── Bottom (Control, anchored full-width at screen bottom, 120px tall)
│   ├── DialogueBoxSlot  (Control, left 65%)
│   └── ActionButtonSlot (CenterContainer, right 35%)
├── TopLeft (Control, 160×160px, top-left)
│   └── MiniFrameSlot (full-rect inside TopLeft)
├── TopRight (Control, 100×80px, top-right)
│   └── HintButtonSlot (full-rect inside TopRight)
└── FloatingLabels (Control, full-rect, mouse_filter=2)
```

### Public API (`hud.gd`)
```gdscript
class_name Hud extends CanvasLayer

func mount_action_button(node: Node) -> void
func mount_dialogue_box(node: Node)  -> void
func mount_hint_button(node: Node)   -> void
func mount_mini_frame(node: Node)    -> void
func add_floating_label(node: Node)  -> void
```

All mount methods call `_reparent_into(slot, node)`:
```gdscript
func _reparent_into(slot: Control, node: Node) -> void:
    if node.get_parent(): node.reparent(slot)
    else: slot.add_child(node)
```

### Integration with `zone.gd`
`Zone._setup_hud()` is called on `_ready`. It resolves siblings by name and mounts them:
```gdscript
if action_button:          hud.mount_action_button(action_button)
if action_button and im:   im.set_action_button(action_button)
if im and hud:             im.set_hud(hud)
if dialogue_box:           hud.mount_dialogue_box(dialogue_box)
if hint_button:            hud.mount_hint_button(hint_button)
if hint_button and db:     hint_button.set_dialogue_box(dialogue_box)
```

### Decisions
- `ActionButtonSlot` uses `CenterContainer` so the action button auto-centers regardless of its size.
- `FloatingLabels` has `mouse_filter = 2` (Ignore) so it never intercepts taps meant for the game world.
- Layer 10 puts the HUD above all game content.

---

## P11 — Dialogue Box

**Commit:** `feat(ui): add dialogue box with fictional + English lines (P11)`

### Files Created
| File | Purpose |
|------|---------|
| `ui/dialogue_box.gd` | Dialogue box logic |
| `ui/dialogue_box.tscn` | Dialogue box scene |
| `data/dialogue/episode_1.json` | Episode 1 dialogue lines |

### Scene Hierarchy
```
DialogueBox (PanelContainer, hidden at start)
└── VBoxContainer
    ├── OrangeLine (Label, centered)  — Orange's fictional speech
    └── EnglishLine (Label, centered) — English translation
```

### Public API (`dialogue_box.gd`)
```gdscript
class_name DialogueBox extends PanelContainer

func show_line(line_id: StringName, duration: float = 3.0) -> void
func show_text(text: String, duration: float = 3.0) -> void   ← added P13
```

Both methods share the same tween pattern:
`fade in 0.3s → hold duration → fade out 0.5s → hide`

`show_line` looks up `line_id` in the JSON dict and shows both language lines.
`show_text` shows arbitrary English text with no Orange line (used by `HintButton`).

### `_load_dialogue()` Safety
- `push_warning` + early return on any failure (file not found, cannot open, JSON parse error, wrong type).
- Never crashes the game.

### Dialogue Data (`data/dialogue/episode_1.json`)
```json
{
  "ep1.intro":               { "orange": "Mimi ruu...?",      "english": "The mushrooms are trying to show me something." },
  "ep1.mushroom_path_start": { "orange": "Oru ki raa!",       "english": "They glow differently... small to large, maybe?" },
  "ep1.mushroom_wrong":      { "orange": "Aa... na.",         "english": "That doesn't feel right. Let me look again." },
  "ep1.mushroom_solved":     { "orange": "Miru kalaa~",       "english": "They lit up! A path revealed itself in the rain." },
  "ep1.animal_tracks_start": { "orange": "Suu veri?",         "english": "So many tracks... one set is fresher than the rest." },
  "ep1.map_completed":       { "orange": "Miruu! Kalaa ruu!", "english": "The map... it's whole now. Where does it lead?" }
}
```

### Subscription
On `_ready`: `EventBus.dialogue_requested.connect(show_line)` — any system can trigger dialogue without knowing about the DialogueBox node.

---

## P12 — Floating Object Labels

**Commit:** `feat(ui): add floating object labels (P12)`

### Files Created
| File | Purpose |
|------|---------|
| `ui/floating_label.gd` | Floating label logic + auto-despawn |
| `ui/floating_label.tscn` | Label scene (mouse_filter=2) |
| `data/floating_labels/episode_1.json` | ID → display text map |

### `floating_label.gd`
```gdscript
class_name FloatingLabel extends Control

func show_label(text: String, world_pos: Vector2) -> void:
    _label.text = text
    call_deferred("_position_and_animate", world_pos)

func _position_and_animate(world_pos: Vector2) -> void:
    var screen_pos := get_viewport().get_canvas_transform() * world_pos
    global_position = screen_pos - Vector2(_label.size.x * 0.5, _label.size.y + 12.0)
    # fade in 0.2s → hold 1.5s → fade out 0.4s → queue_free()
```

- `call_deferred` for positioning: ensures the Label's computed size is available one frame after being added to the tree.
- World→screen conversion: `get_viewport().get_canvas_transform() * world_pos` (forward transform, not inverse).
- `queue_free()` at end of tween — no stale nodes accumulate.

### Integration in `interaction_manager.gd`
```gdscript
const _FLOATING_LABEL_SCENE := preload("res://ui/floating_label.tscn")
var _hud: Hud = null
var _label_data: Dictionary = {}

func _show_floating_label(interactable: Interactable) -> void:
    var text := _label_data.get(str(interactable.interactable_id), interactable.display_label)
    if text.is_empty(): return
    var label := _FLOATING_LABEL_SCENE.instantiate() as FloatingLabel
    _hud.add_floating_label(label)
    label.show_label(text, interactable.global_position)
```

Called at the start of `_handle_tap` — label appears on tap, before Orange walks over.

### Label Data (`data/floating_labels/episode_1.json`)
```json
{
  "ep1.mushroom_path":  "Mushroom Cluster",
  "ep1.animal_tracks":  "Animal Tracks",
  "ep1.raindrop_rhythm": "Rain-Soaked Stone",
  "ep1.wet_bark_symbol": "Carved Bark",
  "ep1.map.frag_1":     "Torn Map Piece",
  "ep1.map.frag_2":     "Torn Map Piece",
  "ep1.map.frag_3":     "Torn Map Piece",
  "ep1.map.frag_4":     "Torn Map Piece"
}
```

Fallback: if no JSON entry, `interactable.display_label` is used instead.

---

## P13 — Hint Button

**Commit:** `feat(ui): add one-level gentle hint button (P13)`

### Files Created
| File | Purpose |
|------|---------|
| `ui/hint_button.gd` | Hint button logic |
| `ui/hint_button.tscn` | Hint button scene (48×48 min) |
| `data/hints/episode_1.json` | Poetic hints for all 4 EP1 puzzles |
| `data/hints/episode_2_bridge.json` | Hint for bridge puzzle |

### Files Edited
| File | Change |
|------|--------|
| `ui/dialogue_box.gd` | Added `show_text(text, duration)` method |
| `episodes/zone.gd` | Added `HintButton` discovery + wiring in `_setup_hud` |
| `episodes/episode_1/zones/zone_1_forest_entry.tscn` | Added `HintButton` instance; load_steps 9→10 |

### `hint_button.gd`
```gdscript
class_name HintButton extends TextureButton

const _HINT_FILES: Dictionary = {
    "ep1":      "res://data/hints/episode_1.json",
    "ep2bridge": "res://data/hints/episode_2_bridge.json",
}

var _current_puzzle_id: StringName = &""
var _hint_data: Dictionary = {}
var _dialogue_box: DialogueBox = null
```

**State machine:**
- `puzzle_started` → sets `_current_puzzle_id`, enables button (`modulate.a = 1.0`, `disabled = false`).
- `puzzle_solved` → clears `_current_puzzle_id`, disables button (`modulate.a = 0.35`, `disabled = true`).
- No active puzzle → button is low-contrast and non-interactive.

**Hint flow:**
```
Player presses button
  └─► _on_pressed: EventBus.hint_requested.emit()
        └─► _on_hint_requested: looks up hint text for _current_puzzle_id
              └─► _dialogue_box.show_text(hint_text, 4.0)
```

`set_dialogue_box(box)` is called by `Zone._setup_hud()` — no direct coupling between `HintButton` and `DialogueBox` at construction time.

### Hint Loading
Uses an explicit `episode_id → filepath` dictionary instead of constructing a filename from `current_episode` — avoids the naming ambiguity between `ep1` (ID) and `episode_1.json` (file).

### Hint Data
```json
// episode_1.json
{
  "ep1.mushroom_path":   "The mushrooms remember a direction. Which one feels like a beginning?",
  "ep1.animal_tracks":   "The freshest trail is the one the forest hasn't had time to forget.",
  "ep1.raindrop_rhythm": "Watch the rain fall on each stone. It repeats, patient as water.",
  "ep1.wet_bark_symbol": "The bark holds a shape — the same shape scattered across what you've already found."
}

// episode_2_bridge.json
{
  "ep2bridge.sunlit_map": "Hold the map where the light is brightest. The forest will show you which way to turn."
}
```

### One-Level Guarantee
`HintButton` stores a **single** `_current_puzzle_id` and a single `_hint_data` dictionary. There is no tier, counter, or progression — pressing the button always shows the same one clue.

---

## P14 — Data Conventions (Resources)

**Commit:** `feat(data): add puzzle, fragment, and key item resource schemas (P14)`

### Files Created
| File | Class | Purpose |
|------|-------|---------|
| `puzzles/puzzle_definition.gd` | `PuzzleDefinition` | Gameplay data for one puzzle |
| `puzzles/fragment_reward.gd` | `FragmentReward` | Fragment reward tied to a puzzle |
| `key_items/key_item.gd` | `KeyItem` | Story-critical key item definition |
| `key_items/secret_map_card.tres` | — | Episode 1 key item instance |
| `key_items/mixed_compass.tres` | — | Episode 2 key item instance (forward placeholder) |

### `PuzzleDefinition extends Resource`
```gdscript
@export var puzzle_id:           StringName = &""
@export var display_name:        String = ""
@export var episode_id:          StringName = &""
@export var fragment_reward:     FragmentReward = null   # nested resource
@export var hint_text_key:       StringName = &""        # JSON key only
@export var intro_dialogue_key:  StringName = &""        # JSON key only
@export var solved_dialogue_key: StringName = &""        # JSON key only
```

### `FragmentReward extends Resource`
```gdscript
@export var fragment_id:  StringName = &""
@export var key_item_id:  StringName = &""
@export var frame_slot:   int = 0       # which slot in the mini frame to fill (0-based)
@export var art_path:     String = ""   # path to fragment illustration
```

### `KeyItem extends Resource`
```gdscript
@export var key_item_id:       StringName = &""
@export var display_name:      String = ""
@export var total_fragments:   int = 0
@export var frame_image_path:  String = ""
@export var description_key:   StringName = &""   # JSON key only
```

### `.tres` Instances
Both files use `script_class="KeyItem"` in the `[gd_resource]` header so Godot 4 resolves the class without a full project reimport.

```
secret_map_card.tres:
  key_item_id = &"key.secret_map_card"
  display_name = "Secret Map Card"
  total_fragments = 4

mixed_compass.tres:
  key_item_id = &"key.mixed_compass"
  display_name = "Mixed Compass"
  total_fragments = 4
```

### Data Convention Rule
| Data type | Format | Reason |
|-----------|--------|--------|
| Narrative text (dialogue, hints, labels) | JSON | Easy to edit without opening Godot; no reimport needed |
| Gameplay data (puzzles, fragments, key items) | Godot Resource (`.tres`) | Inspector editable; engine-typed; nested references |

---

## Cross-Cutting Decisions

### Coordinate Conversion
World↔screen conversion is done consistently throughout:
- **World → screen** (floating labels): `get_viewport().get_canvas_transform() * world_pos`
- **Screen → world** (interaction tap): `get_viewport().get_canvas_transform().affine_inverse() * screen_pos`
- Physics queries use `get_viewport().get_world_2d().direct_space_state` — accessible from a plain `Node`.

### `zone.gd` as a Growing Integration Point
`_setup_hud()` was extended across four prompts without ever editing a zone scene directly:

| Prompt | Addition |
|--------|----------|
| P10 | mount_action_button, set_action_button |
| P11 | mount_dialogue_box |
| P12 | set_hud (for floating labels) |
| P13 | mount_hint_button, set_dialogue_box |

All wiring uses `get_node_or_null("NodeName") as TypeHint` — safe to call in partial scenes.

### `_is_busy` in InteractionManager
Prevents double-handling rapid taps while Orange is walking. The flag is cleared after `await request_interaction` resolves, regardless of outcome.

### Tween Reuse Pattern
`DialogueBox`, `FloatingLabel` and `HintButton` (indirectly) all share the same tween pattern: kill existing tween → create new tween → fade in → hold → fade out → callback. This prevents ghost tweens from overlapping on rapid trigger.

---

## Pending Prompts

| Prompt | Module | Status |
|--------|--------|--------|
| P05 | Tap/Click Walkable Movement | Skipped (see note above) |
| P15 | Puzzle Framework (`PuzzleBase`) | Not started |
| P16 | Fragment Pickup | Not started |
| P17 | Mini Picture Frame | Not started |
| P18 | Key Item Inventory | Not started |
| P19 | Save System | Stub only |
| P20 | Episode Controller | Stub only |
| P21 | Episode 1 Zone Structure | Not started |
| P22 | Mushroom Path Puzzle | Not started |
| P23 | Animal Tracks Puzzle | Not started |
| P24 | Raindrop Rhythm Puzzle | Not started |
| P25 | Wet Bark Symbol Puzzle | Not started |
| P26 | Secret Map Card Completion | Not started |
| P27 | Episode 2 Bridge | Not started |
| P28 | Soft Transitions + End Card | Not started |
| P29 | Web Export | Not started |
| P30 | Final Integration Pass | Not started |

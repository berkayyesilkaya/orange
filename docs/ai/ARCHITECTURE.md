# Orange Architecture Guide

`prompts.md` is canonical. This guide summarizes the architecture that every coding agent must preserve.

## Folder Structure

Use the folder structure from `prompts.md` section 4 exactly.

Important top-level folders:

```text
res://globals/
res://characters/orange/
res://camera/
res://interaction/
res://ui/
res://puzzles/
res://fragments/
res://key_items/
res://data/dialogue/
res://data/hints/
res://data/floating_labels/
res://episodes/episode_1/
res://episodes/episode_2_bridge/
res://transitions/
res://art/
res://audio/
res://tests/
```

Do not use older alternative folders such as `project/autoload`, `core`, `systems`, or `managers` unless a prompt explicitly adds them.

## Autoloads

Required autoloads:

1. `Constants`
2. `EventBus`
3. `GameState`
4. `SaveSystem`
5. `EpisodeController`
6. `KeyItemInventory`

Autoload order matters. Follow `prompts.md`.

## EventBus Rule

`EventBus` contains global signals only. It must not contain gameplay logic.

Required global signals are defined in `prompts.md` section 5.2. Do not rename or add signals without a specific prompt.

## GameState Rule

`GameState` stores runtime state only. It does not write files by itself.

It should track:

- current episode.
- current zone.
- completed puzzles.
- collected fragments.
- owned key items.
- completed key items.
- flags.

## SaveSystem Rule

`SaveSystem` is the only module that reads/writes `user://save.json`.

Other modules request save by emitting `EventBus.save_requested(reason)`.

## Puzzle Flow Contract

Puzzle flow must remain:

1. Puzzle starts.
2. Player interacts.
3. Puzzle checks solution.
4. Puzzle marks solved.
5. Fragment is revealed.
6. Player manually collects fragment.
7. Mini frame updates.
8. Save is requested.
9. If all fragments are collected, key item is completed.

## Key Item Contract

Only fixed story key items are supported:

- `key.secret_map_card`
- `key.mixed_compass`

No generic inventory UI.

## Episode Prototype Contract

The prototype proves:

Episode 1 completes the Secret Map Card -> Episode 2 bridge requires and uses the Secret Map Card.

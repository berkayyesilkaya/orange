# Orange Prompts Clarifications

These clarifications keep `prompts.md` internally consistent. Use them when implementing prompts with coding agents.

## C01: `prompts.md` is Canonical

Use `prompts.md` as the main implementation plan. These clarifications do not replace it. They only resolve small ambiguities and prevent duplicate behavior.

## C02: InteractionManager Should Not Own Puzzle Lifecycle

In P09, the interaction system may detect that an interactable belongs to a puzzle, but it should not permanently own puzzle lifecycle.

Preferred rule:

- `InteractionManager` detects object interaction and dispatches the relevant action to the target object or puzzle node.
- `PuzzleBase.start_puzzle()` owns `EventBus.puzzle_started`.
- `PuzzleBase.mark_solved()` owns `puzzle_solved` and `fragment_revealed`.

Avoid emitting `puzzle_started` twice.

## C03: SaveSystem Should Avoid Duplicate Saves

P16 and P18 request saves through `EventBus.save_requested`. Therefore in P19, the cleanest implementation is:

- `SaveSystem` listens to `EventBus.save_requested`.
- Other modules emit `save_requested` after meaningful changes.

If `SaveSystem` also listens to `fragment_collected`, protect against duplicate writes in the same frame. The preferred approach is one save path: `save_requested` only.

## C04: FragmentPickup Should Reuse the Interaction Contract

Fragment pickups should behave like interactables without creating a second incompatible interaction system.

Preferred rule:

- Fragment pickup is an `Area2D` compatible with `InteractionManager`.
- It shows the contextual action button label `Collect`.
- It emits `fragment_collected` only after the player presses the action button.

Never auto-collect fragments.

## C05: Episode Transition Ownership

P20 and P26 both mention the Secret Map Card completion transition. To avoid duplicated scene changes:

- `MapCompletionTrigger` or the completion listener plays the short celebration moment.
- After the celebration, it emits `EventBus.zone_change_requested(bridge_zone_path)`.
- `EpisodeController` is the only module that actually changes scenes.

No other script should call `change_scene_to_file` directly for this transition.

## C06: Web Export Preset and `.gitignore`

P01 says `.gitignore` excludes `export_presets.cfg`, while P29 creates a web export preset. Choose one consistent policy before implementation.

Recommended solo policy:

- Commit `export_presets.cfg` only if it contains no secrets and helps reproducible web export.
- If committing it, remove `export_presets.cfg` from `.gitignore` in the same P29 commit and explain why.
- Never commit platform secrets or private signing credentials.

## C07: Prototype Art Is Placeholder-Friendly

Prompt agents should not block progress because final art is missing.

Allowed for prototype:

- simple placeholder sprites,
- readable colored rectangles,
- basic tile shapes,
- basic icons,
- simple charming visual feedback.

Do not spend implementation prompts on final polish unless the prompt explicitly asks.

## C08: Sound Puzzle Accessibility

Raindrop rhythm may use sound, but must also have visual timing indicators.

Whispering branches belongs to the future Episode 3, not the first prototype.

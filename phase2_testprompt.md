# Orange — Phase 2 QA Audit Prompt (for Claude Opus)

> Paste this entire document, plus `prompts.md`, `phase2_prompts.md`, and the two LaTeX reports (`Orange_Creative.tex` and `Orange_VisualandTechnical.tex`), into a fresh Claude Opus session. Point Opus at the repository checkout. Opus's job is to **audit** the Phase 2 implementation, not to rewrite it.

---

## 0. Role and Mandate

You are **Claude Opus**, acting as the **lead reviewer, systems auditor, and repair planner** for the *Orange* Phase 2 implementation.

Your mandate is to:

1. Read and internalize:
   - `Orange_Creative.tex` (story arc, Episode 2 puzzle intent, emotional themes).
   - `Orange_VisualandTechnical.tex` (visual, technical, and production direction).
   - `prompts.md` (Phase 1 canonical plan, P01–P30).
   - `phase2_prompts.md` (Phase 2 canonical plan, P31–P42).
2. Inspect the actual repository.
3. Identify gaps, defects, regressions, architectural drift, and inconsistencies with the source documents.
4. Produce a **prioritized bug report**, a **repair plan**, and **targeted fix prompts** for smaller coding agents.
5. Verify that Phase 1 still passes end-to-end after Phase 2 changes (non-regression).
6. **Do not rewrite the project.** Prefer surgical, well-scoped fixes.

---

## 1. Inputs You Must Read Before Reviewing

1. `Orange_Creative.tex` — Episode 2 narrative, puzzle intent, emotional arc, fictional language.
2. `Orange_VisualandTechnical.tex` — engine, visual style, UI rules, save rules, prototype scope.
3. `prompts.md` — Phase 1 rules (sections 1–7) and prompts P01–P30.
4. `phase2_prompts.md` — Phase 2 rules (sections 1–11) and prompts P31–P42.
5. The repository on disk:
   - `project.godot`, `globals/`, `characters/`, `camera/`, `interaction/`, `ui/`, `puzzles/`, `fragments/`, `key_items/`, `data/`, `episodes/`, `transitions/`.
   - `episodes/episode_2/` — all four zones, four puzzles, four definitions.
   - `episodes/episode_2_bridge/zones/zone_sunlit_clearing.tscn` — confirm PrototypeEndCard is removed.
   - `ui/ep2_end_card.tscn`, `ui/ep2_end_card.gd`.
   - `data/dialogue/episode_2.json`, `data/hints/episode_2.json`, `data/floating_labels/episode_2.json`.
6. `git log` — confirm P31–P42 commits are present.

Note any missing inputs at the top of your report.

---

## 2. Review Procedure

Perform the review in this order:

1. **Repository orientation:** map files against `phase2_prompts.md` section 5 (folder structure). Note missing or misplaced files.
2. **Constants audit:** confirm all new constants from P31 are present in `globals/constants.gd`.
3. **Data audit:** confirm three new JSON files exist, are valid JSON, and contain the correct keys from `phase2_prompts.md` sections 10.1–10.3.
4. **Resource audit:** confirm four new `.tres` files in `episodes/episode_2/definitions/` with correct `puzzle_id`, `fragment_id`, and `frame_slot` values.
5. **Core system integration audit:** verify `EpisodeController`, `zone.gd`, `HintButton`, `InteractionManager`, and `DialogueBox` changes from P32, P35, P36.
6. **Bridge zone audit:** confirm `zone_sunlit_clearing.tscn` has no `EndCardLayer` or `PrototypeEndCard`. Confirm `EpisodeController` listens to `key_item_used` and transitions to `ep2.zone_1`.
7. **Per-puzzle audit:** for each of the four Episode 2 puzzles, check the lifecycle, signal connections, and solve condition (section 4.8 below).
8. **End card audit:** verify `Ep2EndCard` appears only on `key_item_completed(&"key.mixed_compass")` and the Play Again flow resets correctly.
9. **Phase 1 non-regression audit:** confirm Episode 1 and bridge zone still work end-to-end.
10. **Per-flow audit:** walk the Episode 2 flow checklist (section 5).
11. **Static issue scan:** unsafe casts, race conditions in `await` chains, prefix collision risks, duplicate signal connections.
12. **Compose bug report** (section 7 format).
13. **Compose repair plan** (section 8 format).
14. **Compose targeted fix prompts** (section 9 format).

Do **not** modify any files. Output is a written audit only.

---

## 3. Cross-Cutting Review Goals

Evaluate the Phase 2 implementation against all of the following:

- **Architecture consistency:** no new autoloads, no new global signals, folder layout matches `phase2_prompts.md` section 5.
- **Prefix safety:** `"ep2bridge"` is checked before `"ep2."` in every string prefix test in `episode_controller.gd` and `zone.gd`.
- **Auto-start pattern:** each Episode 2 puzzle calls `start_puzzle()` in its own `_ready()` if `_state == State.INACTIVE`. It must call `super()` first.
- **action_dispatched routing:** ep2 sub-interactables (IDs like `"ep2.sun_reflection.stone_1"`) are not in `_dispatch_action`'s puzzle list and correctly flow through `action_dispatched`. Each puzzle scene connects to `InteractionManager.action_dispatched` in its `_ready()`.
- **Solved state guard:** ep2 puzzles must not connect to `action_dispatched` when `_state == State.SOLVED`.
- **Cozy design:** wrong answers show dialogue; never punish with a hard reset (except Rock Water which resets the sequence only, not the puzzle state).
- **Save correctness:** save fires after each of the 4 Mixed Compass fragment collections. No mid-puzzle saves.
- **MiniFrame slot order:** `frame_slot` 0→1→2→3 matches zone 1→2→3→4 order.
- **key_item_completed guard:** `Ep2EndCard` must only react to `&"key.mixed_compass"`, not to `&"key.secret_map_card"`.
- **Phase 1 preservation:** Episode 1 puzzles, save flow, and bridge zone must behave identically to Phase 1 (modulo the bridge zone now transitioning to ep2 instead of showing the end card).
- **Web readiness:** the Phase 2 additions must not break audio gating, touch input, or HUD scaling inherited from Phase 1.

---

## 4. Checklist by System

For each item, mark **PASS / FAIL / PARTIAL / N/A** and add a one-line note.

### 4.1 Constants (P31)
- [ ] `PUZZLE_SUN_REFLECTION = &"ep2.sun_reflection"` exists.
- [ ] `PUZZLE_WATER_FLOW = &"ep2.water_flow"` exists.
- [ ] `PUZZLE_MIST_SYMBOL = &"ep2.mist_symbol"` exists.
- [ ] `PUZZLE_ROCK_WATER = &"ep2.rock_water"` exists.
- [ ] `FRAG_COMPASS_1` through `FRAG_COMPASS_4` exist with correct values.
- [ ] `ZONE_EP2_1` through `ZONE_EP2_4` exist with correct values.
- [ ] All Phase 1 constants are unchanged.

### 4.2 JSON Data (P32)
- [ ] `data/dialogue/episode_2.json` exists and is valid JSON with all 14 keys from `phase2_prompts.md` section 10.1.
- [ ] `data/hints/episode_2.json` exists and is valid JSON with 4 keys.
- [ ] `data/floating_labels/episode_2.json` exists and is valid JSON with 16 keys.
- [ ] `HintButton._HINT_PATHS` includes `"res://data/hints/episode_2.json"`.
- [ ] `InteractionManager._LABEL_PATHS` includes `"res://data/floating_labels/episode_2.json"`.
- [ ] `DialogueBox` (or equivalent) loads all episode dialogue files at startup (array pattern, not single-episode load).
- [ ] No gameplay state in any JSON file.

### 4.3 Resource Definitions (P33)
- [ ] All four `.tres` files exist in `episodes/episode_2/definitions/`.
- [ ] Each `.tres` has the correct `puzzle_id`, `episode_id`, `fragment_reward.fragment_id`, `fragment_reward.key_item_id`, and `fragment_reward.frame_slot`.
- [ ] `frame_slot` values are 0, 1, 2, 3 for zones 1, 2, 3, 4 respectively.
- [ ] `key_item_id = &"key.mixed_compass"` on all four `FragmentReward` sub-resources.

### 4.4 Zone Scenes (P34)
- [ ] All four ep2 zone `.tscn` files exist.
- [ ] Each zone root has `zone.gd` script and correct `zone_id` export.
- [ ] Zones 1–3 have a `ZoneExit` with correct `target_zone_id`.
- [ ] Zone 4 has no `ZoneExit`.
- [ ] Each zone instances HUD, ActionButton, DialogueBox, HintButton, InteractionManager.
- [ ] Each zone has an `Interactables` node (puzzle scenes instanced under it in P37–P40).

### 4.5 Core System Integration (P35)
- [ ] `EpisodeController._ZONE_PATHS` contains all four ep2 zone paths.
- [ ] `EpisodeController._EPISODE_KEY_ITEMS` maps `&"ep2"` → `"res://key_items/mixed_compass.tres"`.
- [ ] `_on_node_added` checks `"ep2bridge"` before `"ep2."` (dot-prefixed) before `"ep1"`.
- [ ] `zone.gd._ready()` checks `"ep2bridge"` before `"ep2."` before `"ep1"`.
- [ ] `InteractionManager._dispatch_action` is NOT modified for ep2 sub-interactables (they use the `action_dispatched` else-branch).

### 4.6 Bridge Zone Transition (P36)
- [ ] `zone_sunlit_clearing.tscn` does NOT contain `EndCardLayer` or `PrototypeEndCard`.
- [ ] `EpisodeController._ready()` connects to `EventBus.key_item_used`.
- [ ] `_on_key_item_used` transitions to `ep2.zone_1` when `key_item_id == &"key.secret_map_card"` and `context == &"sunlit_clearing"`.
- [ ] `prototype_end_card.tscn` and `prototype_end_card.gd` still exist on disk (not deleted).
- [ ] Soft fade plays on the bridge → ep2 transition.

### 4.7 Episode 2 Puzzle Architecture (general, P37–P40)
- [ ] Each puzzle class calls `super()` in `_ready()` before any other logic.
- [ ] Each puzzle calls `start_puzzle()` only when `_state == State.INACTIVE`.
- [ ] Each puzzle connects to `InteractionManager.action_dispatched` only when `_state == State.ACTIVE`.
- [ ] Each puzzle's `_on_action_dispatched` filters by its own id prefix before processing.
- [ ] `mark_solved()` is guarded against double-calls by PuzzleBase (idempotent).
- [ ] `_on_already_solved()` hides interactive elements and disconnects from `action_dispatched`.
- [ ] HintButton is active during each puzzle and shows the correct hint text.

### 4.8 Individual Puzzles

#### Sun Reflection (P37)
- [ ] Three stones; action "Rotate"; rotation wraps mod 4.
- [ ] All-correct check fires after every rotate, not just the third.
- [ ] Exported `correct_rotation_stone1/2/3` — not hardcoded.
- [ ] Solve reveals `frag_1`; MiniFrame slot 0 fills.

#### Water Flow Path (P38)
- [ ] Three channels toggle open/closed; action label updates dynamically.
- [ ] Confirm interactable "Send Water" checks state, not order.
- [ ] Wrong answer shows dialogue, no state reset.
- [ ] Expected open channels are exported (`expected_open: Array[StringName]`) — not hardcoded.
- [ ] Solve reveals `frag_2`; MiniFrame slot 1 fills.

#### Mist Symbol (P39)
- [ ] Four panels; action "Examine".
- [ ] `ReferenceSymbol` is not an Interactable (no action button appears on tap).
- [ ] Wrong panel shows dialogue; correct panel solves.
- [ ] `correct_panel` is exported — not hardcoded.
- [ ] Solve reveals `frag_3`; MiniFrame slot 2 fills.

#### Rock Water (P40)
- [ ] Four marks; action "Touch"; tapped in lowest-to-highest order.
- [ ] Wrong order resets `_tapped_sequence` and shows dialogue.
- [ ] `expected_order` is exported — not hardcoded.
- [ ] Solve reveals `frag_4`; MiniFrame slot 3 fills.
- [ ] Filling slot 3 fires `key_item_completed(&"key.mixed_compass")`.

### 4.9 Mixed Compass Completion and End Card (P41)
- [ ] `Ep2EndCard` is on a `CanvasLayer` (layer 64) in zone 4.
- [ ] `Ep2EndCard` is hidden on `_ready()`.
- [ ] `Ep2EndCard` appears only on `key_item_completed(&"key.mixed_compass")`.
- [ ] `Ep2EndCard` does NOT appear on `key_item_completed(&"key.secret_map_card")`.
- [ ] Pressing "Play Again" shows the confirm panel.
- [ ] Pressing "Yes" wipes the save, resets GameState, and transitions to ep1.zone_1.
- [ ] Pressing "No" hides the confirm panel.
- [ ] `ep2.compass_completed` dialogue line is shown exactly once (not duplicated by CompletionTrigger and EndCard both emitting it).
- [ ] `SaveSystem.wipe()` does not crash if the save file is missing.

### 4.10 Phase 1 Non-Regression
- [ ] Episode 1 zones 1–4 load without errors.
- [ ] All four Episode 1 puzzles still solve correctly.
- [ ] Secret Map Card completion still plays celebration and transitions to bridge zone.
- [ ] Bridge zone: owning the Secret Map Card allows solve; not owning it blocks.
- [ ] Bridge solve now transitions to ep2.zone_1 (not the old PrototypeEndCard).
- [ ] Save/load across Episode 1 still works correctly.
- [ ] MiniFrame in ep1 zones still shows Secret Map Card (not Mixed Compass).

### 4.11 Save / Load (Phase 2)
- [ ] Save fires after each of 4 Mixed Compass fragment collections.
- [ ] Reloading mid-Episode-2 restores the correct zone.
- [ ] Reloading restores MiniFrame slot state for completed zones.
- [ ] Reloading restores which puzzles are completed (completed puzzles skip auto-start solve).
- [ ] "Play Again" wipes the save file completely.

---

## 5. Checklist by Episode 2 Flow

Walk the prototype on a **fresh save**, starting from Episode 1 and continuing through Episode 2. For each step, mark PASS / FAIL / PARTIAL.

### 5.1 Bridge to Episode 2 Transition
- [ ] Completing the bridge puzzle fires `key_item_used(&"key.secret_map_card", &"sunlit_clearing")`.
- [ ] EpisodeController emits `zone_change_requested` for ep2.zone_1.
- [ ] Soft fade plays.
- [ ] ep2.zone_1 loads; OrangeCharacter appears; HUD shows Mixed Compass MiniFrame (all empty).
- [ ] HintButton becomes active (Sun Reflection puzzle auto-started).

### 5.2 Zone 1 — Sun Reflection Puzzle
- [ ] Tapping each stone shows the "Rotate" action button.
- [ ] Pressing "Rotate" visually rotates the stone by 90°.
- [ ] Rotating all three to correct values solves the puzzle.
- [ ] HintButton shows the correct hint; not the answer.
- [ ] Fragment 1 appears and can be manually collected.
- [ ] Collecting fragment 1 fills MiniFrame slot 0 and triggers a save.
- [ ] Walking to the zone exit transitions to zone 2 with soft fade.

### 5.3 Zone 2 — Water Flow Path Puzzle
- [ ] Tapping a channel shows "Open" or "Close" based on current state.
- [ ] Pressing the action button toggles the channel and updates the label.
- [ ] Pressing "Send Water" with wrong combination shows gentle dialogue; channels unchanged.
- [ ] Pressing "Send Water" with correct combination solves.
- [ ] Fragment 2 collected; MiniFrame slot 1 fills; save fires.
- [ ] Zone exit to zone 3 works.

### 5.4 Zone 3 — Mist Symbol Puzzle
- [ ] Tapping the ReferenceSymbol does NOT show an action button.
- [ ] Tapping a panel shows "Examine".
- [ ] Wrong panel: gentle dialogue, no state change.
- [ ] Correct panel: solve.
- [ ] Fragment 3 collected; MiniFrame slot 2 fills; save fires.
- [ ] Zone exit to zone 4 works.

### 5.5 Zone 4 — Rock Water Puzzle
- [ ] Tapping marks in correct order (A → B → C → D) solves.
- [ ] Tapping out of order resets the sequence with dialogue.
- [ ] Solve reveals fragment 4.
- [ ] Fragment 4 collected; MiniFrame slot 3 fills; save fires.

### 5.6 Mixed Compass Completion
- [ ] `key_item_completed(&"key.mixed_compass")` fires once.
- [ ] `ep2.compass_completed` dialogue line shows.
- [ ] Ep2EndCard fades in with the Orange line and English ending.
- [ ] No zone exit in zone 4 (player cannot accidentally exit).

### 5.7 Episode 2 End Card
- [ ] Orange line: "RUUU!" visible.
- [ ] English line: "The compass is ready. The river awaits. To be continued." visible.
- [ ] "Play Again" button visible.
- [ ] Pressing "Play Again" shows confirmation.
- [ ] "Yes" wipes save, resets to ep1.zone_1 with empty MiniFrame and no completed puzzles.
- [ ] "No" dismisses confirmation.

### 5.8 Save Persistence (Episode 2)
- [ ] Closing and reopening after zone 1 solve: zone 1 loads; slot 0 filled; puzzle solved (stones inert).
- [ ] Closing and reopening after zone 2 solve: zone 2 loads; slots 0–1 filled.
- [ ] Closing and reopening after zone 3 solve: zone 3 loads; slots 0–2 filled.
- [ ] Closing and reopening after zone 4 solve but before collecting frag_4: zone 4 loads; puzzle solved but fragment not yet collected; slot 3 empty.
- [ ] After collecting frag_4 and reopening: slot 3 filled.

---

## 6. LaTeX Fidelity Audit (Episode 2)

Compare the Episode 2 implementation against the source documents.

### 6.1 Story and Tone (`Orange_Creative.tex`)
- [ ] Episode 2 is sunlit, hopeful — distinct from Episode 1's rain/curiosity tone.
- [ ] Each puzzle connects thematically to sunlight and water (sun reflection, water flow, mist, rock erosion by water).
- [ ] Orange's fictional speech (`"Muu ruu wa!"`, `"RUUU!"`, etc.) is present and consistent in length and character with Episode 1 speech.
- [ ] English translations are poetic and brief, not expository.
- [ ] The Mixed Compass reward carries emotional weight as a symbol of hope and direction.

### 6.2 Visual and Technical (`Orange_VisualandTechnical.tex`)
- [ ] Episode 2 zones use the same pixel-art, isometric style conventions as Episode 1.
- [ ] No new shader systems, particle storms, or rendering changes introduced.
- [ ] Puzzle visuals are clear and readable without audio.
- [ ] Puzzle clues (stone rotation arrows, channel open/closed indicators, panel symbols, height marks) are visually distinguishable — no ambiguity.
- [ ] UI remains minimal: one action button, one hint, one mini frame.
- [ ] No new autoloads, no new global signals, no new menu systems.

---

## 7. Bug Report Format

For every defect, output a block in this exact shape:

```
[BUG-###]
Title: <short imperative description>
Severity: Critical | High | Medium | Low
System: <Globals | Character | Interaction | UI | Puzzles | Fragments | Key Items | Save | Episodes | Web Export | Tone>
Location: <file path : line range, or scene path>
Observed: <what is happening>
Expected: <what should happen, citing phase2_prompts.md prompt ID or LaTeX section>
Repro Steps:
  1. ...
  2. ...
Likely Root Cause: <one-paragraph hypothesis>
Suggested Fix: <one paragraph; reference the smallest module that should change>
References: <e.g. phase2_prompts.md P37; Orange_Creative.tex §"Episode 2 Puzzles">
```

Number bugs `BUG-001`, `BUG-002`, … in the order found.

### 7.1 Severity Definitions

- **Critical:** Episode 2 cannot be completed end-to-end. Examples: bridge → ep2 transition crashes, Mixed Compass never completes, `key_item_completed` never fires, Play Again corrupts save.
- **High:** A puzzle, signal, or save behavior is wrong but the prototype still mostly runs. Examples: HintButton shows wrong hint in ep2, fragments collected out of slot order, `_tapped_sequence` not reset on wrong Rock Water input.
- **Medium:** Tone, naming, or modularity drift. Examples: hardcoded correct values instead of exported variables, dialogue keys missing from JSON, wrong zone_id on a zone scene.
- **Low:** Cosmetic or minor cleanup. Examples: unused exports, stray `print()` calls, placeholder art left in wrong folder.

---

## 8. Repair Plan Format

After the bug report, produce:

```
## Repair Plan

### Phase 1 — Critical fixes (must land before any playtest)
- BUG-### — <one line>

### Phase 2 — High-priority fixes
- BUG-### — <one line>

### Phase 3 — Medium fixes
- BUG-### — <one line>

### Phase 4 — Low-priority polish
- BUG-### — <one line>

### Phase 5 — Optional improvements (only if Phase 1–4 are clean)
- <e.g. "Add visual progress highlight for Rock Water marks already tapped correctly">
```

Order phases strictly by severity. Within a phase, order by dependency.

A rewrite recommendation requires a **Rewrite Justification** section with:
- which modules are unsalvageable,
- why surgical fixes will not work,
- the smallest possible rewrite scope (specific phase2_prompts.md prompt IDs to re-run).

---

## 9. Targeted Fix Prompts for Smaller Coding Agents

For each bug or coherent cluster, produce a fix prompt in the same shape as `phase2_prompts.md` implementation prompts:

```
## Fix Prompt FX2-###

- Fix Prompt ID: FX2-###
- Targets: BUG-###, BUG-###
- Module name: <existing module being repaired>
- Goal: <one-paragraph problem statement>
- Context from previous modules: <which phase2_prompts.md prompt established this code>
- Files to edit: <explicit paths>
- Files NOT to edit: <explicit paths or "everything outside the listed files">
- Required changes: <bulleted list, precise>
- Required preservations: <what must keep working>
- Acceptance criteria: <bulleted, testable>
- Manual test steps: <numbered>
- Common failure cases to avoid:
  - Do not introduce new autoloads.
  - Do not rename signals.
  - Do not refactor neighboring modules.
- Git commit message: `fix(<scope>): <imperative summary> (FX2-###)`
```

Rules for fix prompts:
1. Each fix prompt addresses one defect or one tightly coupled cluster.
2. Each fix prompt names exactly which files may be edited and forbids others.
3. Fix prompts must not request new features.
4. Fix prompts must not change autoload names, signal names/signatures, or folder structure.
5. Fix prompts use `FX2-###` numbering (distinct from Phase 1 `FX-###`).

---

## 10. Things You Are Not Allowed To Do

- Do **not** rewrite the project unless you produce a Rewrite Justification (see section 8).
- Do **not** introduce new architecture (new autoloads, new signals, new folders, new languages).
- Do **not** expand scope beyond Episode 2 (no Episode 3, no Teleportation Door, no new episodes).
- Do **not** add combat, multiplayer, quest systems, large inventory, settings menus, or save slots.
- Do **not** add multi-tier hints.
- Do **not** add C# code.
- Do **not** make any puzzle solvable only by sound.
- Do **not** edit the LaTeX reports.
- Do **not** silently fix things — every issue must produce a `BUG-###` entry.
- Do **not** delete code without citing its origin prompt.

---

## 11. Output Order

Your final report must be organized in this exact order:

1. **Executive Summary** (5–10 lines): overall health of Phase 2, biggest risks, whether the Episode 2 flow is playable end-to-end, and whether Phase 1 is intact.
2. **Repository Inventory:** what was found vs. what `phase2_prompts.md` expects.
3. **System Checklist Results** (section 4, filled in).
4. **Episode 2 Flow Checklist Results** (section 5, filled in).
5. **LaTeX Fidelity Findings** (section 6).
6. **Phase 1 Non-Regression Summary** (brief — state PASS/FAIL for each item in section 4.10).
7. **Bug Report** (`BUG-001` … using section 7 format).
8. **Repair Plan** (section 8 format).
9. **Targeted Fix Prompts** (`FX2-001` … using section 9 format).
10. **Rewrite Justification** if and only if applicable.
11. **Appendix:** tone notes, out-of-scope improvement ideas (clearly labeled "OUT OF SCOPE").

Keep the writing precise and surgical. Every change you recommend must be justified, scoped, and testable.

class_name PuzzleBase
extends Node2D

# Shared lifecycle base for all puzzles.
# Concrete puzzles must be Node2D scenes that `extends PuzzleBase`.
# Only one file is created/edited by P15.

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

enum State { INACTIVE, ACTIVE, SOLVED }

var _state: State = State.INACTIVE

@export var definition: PuzzleDefinition = null


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# If this puzzle was already solved in a previous session, stay inactive
	# so the concrete subclass never runs its logic again.
	if definition == null:
		push_warning("PuzzleBase (%s): `definition` is null — puzzle cannot start." % name)
		return

	if GameState.is_puzzle_completed(definition.puzzle_id):
		_state = State.SOLVED
		_on_already_solved()


# Called by the InteractionManager (or directly in tests) to activate the puzzle.
func start_puzzle() -> void:
	if definition == null:
		push_error("PuzzleBase (%s): cannot start — `definition` is null." % name)
		return

	# Idempotency: ignore if already active or solved.
	if _state != State.INACTIVE:
		return

	_state = State.ACTIVE
	EventBus.puzzle_started.emit(definition.puzzle_id)

	# Optionally request an intro dialogue line.
	if definition.intro_dialogue_key != &"":
		EventBus.dialogue_requested.emit(definition.intro_dialogue_key)


# ---------------------------------------------------------------------------
# Virtual hook — subclasses override this to check input / conditions.
# Call `mark_solved()` from inside this method when the solution is valid.
# ---------------------------------------------------------------------------

func _on_solution_attempt() -> void:
	pass  # Override in subclasses.


# ---------------------------------------------------------------------------
# Called by _on_already_solved when _ready detects the puzzle is complete.
# Override in subclasses to hide interactive elements, etc.
# ---------------------------------------------------------------------------

func _on_already_solved() -> void:
	pass  # Optional override.


# ---------------------------------------------------------------------------
# Marks the puzzle as solved.  Built-in idempotency: calling this twice is a
# no-op after the first call.
# ---------------------------------------------------------------------------

func mark_solved() -> void:
	# Guard: must be ACTIVE (not INACTIVE and not already SOLVED).
	if _state == State.SOLVED:
		return  # Idempotency — silent no-op.

	if _state == State.INACTIVE:
		push_warning("PuzzleBase (%s): mark_solved() called while INACTIVE." % name)
		return

	_state = State.SOLVED

	# 1. Persist to runtime state (SaveSystem writes to disk — P19).
	GameState.mark_puzzle_completed(definition.puzzle_id)

	# 2. Notify the world.
	EventBus.puzzle_solved.emit(definition.puzzle_id)

	# 3. Reveal the associated fragment (if the definition carries one).
	if definition.fragment_reward != null:
		EventBus.fragment_revealed.emit(
			definition.puzzle_id,
			definition.fragment_reward.fragment_id
		)

	# 4. Optionally request a solved dialogue line.
	if definition.solved_dialogue_key != &"":
		EventBus.dialogue_requested.emit(definition.solved_dialogue_key)

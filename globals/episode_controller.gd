class_name EpisodeController
extends Node

# ---------------------------------------------------------------------------
# EpisodeController — the single authority for scene transitions and episode
# state.  Only this module calls get_tree().change_scene_to_file().
#
# Startup sequence:
#   1. _ready → SaveSystem.load()
#   2. If save was found, GameState already has current_episode / current_zone.
#      Otherwise, defaults are set here.
#   3. zone_change_requested → switch scene.
#   4. Whenever a Hud appears in the scene tree, mount the right MiniFrame.
#   5. key_item_completed(&"key.secret_map_card") → emit zone_change_requested
#      for the ep2 bridge zone (C05: EpisodeController is the ONLY module
#      that changes scenes).
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Scene path registry — centralised so no other script has a hardcoded path.
# ---------------------------------------------------------------------------
const _ZONE_PATHS: Dictionary = {
	&"ep1.zone_1":                   "res://episodes/episode_1/zones/zone_1_forest_entry.tscn",
	&"ep1.zone_2":                   "res://episodes/episode_1/zones/zone_2_mushroom_grove.tscn",
	&"ep1.zone_3":                   "res://episodes/episode_1/zones/zone_3_muddy_path.tscn",
	&"ep1.zone_4":                   "res://episodes/episode_1/zones/zone_4_bark_clearing.tscn",
	&"ep2bridge.zone_sunlit_clearing": "res://episodes/episode_2_bridge/zones/zone_sunlit_clearing.tscn",
}

# ---------------------------------------------------------------------------
# Episode → KeyItem resource path mapping.
# ---------------------------------------------------------------------------
const _EPISODE_KEY_ITEMS: Dictionary = {
	&"ep1":       "res://key_items/secret_map_card.tres",
	&"ep2bridge": "res://key_items/mixed_compass.tres",
}

var current_episode_id: StringName = &"ep1"

# Reference to the currently live MiniFrame node (if any).
var _mini_frame: MiniFrame = null

# Lazily resolved reference to the persistent SoftTransition overlay.
var _transition: SoftTransition = null


func _ready() -> void:
	# 1. Load saved state (populates GameState).
	var loaded := SaveSystem.load()
	if not loaded:
		# Fresh run — set defaults.
		GameState.current_episode = &"ep1"
		GameState.current_zone    = &"ep1.zone_1"

	current_episode_id = GameState.current_episode

	# 2. Subscribe to global signals.
	EventBus.zone_change_requested.connect(_on_zone_change_requested)
	# 3. Boot the persistent SoftTransition overlay.
	_boot_soft_transition()
	# 4. Watch the scene tree so we can mount MiniFrame whenever a Hud appears.
	get_tree().node_added.connect(_on_node_added)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Update the active episode and rebind the MiniFrame to the matching KeyItem.
func set_episode(episode_id: StringName) -> void:
	current_episode_id = episode_id
	GameState.current_episode = episode_id
	_bind_mini_frame_for_episode(episode_id)


# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------

func _on_zone_change_requested(zone_path: String) -> void:
	if not ResourceLoader.exists(zone_path):
		push_error("EpisodeController: zone scene not found at '%s'." % zone_path)
		return
	_change_scene_faded(zone_path)


func _change_scene_faded(zone_path: String) -> void:
	if is_instance_valid(_transition):
		await _transition.play_out()
	# Clear MiniFrame reference — the new scene will add a fresh Hud.
	_mini_frame = null
	get_tree().change_scene_to_file(zone_path)
	# Fade back in once the new scene is initialised.
	if is_instance_valid(_transition):
		await get_tree().process_frame
		_transition.play_in()


func _boot_soft_transition() -> void:
	var st_scene := load("res://transitions/soft_transition.tscn") as PackedScene
	if st_scene == null:
		push_error("EpisodeController: could not load soft_transition.tscn.")
		return
	_transition = st_scene.instantiate() as SoftTransition
	# Add to root so the overlay survives all scene changes.
	get_tree().root.call_deferred("add_child", _transition)


## Called whenever any node enters the scene tree.
## Detects a freshly loaded Zone and rebinds the episode, then mounts MiniFrame when a Hud appears.
func _on_node_added(node: Node) -> void:
	if node is Zone:
		var zid := str((node as Zone).zone_id)
		if zid.begins_with("ep2bridge"):
			set_episode(&"ep2bridge")
		elif zid.begins_with("ep1"):
			set_episode(&"ep1")

	if not (node is Hud):
		return
	var hud := node as Hud
	# Small deferral so the Hud node finishes its own _ready before we add children.
	call_deferred("_mount_mini_frame_for_hud", hud)


# ---------------------------------------------------------------------------
# MiniFrame binding
# ---------------------------------------------------------------------------

func _mount_mini_frame_for_hud(hud: Hud) -> void:
	if not is_instance_valid(hud):
		return

	# Build a fresh MiniFrame and mount it into the HUD slot.
	var mini_frame_scene := load("res://ui/mini_frame.tscn") as PackedScene
	if mini_frame_scene == null:
		push_error("EpisodeController: could not load mini_frame.tscn.")
		return

	var mini_frame := mini_frame_scene.instantiate() as MiniFrame
	_mini_frame = mini_frame
	hud.mount_mini_frame(mini_frame)

	# Bind to the correct KeyItem for the current episode.
	_bind_mini_frame_for_episode(current_episode_id)


func _bind_mini_frame_for_episode(episode_id: StringName) -> void:
	if not is_instance_valid(_mini_frame):
		return

	var item_path: String = _EPISODE_KEY_ITEMS.get(episode_id, "")
	if item_path.is_empty() or not ResourceLoader.exists(item_path):
		push_warning("EpisodeController: no KeyItem resource for episode '%s'." % episode_id)
		return

	var item := load(item_path) as KeyItem
	if item:
		_mini_frame.set_key_item(item)


# ---------------------------------------------------------------------------
# Helper — converts a zone_id to its scene file path (used by other modules).
# ---------------------------------------------------------------------------
func zone_path_for_id(zone_id: StringName) -> String:
	return _ZONE_PATHS.get(zone_id, "")

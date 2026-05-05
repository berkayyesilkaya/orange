extends Node

# Attach to a zone root that has:
#   OrangeCharacter node
#   Interactables/InteractableA  (Interactable, interactable_id = &"test.a", interaction_position = Vector2(-30, 0))
#   Interactables/InteractableB  (Interactable, interactable_id = &"test.b", interaction_position = Vector2(30, 0))

@onready var orange: OrangeCharacter = get_parent().get_node("OrangeCharacter")
@onready var interactable_a: Interactable = get_parent().get_node("Interactables/InteractableA")
@onready var interactable_b: Interactable = get_parent().get_node("Interactables/InteractableB")


func _ready() -> void:
	interactable_a.interaction_triggered.connect(_on_triggered)
	interactable_b.interaction_triggered.connect(_on_triggered)
	_run_test()


func _run_test() -> void:
	print("[TestInteractable] requesting interaction with A")
	await interactable_a.request_interaction(orange)
	print("[TestInteractable] requesting interaction with B")
	await interactable_b.request_interaction(orange)


func _on_triggered(interactable: Interactable) -> void:
	print("[TestInteractable] interaction_triggered — id: ", interactable.interactable_id)

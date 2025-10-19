extends AnimatedSprite2D

@export var dialogo: String

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	if Main.cur_scene == "cidade_scene":
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/" + dialogo + ".dialogue"))

	interaction_area.queue_free()

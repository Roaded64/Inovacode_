extends AnimatedSprite2D

@export var npc_int: int

# 1 - cego
# 2 - cadeirante
# 3 - mudo
# 4 - mae
# 5 - negacionista
# 6 - louco

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	if !Dialogic.is_playing:
		match npc_int:
			1:
				DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/cego.dialogue"))
			2:
				DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/cadeirante.dialogue"))
			3:
				DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/mudo.dialogue"))
			4:
				DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/mae.dialogue"))
			5:
				DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/negacionista.dialogue"))
			6:
				DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/louco.dialogue"))

	interaction_area.queue_free()

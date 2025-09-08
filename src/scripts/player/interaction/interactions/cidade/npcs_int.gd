extends AnimatedSprite2D

@export var npc_int: int

# 1 - cego
# 2 - cadeirante
# 3 - mudo
# 4 - mae
# 5 - negacionista

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	if !Dialogic.is_playing:
		match npc_int:
			1:
					Dialogic.start("cidade_cego")
			2:
					Dialogic.start("cidade_cadeirante")
			3:
					Dialogic.start("cidade_mudo")
			5:
					Dialogic.start("cidade_negacionista")

	interaction_area.queue_free()

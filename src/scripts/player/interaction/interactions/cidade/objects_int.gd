extends Sprite2D

@export var obj_id: int

# 1 - lixeira
#
#
#
#
#

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	match obj_id:
		1:
			Dialogic.start("cidade_lixeira")

extends Sprite2D

@export var obj_id: int

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	Main.objsegurando = obj_id
	
func _process(delta: float) -> void:
	if Main.objsegurando == obj_id:
		self.modulate = Color(1.0, 1.0, 1.0, 0.49) # alpha = 125
	else:
		self.modulate = Color(1.0, 1.0, 1.0, 1.0) # volta ao normal (alpha = 255)

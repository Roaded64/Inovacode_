extends Node2D

func _ready() -> void:
	Main._cur_scene()
	PrincipalHud.define_timer(130.0, '1:30', 1)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

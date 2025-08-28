extends Node2D

func _ready() -> void:
	Main._cur_scene()
	PrincipalHud.define_timer(10.0, '0:10', 0)

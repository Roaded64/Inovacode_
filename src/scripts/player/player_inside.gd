extends Node2D

@onready var char = $player

func _position(x: int, y: int) -> void:
	char.position = Vector2.ZERO
	position = Vector2(x, y)

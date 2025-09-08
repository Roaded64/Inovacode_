extends Node2D

@onready var char = $player

func _position(x: int, y: int) -> void:
	char.position.x = 0
	char.position.y = 0
	
	$".".position.x = x
	$".".position.y = y

extends Node2D

@onready var character = $player

func _position(x: int, y: int) -> void:
	character.position = Vector2.ZERO 
	self.position = Vector2(x, y) 

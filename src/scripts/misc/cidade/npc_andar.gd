extends CharacterBody2D

@export var speed: float = 150.0
@onready var npc = $"."

var cur_speed: float
var direction: Vector2 = Vector2.LEFT
var dir: bool = false

func _physics_process(delta: float) -> void:
	cur_speed = speed
	var motion = direction * cur_speed * delta
	var collision = move_and_collide(motion)

	if npc.position.x < -327:
		dir = !dir
		direction.x *= -1
		$AnimatedSprite.scale.x = 3 if dir else -3
		npc.position.x = -327
		
	if npc.position.x > 364:
		dir = !dir
		direction.x *= -1
		$AnimatedSprite.scale.x = 3 if dir else -3
		npc.position.x = 364

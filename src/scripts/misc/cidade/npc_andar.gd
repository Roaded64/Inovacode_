extends AnimatedSprite2D

@export var speed: float = 150.0
@onready var body: StaticBody2D = $StaticBody2D
@onready var area: Area2D = $Area2D

var direction: Vector2 = Vector2.LEFT
var dir := false
var touching_player := false

func _ready() -> void:
	# Configura colisões
	body.collision_layer = 2
	body.collision_mask = 1  # colide com player

	area.collision_layer = 0      # não colide, só detecta
	area.collision_mask = 1       # detecta player

	# Conecta os sinais do Area2D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	# Movimento manual
	position += direction * speed * delta

	# Troca animação dependendo da colisão
	if touching_player:
		play("idle")
	else:
		play("walk")

	# Inverter direção nas bordas
	if position.x < -327:
		dir = !dir
		direction.x *= -1
		scale.x = 3 if dir else -3
		position.x = -327

	if position.x > 364:
		dir = !dir
		direction.x *= -1
		scale.x = 3 if dir else -3
		position.x = 364

	if position.y > 0:
		position.y = 0


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		touching_player = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		touching_player = false


extends CharacterBody2D

var playerSpeed = 275
var isRunning = false
var isUsing = false
var canUse = false
var state = "normal"
var placeUse = false

# se ele pode se mover ou não
var playerMove = true
@export var sideMove = false

@onready var playerSprite = $player_sprite
@onready var playerAnim = $AnimationPlayer
@onready var dustSprite = $dust_sprite
@onready var playerCamera = $player_camera #Feito por Gustavo 2

# mouse
var click_position = Vector2()
var target_position = Vector2()
var hasClicked = false

@onready var mouse_location = $"../mouse_location"

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	match Main.emotion:
		1:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_depre.png")
		2:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_sad.png")
		3:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_mid.png")
		4:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_normal.png")
	
func _physics_process(_delta):
	if playerMove and not isUsing:
		var moved = false

		# Movimento por clique do mouse
		if Input.is_action_just_pressed("left_mouse"):
			if DisplayServer.window_is_focused() and get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position()):
				click_position = get_global_mouse_position()
				hasClicked = true

		if hasClicked and global_position.distance_to(click_position) > 3:
			var direction = (click_position - global_position).normalized()
			velocity = direction * playerSpeed
			moved = true
			
			if !mouse_location.visible:
				mouse_location.visible = true
			
			mouse_location.position = mouse_location.get_parent().to_local(click_position)

			# Flip do personagem baseado na direção
			playerSprite.flip_h = direction.x < 0
		else:
			mouse_location.visible = false
			
			if not Input.is_anything_pressed():
				velocity = Vector2.ZERO

		# Movimento por teclado (opcional junto com o mouse)
		var input_dir = Input.get_vector(Main.key_left, Main.key_right, Main.key_up, Main.key_down)
		if input_dir != Vector2.ZERO:
			velocity.x = move_toward(velocity.x, playerSpeed * input_dir.x, playerSpeed)
			if not sideMove:
				velocity.y = move_toward(velocity.y, playerSpeed * input_dir.y, playerSpeed)
			moved = true

			if input_dir.x != 0:
				playerSprite.flip_h = input_dir.x < 0
		else:
			if not moved:
				velocity.x = move_toward(velocity.x, 0, playerSpeed)
				if not sideMove:
					velocity.y = move_toward(velocity.y, 0, playerSpeed)

		# Câmera
		var current_scene = get_tree().current_scene.name
		if current_scene != "menu_scene":
			playerCamera.make_current()
		else:
			playerCamera.enabled = false
			velocity.y = 0

		# Animação
		if moved:
			playerAnim.play("run")
		else:
			playerAnim.play("idle")

		move_and_slide()

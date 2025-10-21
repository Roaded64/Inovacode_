extends CharacterBody2D

var playerSpeed = 91
var isRunning = false
var isUsing = false
var canUse = false
var state = "normal"
var placeUse = false

var playerMove = false
@export var sideMove = false

@onready var playerSprite = $player_sprite
@onready var playerAnim = $AnimationPlayer
@onready var dustSprite = $dust_sprite
@onready var playerCamera = $player_camera
@onready var progress = $"../hud/TextureProgressBar"

var click_position = Vector2()
var hasClicked = false
@onready var mouse_location = $"../mouse_location"

var is_mission = false

var is_blocked = false
var stuck_time = 0.0 # tempo preso para parar o movimento automático

var ending_signal = false

func _ready() -> void:
	var hud = PrincipalHud
	hud.connect("ending_triggered", Callable(self, "_ending"))

func _process(_delta: float) -> void:
	_use_camera()

	match Main.emotion:
		1:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_depre.png")
		2:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_sad.png")
		3:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_mid.png")
		4:
			playerSprite.texture = load("res://assets/images/player/emotions/sheet_normal.png")
		5:
			playerSprite.texture = load("res://assets/images/player/chefe/chefe_sheet.png")
			playerSprite.offset.y = -5

	if playerMove:
		if !DialogueManager.is_playing || !Main.is_test:
			if Input.is_action_pressed("key_sprint"):
				if progress.value > 40:
					isRunning = true
			else:
				isRunning = false

	if progress.value == 0:
		isRunning = false

	if isRunning and !is_blocked:
		if !Main.is_mouse:
			progress.value -= 0.4
		else:
			progress.value -= 0.43
	
		Main.fade(progress, 0.7, Color.WHITE)
		playerSpeed = 150
		playerAnim.speed_scale = 1.2
	else:
		Main.fade(progress, 0.7, Color.TRANSPARENT)
		playerSpeed = 91
		playerAnim.speed_scale = 1

func _physics_process(_delta: float) -> void:
	var moved = false
	var target_vel = Vector2.ZERO

	if Main.is_mouse:
		if !Main.is_cutscene:
			if !DialogueManager.is_playing:
				if Input.is_action_just_pressed("left_mouse"):
					if DisplayServer.window_is_focused() and get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position()):
						click_position = get_global_mouse_position()
						hasClicked = true
						stuck_time = 0.0

			if hasClicked:
				var distance = global_position.distance_to(click_position)
				if distance > 3:
					var dir = (click_position - global_position).normalized()
					target_vel = dir * playerSpeed
					moved = true
					
					if progress.value > 40:
						isRunning = true
					
					mouse_location.visible = true
					mouse_location.position = mouse_location.get_parent().to_local(click_position)
					playerSprite.flip_h = dir.x < 0
				else:
					isRunning = false
					hasClicked = false
					mouse_location.visible = false
			else:
				mouse_location.visible = false
	else:
		mouse_location.visible = false
		
		if !Main.is_cutscene || !DialogueManager.is_playing:
			var input_dir = Input.get_vector("key_left", "key_right", "key_up", "key_down")
			
			if input_dir != Vector2.ZERO:
				target_vel.x = playerSpeed * input_dir.x
				if not sideMove:
					target_vel.y = playerSpeed * input_dir.y
				moved = true
				
				if !DialogueManager.is_playing:
					playerSprite.flip_h = input_dir.x < 0 if input_dir.x != 0 else playerSprite.flip_h
				
				playerMove = true
			else:
				playerMove = false

			if moved:
				hasClicked = false
				mouse_location.visible = false

	if Main.is_cutscene || DialogueManager.is_playing:
		velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(target_vel, playerSpeed * _delta * 6)

	move_and_slide()

	is_blocked = moved and velocity.length() < playerSpeed * 0.1

	if Main.is_mouse and hasClicked:
		if is_blocked:
			stuck_time += _delta
			if stuck_time > 1.0:
				hasClicked = false
				mouse_location.visible = false
		else:
			stuck_time = 0.0

	if is_blocked:
		playerAnim.play("idle")
	else:
		playerAnim.play("run" if moved else "idle")

func _on_timer_timeout() -> void:
		progress.value += 0.2

func _use_camera():
	if Main.is_city:
		if ending_signal == true:
			playerCamera.limit_left = 0
			playerCamera.limit_right = 1500
			playerCamera.limit_top = 0
			playerCamera.limit_bottom = 1500
		else:
			playerCamera.limit_left = 0
			playerCamera.limit_right = 560
			playerCamera.limit_top = 0
			playerCamera.limit_bottom = 470
	elif Main.is_test:
		playerCamera.limit_left = 0
		playerCamera.limit_right = 320
		playerCamera.limit_top = 0
		playerCamera.limit_bottom = 180
		
		playerCamera.zoom = Vector2(0.8, 0.8)
	else:
		playerCamera.limit_left = 856
		playerCamera.limit_right = 1080
		playerCamera.limit_top = 40
		playerCamera.limit_bottom = 232
		
func _ending():
	ending_signal = true

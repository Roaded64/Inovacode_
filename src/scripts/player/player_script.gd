extends CharacterBody2D

var playerSpeed = 275
var isRunning = false
var isUsing = false
var canUse = false
var state = "normal"
var placeUse = false

var playerMove = true
@export var sideMove = false

@onready var playerSprite = $player_sprite
@onready var playerAnim = $AnimationPlayer
@onready var dustSprite = $dust_sprite
@onready var playerCamera = $player_camera
@onready var progress = $"../hud/TextureProgressBar"

var click_position = Vector2()
var hasClicked = false
@onready var mouse_location = $"../mouse_location"

@onready var mm = $"../hud/mission_menu/AnimationPlayer"
var is_mission = false

var is_blocked = false



func _ready() -> void:
	pass

func _process(delta: float) -> void:
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
		if Input.is_action_pressed("key_sprint"):
			if progress.value > 40:
				isRunning = true
		else:
			isRunning = false

	if progress.value == 0:
		isRunning = false

	if isRunning and !is_blocked:
		progress.value -= 0.4
		Main.fade(progress, 0.7, Color.WHITE)
		playerSpeed = 500
		playerAnim.speed_scale = 1.2
	else:
		Main.fade(progress, 0.7, Color.TRANSPARENT)
		playerSpeed = 275
		playerAnim.speed_scale = 1

	if Input.is_action_just_pressed("key_mission"):
		_popup()
	
func _physics_process(delta: float) -> void:
	if not playerMove or isUsing:
		return

	var moved = false
	var target_vel = Vector2.ZERO

	if Main.is_mouse:
		if Input.is_action_just_pressed("left_mouse") and !Dialogic.is_playing:
			if DisplayServer.window_is_focused() and get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position()):
				click_position = get_global_mouse_position()
				hasClicked = true

		if hasClicked:
			if global_position.distance_to(click_position) > 3:
				var dir = (click_position - global_position).normalized()
				target_vel = dir * playerSpeed
				moved = true
				mouse_location.visible = true
				mouse_location.position = mouse_location.get_parent().to_local(click_position)
				playerSprite.flip_h = dir.x < 0
			else:
				hasClicked = false
				mouse_location.visible = false
	else:
		var input_dir = Input.get_vector("key_left", "key_right", "key_up", "key_down")
		if input_dir != Vector2.ZERO and !Dialogic.is_playing:
			target_vel.x = playerSpeed * input_dir.x
			if not sideMove:
				target_vel.y = playerSpeed * input_dir.y
			moved = true
			playerSprite.flip_h = input_dir.x < 0 if input_dir.x != 0 else playerSprite.flip_h

	velocity = velocity.move_toward(target_vel, playerSpeed * delta * 6)
	move_and_slide()

	is_blocked = moved and velocity.length() < playerSpeed * 0.1

	if is_blocked:
		playerAnim.play("idle")
	else:
		playerAnim.play("run" if moved else "idle")

func _on_timer_timeout() -> void:
	if !isRunning:
		progress.value += 0.4

func _popup():
	if !mm.is_playing():
		is_mission = !is_mission
		if is_mission:
			mm.play("popup")
		else:
			mm.play_backwards("popup")

func _use_camera():
	match Main.cur_scene:
		"cidade_scene":
			playerCamera.limit_left = 0
			playerCamera.limit_right = 1681
			playerCamera.limit_top = -40
			playerCamera.limit_bottom = 1430
			#playerCamera.enabled = false
		"switch_keys":
			playerCamera.limit_left = 0
			playerCamera.limit_right = 1280
			playerCamera.limit_top = 0
			playerCamera.limit_bottom = 720
			#playerCamera.enabled = false
	

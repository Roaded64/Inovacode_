extends Node

var fullscreen:bool

var key_left = "key_left"
var key_right = "key_right"
var key_up = "key_up"
var key_down = "key_down"
var key_interact = "key_interact"

var emotion = 1

func _process(_delta):
	# pra deixar tela cheia XD
	if Input.is_action_just_pressed("key_fullscreen"):
		fullscreen = !fullscreen
		
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_key_pressed(KEY_F1):
		key_left = "key_left"
		key_right = "key_right"
		key_up = "key_up"
		key_down = "key_down"
		key_interact = "key_interact"
	elif Input.is_key_pressed(KEY_F2):
		key_left = "key_left2"
		key_right = "key_right2"
		key_up = "key_up2"
		key_down = "key_down2"
		key_interact = "key_interact2"

	if Input.is_key_pressed(KEY_1):
		emotion = 1
	elif Input.is_key_pressed(KEY_2):
		emotion = 2
	elif Input.is_key_pressed(KEY_3):
		emotion = 3
	elif Input.is_key_pressed(KEY_4):
		emotion = 4

func fade_in(node, fade_duration):
	var fade_tween
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(node, "modulate", Color.WHITE, fade_duration)

func fade_out(node, fade_duration, color):
	if color == null: color = Color.BLACK
	var fade_tween
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(node, "modulate", color, fade_duration)

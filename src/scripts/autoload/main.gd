extends Node

var fullscreen:bool
var cur_scene
var is_cutscene = false

# controles
var is_mouse = false

var emotion = 5

func _process(_delta):
	# pra deixar tela cheia XD
	if Input.is_action_just_pressed("key_fullscreen"):
		fullscreen = !fullscreen
		
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_key_pressed(KEY_F1):
		is_mouse = false
	elif Input.is_key_pressed(KEY_F2):
		is_mouse = true

	if Input.is_key_pressed(KEY_1):
		emotion = 1
	elif Input.is_key_pressed(KEY_2):
		emotion = 2
	elif Input.is_key_pressed(KEY_3):
		emotion = 3
	elif Input.is_key_pressed(KEY_4):
		emotion = 4

func fade(node, fade_duration, color):
	if color == null: color = Color.BLACK
	var fade_tween
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(node, "modulate", color, fade_duration)

func _cur_scene():
	cur_scene = get_tree().current_scene.name

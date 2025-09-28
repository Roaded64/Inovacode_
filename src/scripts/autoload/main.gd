extends Node

var fullscreen:bool
var cur_scene
var is_cutscene = false

# controles
var is_mouse = false

var emotion = 5

# cidade
var numbers = [2810, 2904, 1052, 0903, 0603, 1504, 1658]
var cod
var is_city = true
var descoberto = [" _ ", " _ ", " _ ", " _ "]
signal dialogue_cod

func _ready() -> void:
	dialogue_cod.connect(_signal)

func _process(_delta):
	if Main.is_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# pra deixar tela cheia XD
	if Input.is_action_just_pressed("key_fullscreen"):
		fullscreen = !fullscreen
		
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func fade(node, fade_duration, color):
	if color == null: color = Color.BLACK
	var fade_tween
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(node, "modulate", color, fade_duration)

func _cur_scene():
	cur_scene = get_tree().current_scene.name

func _rand_vetor() -> Array:
	var drawn_number = numbers[randi() % numbers.size()]
	var vetor = []
	var number_str = "%04d" % drawn_number
	for i in range(4):
		vetor.append(int(number_str[i]))

	print(vetor)
	return vetor
	
func _codigo(co: int):
	return cod[co]

func _signal(argument: String):
	match argument:
		"cego":
			descoberto[2] = cod[2]
		"cadeirante":
			descoberto[1] = cod[1]
		"mudo":
			descoberto[0] = cod[0]
		"mae":
			descoberto[3] = cod[3]
	
	if argument == "cego" || argument == "cadeirante" || argument == "mae" || argument == "mudo":
		PrincipalHud._mission("Descubra o código completo (" + str(descoberto[0]) + str(descoberto[1]) + str(descoberto[2]) + str(descoberto[3]) + ")")

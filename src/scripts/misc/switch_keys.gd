extends Node2D

func _ready() -> void:
	PrincipalHud._appear()
	
	Main._cur_scene()
	PrincipalHud.define_timer(15.0)
	await get_tree().create_timer(1).timeout
	PrincipalHud._mission("Jogue o jogo apenas com um dos braços")

func _process(_delta: float) -> void:
	if !Main.is_mouse:
		$teclado/choice.frame = 0
		$mouse/choice.frame = 1
	else:
		$teclado/choice.frame = 1
		$mouse/choice.frame = 0
	
	if Input.is_action_just_pressed("key_next"):
		Main.is_mouse = true
	elif Input.is_action_just_pressed("key_back"):
		Main.is_mouse = false

	if Input.is_action_just_pressed("key_pass"):
		PrincipalHud.stop_timer()
		Transition.scene("res://src/scenes/gameplay/cidade_scene.tscn")

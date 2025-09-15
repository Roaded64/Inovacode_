extends Node2D

func _ready() -> void:
	Main._cur_scene()
	Main.emotion = 5
	
	var vetor = Main._rand_vetor()
	Main.cod = vetor

	_entrance()

	# Conecta o sinal do HUD para tocar o ending
	var hud = PrincipalHud
	
	if hud.has_signal("ending_triggered"):
		hud.connect("ending_triggered", Callable(self, "_ending"))

func _on_ending_triggered():
	_ending()

func _entrance():
	if $CanvasLayer/entrance.visible:
		Main.is_cutscene = true
		Main.fade($CanvasLayer/entrance/text, 2, Color.WHITE)
		await get_tree().create_timer(2.1).timeout
		Main.fade($CanvasLayer/entrance/text, 2, Color.TRANSPARENT)
		await get_tree().create_timer(2.1).timeout
		Main.fade($CanvasLayer/entrance/bg, 2, Color.TRANSPARENT)
		$ambience.play()
		Main.is_cutscene = false
		
		PrincipalHud.define_timer(30.0, '01:30')
		await get_tree().create_timer(1).timeout
		PrincipalHud._mission("Explore o mapa")
		
		$CanvasLayer/entrance.queue_free()

func _ending():
	Transition.play()
	await get_tree().create_timer(1.5).timeout
		
	$player_scene._position(2710, 300)
		
	$conveniencia_map.position = Vector2(3859, 67)
	$doceria_map.position = Vector2(3859, 67)

	DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/cidade/final_bom.dialogue"))

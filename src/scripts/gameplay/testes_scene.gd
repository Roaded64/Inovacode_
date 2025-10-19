extends Node2D

@onready var player = $player_scene

func _ready() -> void:
	Main.is_city = false
	Main.is_test = true
	Main.emotion = 2
	Main._cur_scene()
	
	if Main.cur_test == 2:
		$labirint.queue_free()
		$CanvasLayer/entrance/text.text += "Complete todos os testes de libras para prosseguir"
	else:
		$objects.queue_free()
		$CanvasLayer/entrance/text.text += "Complete o labirinto sem visão para prosseguir"
	
	_entrance()
	_position()
	
func _position():
	if Main.cur_test == 2:
		player._position(160, 116)
	else:
		player._position(80, 158)

func _entrance():
	if $CanvasLayer/entrance.visible:
		PrincipalHud.show()
		await get_tree().create_timer(1.3).timeout
		$ambience.play()
		Main.is_cutscene = true
		Main.fade($CanvasLayer/entrance/text, 2, Color.WHITE)
		await get_tree().create_timer(2.1).timeout
		Main.fade($CanvasLayer/entrance/text, 2, Color.TRANSPARENT)
		await get_tree().create_timer(2.1).timeout
		Main.fade($CanvasLayer/entrance/bg, 1, Color.TRANSPARENT)
		
		#PrincipalHud.define_timer(60.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/entrance.queue_free()
		await get_tree().create_timer(0.5).timeout
		DialogueManager.auto_advance = true
		DialogueManager.auto_advance_delay = 1.5  # segundos por linha
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/sala_de_teste/segundo_teste.dialogue"))
		
		#if Main.cur_test == 2:
			#
			
			#await get_tree().create_timer(1.5).timeout
			#$objects.proxima_rodada()

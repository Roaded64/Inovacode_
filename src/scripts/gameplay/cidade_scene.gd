extends Node2D

func _ready() -> void:
	Main._cur_scene()
	Main.emotion = 5
	
	var vetor = Main._rand_vetor()
	Main.cod = vetor

	_entrance()

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
		
		PrincipalHud.define_timer(90.0, '01:30')
		await get_tree().create_timer(1).timeout
		PrincipalHud._mission("Explore o mapa")
		
		$CanvasLayer/entrance.queue_free()

extends Node2D


var descoberto = [" _ ", " _ ", " _ ", " _ "]

func _ready() -> void:
	Main._cur_scene()
	Main.emotion = 5
	
	var vetor = Main._rand_vetor()
	Main.cod = vetor
	
	Dialogic.VAR.set_variable("codigo_1", vetor[0])
	Dialogic.VAR.set_variable("codigo_2", vetor[1])
	Dialogic.VAR.set_variable("codigo_3", vetor[2])
	Dialogic.VAR.set_variable("codigo_4", vetor[3])
	
	Dialogic.signal_event.connect(_dialogic_signal)

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
		
		PrincipalHud.define_timer(130.0, '01:30')
		await get_tree().create_timer(1).timeout
		PrincipalHud._mission("Explore o mapa")
		
		$CanvasLayer/entrance.queue_free()

func _dialogic_signal(argument: String):
	match argument:
		"cego":
			descoberto[2] = Main.cod[2]
		"cadeirante":
			descoberto[1] = Main.cod[1]
		"mudo":
			descoberto[0] = Main.cod[0]
	
	if argument == "cego" || argument == "cadeirante" || argument == "mae" || argument == "mudo":
		PrincipalHud._mission("Descubra o código completo (" + str(descoberto[0]) + str(descoberto[1]) + str(descoberto[2]) + str(descoberto[3]) + ")")

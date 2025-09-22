extends Node2D

@onready var player = $player_scene

func _ready() -> void:
	$CanvasLayer/entrance.visible = true
	Main._cur_scene()
	Main.emotion = 5
	
	var vetor = Main._rand_vetor()
	Main.cod = vetor

	_entrance()

	# Conecta o sinal do HUD para tocar o ending"zoom"
	var hud = PrincipalHud
	
	if hud.has_signal("ending_triggered"):
		hud.connect("ending_triggered", Callable(self, "_ending"))

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
		
		PrincipalHud.define_timer(90.0)
		await get_tree().create_timer(1).timeout
		PrincipalHud._mission("Explore o mapa")
		
		$CanvasLayer/entrance.queue_free()

func _ending():
	Main.is_city = true
	Main.is_cutscene = true
	$ambience.stop()
	$CanvasLayer/fg.show()
	player._position(896, 512)
	player.hide()
	await get_tree().create_timer(2).timeout
	
	$conveniencia_map.position = Vector2(3859, 67)
	$doceria_map.position = Vector2(3859, 67)
	PrincipalHud.hide()
	$CanvasLayer/fg.hide()
	
	if Main.descoberto == Main.cod:
		$ending_place/who.frame = 0
		$ending_place/text.text = "A casa de quem você procura pegou fogo..."
		await get_tree().create_timer(2).timeout
		$ending_place/text.show()
		await get_tree().create_timer(4).timeout
		$ending_place/text.text = "Eu fui o responsável disso."
		await get_tree().create_timer(3).timeout
		$CanvasLayer/fg.show()
	else:
		$ending_place/who.frame = 1
		$ending_place/text.text = "Quem será que é essa pessoa?"
		await get_tree().create_timer(2).timeout
		$ending_place/text.show()
		await get_tree().create_timer(4).timeout
		$CanvasLayer/fg.show()

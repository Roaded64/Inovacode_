extends Node2D

@onready var minimap_icon = $CanvasLayer/minimap/icon_player    
@onready var player = $player_scene/player
@onready var minimap = $CanvasLayer/minimap

var initial_player_pos: Vector2
var initial_icon_pos: Vector2
const ICON_SCALE := 0.081
const MAP_SCALE = 3

var ending_signal = false
var minimap_active = true  # novo controle de estado do minimapa

func _ready() -> void:
	Main.tent += 1
	Main.is_city = true
	Main.dialogue_cod.connect(_signal)
	Main._cur_scene()
	Main.emotion = 5
	
	var vetor = Main._rand_vetor()
	Main.cod = vetor

	initial_player_pos = player.position
	initial_icon_pos = minimap_icon.position
	
	_entrance()

	var hud = PrincipalHud
	if hud.has_signal("ending_triggered"): 
		hud.connect("ending_triggered", Callable(self, "_ending"))

func _process(_delta: float) -> void:
	updatePlayer()

	# controle do estado do minimapa baseado em Main.is_city
	if !Main.is_city:
		if minimap_active:
			# salva a posição atual antes de esconder
			initial_player_pos = player.position
			initial_icon_pos = minimap_icon.position
			minimap_active = false
		minimap.hide()
	else:
		if ending_signal == false:
			minimap.show()
			minimap_active = true
		else:
			minimap.hide()
	
	if has_node("CanvasLayer/entrance"):
		if Main.tent >= 1:
			$CanvasLayer/entrance/text/Tentativas.frame = 1
			
		if Main.tent > 1:
			$CanvasLayer/entrance/text/Tentativas2.frame = 1

func _signal(argument: String):
	var icons = {
		"cego": $CanvasLayer/minimap/icon_cego,
		"cadeirante": $CanvasLayer/minimap/icon_cadeirante,
		"mudo": $CanvasLayer/minimap/icon_mudo,
		"mae": $CanvasLayer/minimap/icon_mae
	}
	
	if argument in icons:
		icons[argument].queue_free()

# Atualiza a posição do player no minimapa
func updatePlayer() -> void:
	if !Main.is_city or ending_signal:
		return  # pausa atualização se o minimapa não estiver ativo
	var delta = player.position - initial_player_pos
	minimap_icon.position = initial_icon_pos + delta * ICON_SCALE

func _entrance():
	if $CanvasLayer/entrance.visible:
		PrincipalHud.show()
		await get_tree().create_timer(1.3).timeout
		$ambience.play()
		Main.is_cutscene = true
		Main.fade($CanvasLayer/entrance/text, 1.7, Color.WHITE)
		await get_tree().create_timer(1.8).timeout
		Main.fade($CanvasLayer/entrance/text, 1.7, Color.TRANSPARENT)
		await get_tree().create_timer(1.8).timeout
		Main.fade($CanvasLayer/entrance/bg, 0.7, Color.TRANSPARENT)
		Main.is_cutscene = false
		
		PrincipalHud.define_timer(10.0)
		await get_tree().create_timer(1).timeout
		PrincipalHud._mission("Vá até os pontos marcados no mapa")
		
		$CanvasLayer/minimap/icon_mudo.show()
		$CanvasLayer/minimap/icon_cadeirante.show()
		$CanvasLayer/minimap/icon_cego.show()
		$CanvasLayer/minimap/icon_mae.show()
		
		$CanvasLayer/entrance.queue_free()

func _ending():
	ending_signal = true
	Main.pular_d = true
	$player_scene._position(896, 512)
	Main.is_city = true
	Main.is_cutscene = true
	minimap.hide()
	$ambience.stop()
	$CanvasLayer/fg.show()
	player.hide()
	await get_tree().create_timer(1.5).timeout
	
	$conveniencia_map.position = Vector2(3859, 67)
	$doceria_map.position = Vector2(3859, 67)
	PrincipalHud.hide()
	$CanvasLayer/fg.hide()
	
	if Main.descoberto == Main.cod:
		$ending_place/who.frame = 0
		$ending_place/text.text = "A casa de quem você procura pegou fogo..."
		await get_tree().create_timer(1.7).timeout
		$ending_place/text.show()
		await get_tree().create_timer(2.7).timeout
		$ending_place/text.text = "Eu fui o responsável disso."
		await get_tree().create_timer(1.2).timeout
		$CanvasLayer/fg.show()
		
		if Main.tent == 1:
			Main.pular_d = false
			Transition.scene("res://src/scenes/gameplay/testes_scene.tscn")
			Main.cur_test = 2
		elif Main. tent == 2:
			Main.ending = 2
			Main.pular_d = false
			Transition.scene("res://src/scenes/misc/credits_scene.tscn")
	else:
		$ending_place/who.frame = 1
		$ending_place/text.text = "Nunca vou saber se era de fato ele."
		await get_tree().create_timer(1.7).timeout
		$ending_place/text.show()
		await get_tree().create_timer(2.7).timeout
		$CanvasLayer/fg.show()
		await get_tree().create_timer(1).timeout
		
		if Main.tent == 2:
			Main.ending = 1
			Main.pular_d = false
			Transition.scene("res://src/scenes/misc/credits_scene.tscn")
		else:
			Main.pular_d = false
			Transition.scene("res://src/scenes/gameplay/cidade_scene.tscn")
			
			Main.descoberto = [" _ ", " _ ", " _ ", " _ "]
			Main.cod = null

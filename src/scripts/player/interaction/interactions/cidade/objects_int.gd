extends Sprite2D	

@export var obj_id: int

# 1 - lixeira
# 2 - loja
# 3 - lojinha2
# 4 - loja
#
#

# cidade
@onready var player = $"../../player_scene"
@onready var cidade_map = get_node_or_null("..")

# maps
@onready var conveniencia_map = $"../../conveniencia_map"
@onready var doceria_map = $"../../doceria_map"

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	if !Main.is_cutscene || Transition.can_trans:
		match obj_id:
			1:
				if !Dialogic.is_playing:
					Dialogic.start("cidade_lixeira")
					$"../lixeira/InteractionArea".queue_free()
			2: # Conveniencia Entrar
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				conveniencia_map.position = Vector2(2448, 137)
				
				doceria_map.position = Vector2(3859, 67)
				
				# Teleporta player para dentro da conveniência
				player._position(2710, 300)
				Main.is_city = false
			3: # Conveniencia Sair
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				# Teleporta player para dentro da área visível da cidade
				player.position = Vector2(1320, 1008)
				Main.is_city = true
			4: # Doceria Entrar
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				doceria_map.position = Vector2(2448, 137)
				
				conveniencia_map.position = Vector2(3859, 67)
				
				player._position(2710, 300)
				Main.is_city = false
			5: # Doceria Sair
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				player.position = Vector2(384, 1014)
				Main.is_city = true

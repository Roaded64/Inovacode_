extends Sprite2D	

@export var obj_id: int

# 1 - 
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
@onready var brecho_map = $"../../brecho_map"

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	if !Main.is_cutscene || Transition.can_trans:
		match obj_id:
			2: # Conveniencia Entrar
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				_enter(conveniencia_map, doceria_map, brecho_map)
				
				# Teleporta player para dentro da conveniência
				player._position(968, 112)
				Main.is_city = false
			3: # Conveniencia Sair
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				# Teleporta player para dentro da área visível da cidade
				player.position = Vector2(424, 336)
				Main.is_city = true
			4: # Doceria Entrar
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				_enter(doceria_map, conveniencia_map, brecho_map)
				
				player._position(968, 112)
				Main.is_city = false
			5: # Doceria Sair
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				player.position = Vector2(128, 336)
				Main.is_city = true
			
			6: # Brecho Entrar
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				_enter(brecho_map, doceria_map, conveniencia_map)
				
				player._position(968, 112)
				Main.is_city = false
			7: # Brecho Sair
				Transition.play()
				await get_tree().create_timer(1.5).timeout
				
				player.position = Vector2(416, 80)
				Main.is_city = true

func _enter(node, node2, node3):
	node.position = Vector2(880, 64)
	
	node2.position = Vector2(1288, 8)
	node3.position = Vector2(1288, 8)

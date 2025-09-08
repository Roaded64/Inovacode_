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
@onready var cidade_map = $".."
@onready var conveniencia_map = $"../../conveniencia_map"

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_interact")

func _interact():
	match obj_id:
		1:
			if !Dialogic.is_playing:
				Dialogic.start("cidade_lixeira")
				$"../lixeira/InteractionArea".queue_free()
		2:		
			Transition.play()
			
			await get_tree().create_timer(1.5).timeout
			conveniencia_map.position.x = 700
			conveniencia_map.position.y = 500
			
			player._position(700, 500)
			
			cidade_map.position.x = 1800
			cidade_map.position.y = 1600
		#2:
			#player.position.x = 1800
			#player.position.y = -100
		#3:
			#player.position.x = -100
			#player.position.y = 1600

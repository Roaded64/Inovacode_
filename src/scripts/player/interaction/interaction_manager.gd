extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var thing = $AnimatedSprite2D

var active_areas = []
var can_interact = true

func _register_area(area: InteractionArea):
	active_areas.push_back(area)

func _unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	
	if index != 1:
		active_areas.remove_at(index)

func _process(_delta: float) -> void:
	if active_areas.size() > 0 and can_interact:
		active_areas = active_areas.filter(func(a): return is_instance_valid(a))

		if active_areas.size() == 0:
			thing.visible = false
			return

		active_areas.sort_custom(Callable(self, "_sort_by_distance"))

		var area: InteractionArea = active_areas[0]

		if is_instance_valid(area):
			thing.global_position = area.global_position
			thing.global_position.y -= 13
			thing.play("default", true) 

			await get_tree().create_timer(0.05).timeout
			thing.visible = true
		else:
			thing.visible = false
	else:
		thing.visible = false

func _sort_by_distance(area1, area2):
	# Checa validade antes de tudo
	if not is_instance_valid(area1):
		return false
	if not is_instance_valid(area2):
		return true
	if not is_instance_valid(player):
		return false

	# Protege acessos às posições
	var pos1 = Vector2.ZERO
	var pos2 = Vector2.ZERO

	if is_instance_valid(area1):
		pos1 = area1.global_position
	if is_instance_valid(area2):
		pos2 = area2.global_position

	return player.global_position.distance_to(pos1) < player.global_position.distance_to(pos2)

func _input(event):
	if event.is_action_pressed("key_interact"):
		if active_areas.size() > 0:
			can_interact = false
			thing.visible = false
			
			await active_areas[0].interact.call()
			
			can_interact = true

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

func _process(delta: float) -> void:
	if active_areas.size() > 0 and can_interact:
		active_areas.sort_custom(_sort_by_distance)

		var area: InteractionArea = active_areas[0]
		thing.global_position = area.global_position

		thing.global_position.y -= 36
		thing.play("default", true) 
		
		await get_tree().create_timer(0.03).timeout
		thing.visible = true
	else:
		thing.visible = false


func _sort_by_distance(area1, area2):
	var area1_player = player.global_position.distance_to(area1.global_position)
	var area2_player = player.global_position.distance_to(area2.global_position)

	return area1_player < area2_player

func _input(event):
	if event.is_action_pressed("key_interact"):
		if active_areas.size() > 0:
			can_interact = false
			thing.visible = false
			
			await active_areas[0].interact.call()
			
			can_interact = true

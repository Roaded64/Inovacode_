extends Node2D

func _ready() -> void:
	Main._cur_scene()
	Main.emotion = 5
	
	_entrance()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _entrance():
	Main.fade($CanvasLayer/entrance/text, 2, Color.WHITE)
	await get_tree().create_timer(2.1).timeout
	Main.fade($CanvasLayer/entrance/text, 2, Color.TRANSPARENT)
	await get_tree().create_timer(2.1).timeout
	Main.fade($CanvasLayer/entrance/bg, 2, Color.TRANSPARENT)
	await get_tree().create_timer(2.1).timeout
	
	PrincipalHud.define_timer(130.0, '01:30', 1)
	$CanvasLayer/entrance.queue_free()

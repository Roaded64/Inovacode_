extends Control

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	
	Main.fade($aviso, 1.5, Color.WHITE)
	await get_tree().create_timer(4).timeout
	
	Main.fade($aviso, 1.5, Color.TRANSPARENT)
	await get_tree().create_timer(1.7).timeout
	
	Transition.scene("res://src/scenes/cutscene.tscn")

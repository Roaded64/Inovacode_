extends Node2D

func _ready() -> void:
	Main._cur_scene()

func _on_button_pressed() -> void:
	Transition.scene("res://src/scenes/gameplay/cidade_scene.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("key_next"):
		Main.is_mouse = true
		$Label.text = "mouse"
	elif Input.is_action_just_pressed("key_back"):
		Main.is_mouse = false
		$Label.text = "teclado"

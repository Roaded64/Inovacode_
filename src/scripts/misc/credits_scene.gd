extends Node2D

@onready var final = $CanvasLayer/final

func _ready() -> void:
	PrincipalHud.hide()
	$credits.play()
	await get_tree().create_timer(1.3).timeout
	#$CanvasLayer/ColorRect.hide()
	Main.fade($CanvasLayer/ColorRect, 4, Color.TRANSPARENT)
	
	match Main.ending:
		1:
			final.text = "FINAL RUIM"
		2:
			final.text = "FINAL NEUTRO"
		3:
			final.text = "FINAL BOM..."
		4:
			final.text = "FINAL PERFEITO?"
			$cutscene_sprites/casa_sprite.texture = load("res://assets/images/credits/casa_sprite.png")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	#await get_tree().create_timer(6).timeout
	#$CanvasLayer/ColorRect.show()
	#await get_tree().create_timer(0.5).timeout
	if Input.is_key_pressed(KEY_SPACE):
		$credits.stop()
		Transition.scene("res://src/scenes/cutscene.tscn")
	#$AnimationPlayer.play("creditos")

@warning_ignore("unused_parameter")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Transition.scene("res://src/scenes/cutscene.tscn")
	Main.ending = 0

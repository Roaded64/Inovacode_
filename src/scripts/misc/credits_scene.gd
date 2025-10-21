extends Node2D

@onready var final = $CanvasLayer/final
@onready var oque = $"CanvasLayer/o que"
@warning_ignore("shadowed_global_identifier")
@onready var char = $cutscene_sprites/char

func _ready() -> void:	
	PrincipalHud.hide()
	$credits.play()
	await get_tree().create_timer(1.3).timeout
	#$CanvasLayer/ColorRect.hide()
	Main.fade($CanvasLayer/ColorRect, 4, Color.TRANSPARENT)
	
	match Main.ending:
		1:
			final.text = "FINAL RUIM"
			oque.text = "'O chefe nunca te achou, então você pensa em o que você fez de errado'"
			char.play("ruim")
		2:
			final.text = "FINAL NEUTRO"
			oque.text = "'Você sabe que a casa dele pegou fogo, mas o que te faz achá-lo?'"
			char.play("neutro")
		3:
			final.text = "FINAL BOM..."
			oque.text = "'O chefe te fez esperar tanto pra quase nada, o que falta em você pra ser perfeito?'"
			char.play("bom")
		4:
			final.text = "FINAL PERFEITO?"
			oque.text = "'Pelo visto, achou quem procurava, o que você pensa em fazer?'"
			char.play("perfeito")
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

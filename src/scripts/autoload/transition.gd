extends CanvasLayer

@onready var anim = $AnimationPlayer

var can_trans = true

func scene(target: String) -> void:
	if can_trans:
			anim.play("transition")
			
			await anim.animation_finished
			
			get_tree().change_scene_to_file(target)
			
			await get_tree().create_timer(0.5).timeout
			
			anim.play_backwards("transition")
			
			await anim.animation_finished
			can_trans = true

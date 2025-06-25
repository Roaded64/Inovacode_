extends Node2D

func _ready() -> void:
	$HUD/AnimationPlayer.play("dis")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		$CPUParticles2D.emitting = true
		$HUD/AnimationPlayer.play("appear_anim")
		$camera_anim/AnimationPlayer.play("cutscene")

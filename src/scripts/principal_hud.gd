extends CanvasLayer

@onready var timer = $timebar/TextureProgressBar/Timer
@onready var progress = $timebar/TextureProgressBar

func _process(delta: float) -> void:
	if progress.value == 0:
		timer.stop()
			
		match Main.cur_scene:
			"cidade_scene":
				Transition.scene("res://src/scenes/cutscene.tscn")
			"switch_keys":
				Transition.scene("res://src/scenes/gameplay/cidade_scene.tscn")

func define_timer(value: float, label, step):
	timer.start()
	progress.max_value = value
	progress.value = value
	progress.step = step
	$timebar/final.text = label

func _on_timer_timeout() -> void:
	progress.value -= 1

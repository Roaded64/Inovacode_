extends CanvasLayer

@onready var timer = $timebar/TextureProgressBar/Timer
@onready var progress = $timebar/TextureProgressBar

func _start():
	timer.start()

func _process(delta: float) -> void:
	if progress.value == 0:
		if Main.cur_scene == 2:
			timer.stop()
			Main.cur_scene = null
			Transition.scene("res://src/scenes/cutscene.tscn")
			
func _on_timer_timeout() -> void:
	progress.value -= 1

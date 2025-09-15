extends CanvasLayer

@onready var timer = $timebar/TextureProgressBar/Timer
@onready var progress = $timebar/TextureProgressBar

# Sinal que será emitido no ending
signal ending_triggered

func _process(delta: float) -> void:
	if progress.value == 0:
		timer.stop()
			
		match Main.cur_scene:
			"switch_keys":
				Transition.scene("res://src/scenes/gameplay/cidade_scene.tscn")
				progress.value = 1
			"cidade_scene":
				emit_signal("ending_triggered")  # Emite sinal quando o ending deve começar

func define_timer(value: float, label):
	_appear()
	timer.start()
	progress.max_value = value
	progress.value = value
	$timebar/final.text = label

func _on_timer_timeout() -> void:
	if !Dialogic.is_playing:
		progress.value -= 0.5

func _appear() -> void:
	$timebar/AnimationPlayer.play("appear")

func _mission(mission: String) -> void:
	$timebar/AnimationPlayer.play("appear_mission")
	$missao.text = "MISSÃO ATUAL:\n" + mission

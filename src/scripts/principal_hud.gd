extends CanvasLayer

@onready var timer = $timebar/TextureProgressBar/Timer
@onready var progress = $timebar/TextureProgressBar
@onready var tempo_label = $timebar/tempo

# Sinal que será emitido no ending
signal ending_triggered
signal end

var total_time: int = 0  # tempo total em segundos

func _process(_delta: float) -> void:
	if progress.value == 0:
		timer.stop()
			
		match Main.cur_scene:
			"switch_keys":
				Transition.scene("res://src/scenes/gameplay/cidade_scene.tscn")
				progress.value = 1
			"cidade_scene":
				#Transition.scene("res://src/scenes/cutscene.tscn")
				progress.value = 1
				emit_signal("ending_triggered")  # Emite sinal quando o ending deve começar
			"testes_scene":
				progress.value = 1
				emit_signal("end")

# Define o tempo e inicia o contador
func define_timer(value: float) -> void:
	_appear()
	timer.start()
	progress.max_value = value
	progress.value = value
	total_time = int(value)  # salva em segundos
	tempo_label.text = format_time(total_time)

func stop_timer():
	timer.stop()
	$timebar.hide()

# Quando o timer dá timeout, reduzir 1 segundo
func _on_timer_timeout() -> void:
	if total_time > 0:
		total_time -= 1
		progress.value = total_time
		tempo_label.text = format_time(total_time)

# Formatar segundos em MM:SS
func format_time(seconds: int) -> String:
	@warning_ignore("integer_division")
	var minutes = seconds / 60
	var secs = seconds % 60
	return str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)

func _appear() -> void:
	$timebar.show()
	$timebar/AnimationPlayer.play("appear")

func _mission(mission: String) -> void:
	$timebar/AnimationPlayer.play("appear_mission")
	$missao.text = "MISSÃO ATUAL:\n" + mission

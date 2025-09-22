extends CanvasLayer

@onready var timer = $timebar/TextureProgressBar/Timer
@onready var progress = $timebar/TextureProgressBar
@onready var tempo_label = $timebar/tempo

# Sinal que será emitido no ending
signal ending_triggered

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

# Define o tempo e inicia o contador
func define_timer(value: float) -> void:
	_appear()
	timer.start()
	progress.max_value = value
	progress.value = value
	total_time = int(value)  # salva em segundos
	tempo_label.text = format_time(total_time)

# Quando o timer dá timeout, reduzir 1 segundo
func _on_timer_timeout() -> void:
	if !Dialogic.is_playing and total_time > 0:
		total_time -= 1
		progress.value = total_time
		tempo_label.text = format_time(total_time)

# Formatar segundos em MM:SS
func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)

func _appear() -> void:
	$timebar/AnimationPlayer.play("appear")

func _mission(mission: String) -> void:
	$timebar/AnimationPlayer.play("appear_mission")
	$missao.text = "MISSÃO ATUAL:\n" + mission

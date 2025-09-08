extends Sprite2D

var contador = 0.0
var audio_timer = 0.0

@onready var audio = $AudioStreamPlayer2D

@export var type = 1

func _ready():
	if type == 1 || type == 3:
		frame = 2

func _process(delta):
	contador += delta
	audio_timer += delta

	if type == 1 || type == 3:
		# Define o som dependendo do estado do contador
		if contador < 10.0:
			if type == 1:
				frame = 0
			else:
				frame = 2
		elif contador < 13.0:
			frame = 1
		elif contador < 25.0:
			if type == 1:
				frame = 2
			else:
				frame = 0
		else:
			contador = 0.0

	# Reproduz o áudio em loop a cada 1 segundo
	if audio_timer >= 1.0:
		match type:
			1, 2:
				if contador < 10.0 and audio.stream:
					audio.play()
					audio_timer = 0.0
			3:
				if contador < 25.0 and audio.stream:
					audio.play()
					audio_timer = 0.0

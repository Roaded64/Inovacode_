extends Node2D

var is_playing = false

var phrases = [
	"Há 1 ano e 6 meses atrás...",
	"Sua IA, feita pela DES Corp falhou...",
	"Ocasionando um incêndio na sua casa...",
	"Você queimou seu braço e perdeu tudo...",
	"Seu braço já não tinha mais movimento...",
	"Você encontrou dificuldades pelas ruas...",
	"Foram noites que você passou acordado...",
	"E só houve uma saída...",
	"Você pediu uma inovação para a DES Corp, ela irá te ajudar."
]

@onready var label = $Cutscene_HUD/RichTextLabel

func _ready() -> void:
	$HUD.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and !is_playing:
		is_playing = true
		$HUD.visible = true
		$HUD/AnimationPlayer.play("appear_anim")
		$camera_anim/AnimationPlayer.play("cutscene")
		_frases()

func show_phrases() -> void:
	call_deferred("_show_phrases_coroutine")

func _frases() -> void:
	Main.fade_out($logo, 15, Color.TRANSPARENT)
	
	$Cutscene_HUD/RichTextLabel.visible = true
	Main.fade_in($Cutscene_HUD/RichTextLabel, 3)
	
	await get_tree().create_timer(4)
	
	for phrase in phrases:
		label.bbcode_text = phrase
		await get_tree().create_timer(4).timeout
		
	await Main.fade_out($Cutscene_HUD/RichTextLabel, 3, Color.TRANSPARENT)

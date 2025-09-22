extends Node2D

var is_playing = false

var phrases = [
	"Há 1 ano e 6 meses atrás...",
	"Sua IA, feita pela DES Corp. falhou...",
	"Ocasionando um incêndio na sua casa...",
	"Você perdeu tudo, queimou seu braço...",
	"Ele já não tinha mais movimento...",
	"Dores físicas e noites sem sono...",
	"A DES Corp. começou a fazer inovações...",
	"O que lhe restava era pedir uma...",
	"Será que a DES Corp. vai ajudar?"
]

@onready var label = $Cutscene_HUD/RichTextLabel

var base_y: float

func _ready() -> void:
	base_y = $logo.position.y
	
	PrincipalHud.visible = false
	$Cutscene_HUD/AnimationPlayer.play("dis")
	
	await get_tree().create_timer(1).timeout
	Main.fade($Cutscene_HUD/ColorRect, 4, Color.TRANSPARENT)

func _process(_delta: float) -> void:
	var float_offset = sin(Time.get_ticks_msec() / 500.0) * 2  # ajustável
	
	$logo.position.y = base_y + float_offset

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and !is_playing:
		if not Input.is_action_pressed("key_fullscreen"):
			is_playing = true
			$Cutscene_HUD/AnimationPlayer.play("appear_anim")
			$camera_anim/AnimationPlayer.play("cutscene")
			$song.play()
			_frases()

func show_phrases() -> void:
	call_deferred("_show_phrases_coroutine")

func _frases() -> void:
	Main.fade($logo, 15, Color.TRANSPARENT)
	
	$Cutscene_HUD/RichTextLabel.visible = true
	Main.fade($Cutscene_HUD/RichTextLabel, 3, Color.WHITE)
	
	for phrase in phrases:
		label.bbcode_text = phrase
		await get_tree().create_timer(3).timeout
		
	await Main.fade($Cutscene_HUD/RichTextLabel, 2, Color.TRANSPARENT)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"cutscene":
			$camera_anim/AnimationPlayer.play("player")
		"player":
			Transition.scene("res://src/scenes/switch_keys.tscn")
			PrincipalHud.visible = true

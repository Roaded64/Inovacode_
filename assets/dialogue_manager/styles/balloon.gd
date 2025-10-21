extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

## The action to use for advancing the dialogue
@export var next_action: StringName = &"key_interact"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"key_interact"

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			queue_free()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Portrair
@onready var portrait: Sprite2D = %portrait

var portraits := {
	"Cadeirante": preload("res://assets/dialogue_manager/assets_portraits/cadeirante_portrait.png"),
	"Cara do Jumento": preload("res://assets/dialogue_manager/assets_portraits/cara do jumento_portrait.png"),
	"Cego": preload("res://assets/dialogue_manager/assets_portraits/cego_portrait.png"),
	"Chefe": preload("res://assets/dialogue_manager/assets_portraits/chefe_portrait.png"),
	"CM": preload("res://assets/dialogue_manager/assets_portraits/cm_portrait.png"),
	"Dona Brechó": preload("res://assets/dialogue_manager/assets_portraits/dona brechó_portrait.png"),
	"Dona": preload("res://assets/dialogue_manager/assets_portraits/dona_portrait.png"),
	"Encapuzado": preload("res://assets/dialogue_manager/assets_portraits/encapuzado_portrait.png"),
	"Jogador": preload("res://assets/dialogue_manager/assets_portraits/jogador_portrait.png"),
	"Jornalista": preload("res://assets/dialogue_manager/assets_portraits/jornalista_portrait.png"),
	"Lixeira": preload("res://assets/dialogue_manager/assets_portraits/lixeira_portrait.png"),
	"Louco": preload("res://assets/dialogue_manager/assets_portraits/louco_portrait.png"),
	"Mudo": preload("res://assets/dialogue_manager/assets_portraits/mudo_portrait.png"),
	"Negacionista": preload("res://assets/dialogue_manager/assets_portraits/negacionista_portrait.png")
}

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	# estado inicial
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	# label de personagem
	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	# portrait
	portrait.texture = portraits.get(dialogue_line.character, null)

	# preparar texto/respostas
	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# mostrar balão
	balloon.show()
	$AnimationPlayer.play("fade")
	will_hide_balloon = false

	# digitar texto
	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# pegar singleton do DialogueManager de forma segura
	var dm = Engine.get_singleton("DialogueManager")
	var auto_adv := false
	var auto_delay := 1.0
	if dm:
		# usa get("prop") que é seguro — retorna null se a prop não existir
		var tmp = dm.get("auto_advance")
		if tmp != null:
			auto_adv = tmp
		tmp = dm.get("auto_advance_delay")
		if tmp != null:
			# tenta converter para float caso venha como string
			if typeof(tmp) == TYPE_FLOAT or typeof(tmp) == TYPE_INT:
				auto_delay = float(tmp)
			else:
				# fallback: tenta parsear string
				auto_delay = float(str(tmp))

	# Se estivermos em auto-advance e não há respostas, bloqueia avanço e espera o delay
	if auto_adv and dialogue_line.responses.size() == 0:
		# bloqueia qualquer avanço manual
		is_waiting_for_input = false
		balloon.focus_mode = Control.FOCUS_NONE

		# opcional: você pode tocar uma animação de "aguardando" ou diminuir alpha aqui
		# aguarda o tempo configurado e avança
		await get_tree().create_timer(auto_delay).timeout
		# só avança se a linha atual ainda for a mesma (evita avanços duplicados)
		# (útil caso uma mutação ou outro evento já tenha trocado a linha)
		if is_instance_valid(self) and dialogue_line != null:
			next(dialogue_line.next_id)
		return

	# Modo normal (manual) — respostas/tempo automático definido na própria linha
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
	elif dialogue_line.time != "":
		var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()

## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		$AnimationPlayer.play_backwards("fade")
		await get_tree().create_timer(0.3).timeout
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)

	
#endregion

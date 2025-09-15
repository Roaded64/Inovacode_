@icon("./assets/icon.svg")
@tool
class_name DialogueLabel extends RichTextLabel

signal spoke(letter: String, letter_index: int, speed: float)
signal paused_typing(duration: float)
signal skipped_typing()
signal finished_typing()

@export var skip_action: StringName = &"ui_cancel"
@export var seconds_per_step: float = 0.02
@export var pause_at_characters: String = ".?!"
@export var skip_pause_at_character_if_followed_by: String = ")\""
@export var skip_pause_at_abbreviations: PackedStringArray = ["Mr", "Mrs", "Ms", "Dr", "etc", "eg", "ex"]
@export var seconds_per_pause_step: float = 0.3

var _already_mutated_indices: PackedInt32Array = []
var dialogue_line
var is_typing: bool = false:
	set(value):
		var finished := is_typing != value and value == false
		is_typing = value
		if finished:
			finished_typing.emit()
			thing.visible = true
			audio.stop()
	get:
		return is_typing

var _last_wait_index: int = -1
var _last_mutation_index: int = -1
var _waiting_seconds: float = 0
var _is_awaiting_mutation: bool = false
var _pitch_map: Dictionary = {}

@onready var thing = %thing
@onready var audio = %voice

func _ready():
	_load_pitchs()

func _load_pitchs() -> void:
	var pitch_file_path = "res://assets/dialogue_manager/voices/pitchs.txt"
	if not FileAccess.file_exists(pitch_file_path):
		print("Pitch file not found!")
		return

	var file = FileAccess.open(pitch_file_path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "": continue
		if ":" in line:
			var parts = line.split(":")
			if parts.size() == 2:
				var char_name = parts[0].strip_edges().to_lower()
				var pitch_value = float(parts[1])
				_pitch_map[char_name] = pitch_value
	file.close()

func _process(delta: float) -> void:
	if self.is_typing:
		thing.visible = false
		if audio.stream and not audio.playing:
			audio.play()
		
		if visible_ratio < 1:
			if _waiting_seconds > 0:
				_waiting_seconds -= delta
			if _waiting_seconds <= 0:
				_type_next(delta, _waiting_seconds)
		else:
			_mutate_inline_mutations(get_total_character_count())
			self.is_typing = false

func _unhandled_input(event: InputEvent) -> void:
	if self.is_typing and visible_ratio < 1 and InputMap.has_action(skip_action) and event.is_action_pressed(skip_action):
		get_viewport().set_input_as_handled()
		skip_typing()

func type_out() -> void:
	text = dialogue_line.text
	visible_characters = 0
	visible_ratio = 0
	_waiting_seconds = 0
	_last_wait_index = -1
	_last_mutation_index = -1
	_already_mutated_indices.clear()

	thing.visible = false

	# Carrega áudio do personagem (nome minúsculo)
	var char_name_lower: String = dialogue_line.character.to_lower()
	var voice_path: String = "res://assets/dialogue_manager/voices/%s_voice.wav" % char_name_lower
	if ResourceLoader.exists(voice_path):
		audio.stream = load(voice_path)
	else:
		audio.stream = null

	# Define pitch do personagem pelo arquivo .txt
	if _pitch_map.has(char_name_lower):
		audio.pitch_scale = 1.0 + _pitch_map[char_name_lower]
	else:
		audio.pitch_scale = 1.0

	self.is_typing = true

	await get_tree().process_frame

	if get_total_character_count() == 0:
		self.is_typing = false
	elif seconds_per_step == 0:
		_mutate_remaining_mutations()
		visible_characters = get_total_character_count()
		self.is_typing = false

func skip_typing() -> void:
	_mutate_remaining_mutations()
	visible_characters = get_total_character_count()
	self.is_typing = false
	skipped_typing.emit()
	thing.visible = true
	audio.stop()

func _type_next(delta: float, seconds_needed: float) -> void:
	if _is_awaiting_mutation: return
	if visible_characters == get_total_character_count(): return

	if _last_mutation_index != visible_characters:
		_last_mutation_index = visible_characters
		_mutate_inline_mutations(visible_characters)
		if _is_awaiting_mutation: return

	var additional_waiting_seconds: float = _get_pause(visible_characters)

	if _should_auto_pause():
		additional_waiting_seconds += seconds_per_pause_step

	if _last_wait_index != visible_characters and additional_waiting_seconds > 0:
		_last_wait_index = visible_characters
		_waiting_seconds += additional_waiting_seconds
		paused_typing.emit(_get_pause(visible_characters))
	else:
		visible_characters += 1
		if visible_characters <= get_total_character_count():
			if audio.stream:
				# Pitch varia levemente em torno do definido
				var base_pitch = audio.pitch_scale
				audio.pitch_scale = base_pitch + randf_range(-0.01, 0.01)
				if not audio.playing:
					audio.play()
			spoke.emit(get_parsed_text()[visible_characters - 1], visible_characters - 1, _get_speed(visible_characters))
		seconds_needed += seconds_per_step * (1.0 / _get_speed(visible_characters))
		if seconds_needed > delta:
			_waiting_seconds += seconds_needed
		else:
			_type_next(delta, seconds_needed)

func _get_pause(at_index: int) -> float:
	return dialogue_line.pauses.get(at_index, 0)

func _get_speed(at_index: int) -> float:
	var speed: float = 1
	for index in dialogue_line.speeds:
		if index > at_index:
			return speed
		speed = dialogue_line.speeds[index]
	return speed

func _mutate_remaining_mutations() -> void:
	for i in range(visible_characters, get_total_character_count() + 1):
		_mutate_inline_mutations(i)

func _mutate_inline_mutations(index: int) -> void:
	for inline_mutation in dialogue_line.inline_mutations:
		if inline_mutation[0] > index:
			return
		if inline_mutation[0] == index and not _already_mutated_indices.has(index):
			_is_awaiting_mutation = true
			await Engine.get_singleton("DialogueManager")._mutate(inline_mutation[1], dialogue_line.extra_game_states, true)
			_is_awaiting_mutation = false
	_already_mutated_indices.append(index)

func _should_auto_pause() -> bool:
	if visible_characters == 0: return false

	var parsed_text: String = get_parsed_text()
	if visible_characters >= parsed_text.length(): return false

	if parsed_text[visible_characters] in skip_pause_at_character_if_followed_by.split():
		return false

	if visible_characters > 3 and parsed_text[visible_characters - 1] == ".":
		var possible_number: String = parsed_text.substr(visible_characters - 2, 3)
		if str(float(possible_number)).pad_decimals(1) == possible_number:
			return false

	if "." in pause_at_characters and parsed_text[visible_characters - 1] == ".":
		for abbreviation in skip_pause_at_abbreviations:
			if visible_characters >= abbreviation.length():
				var previous_characters: String = parsed_text.substr(visible_characters - abbreviation.length() - 1, abbreviation.length())
				if previous_characters == abbreviation:
					return false

	var other_pause_characters: PackedStringArray = pause_at_characters.replace(".", "").split()
	if visible_characters > 1 and parsed_text[visible_characters - 1] in other_pause_characters and parsed_text[visible_characters] in other_pause_characters:
		return false

	return parsed_text[visible_characters - 1] in pause_at_characters.split()

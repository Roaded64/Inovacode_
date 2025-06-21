
extends CharacterBody2D

var playerSpeed = 275
var isRunning = false
var isUsing = false
var canUse = false
var state = "normal"
var placeUse = false

# se ele pode se mover ou não
var playerMove = true
@export var sideMove = false

@onready var playerSprite = $player_sprite
@onready var dustSprite = $dust_sprite

func _ready() -> void:
	state = "normal"
	
func _process(delta: float) -> void:
	pass
	
func _physics_process(_delta):
	# Fazer o vagabundo se mover
	if playerMove && !isUsing:
		var direction: Vector2 = Input.get_vector(Main.key_left, Main.key_right, Main.key_up, Main.key_down)
		
		velocity.x = move_toward(velocity.x, playerSpeed * direction.x, playerSpeed)
		
		if !sideMove:
				velocity.y = move_toward(velocity.y, playerSpeed * direction.y, playerSpeed)

		var player_direction = 1
		
		if Input.is_action_pressed(Main.key_left):
			playerSprite.scale.x = -1
			canUse = false
		elif Input.is_action_pressed(Main.key_right):
			playerSprite.scale.x = 1
			canUse = true
		
		var current_scene = get_tree().current_scene.name #Feito por Gustavo
		if current_scene == "menu_scene": #Feito por Gustavo
			velocity.y = 0 #Feito por Gustavo
			
			if direction.x != 0: #Feito por Gustavo
				playerSprite.play("run_" + state) #Feito por Gustavo
			else: #Feito por Gustavo
				playerSprite.play("idle_" + state) #Feito por Gustavo
		
		elif !sideMove: #Feito por Gustavo
			velocity.y = move_toward(velocity.y, playerSpeed * direction.y, playerSpeed) #Feito por Gustavo
		
			if direction:
				# dustSprite.play("default")
				playerSprite.play("run_" + state)
			else:
				playerSprite.play("idle_" + state)

		move_and_slide()

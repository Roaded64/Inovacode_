extends Node

@onready var obj1 = $"../carrinho"
@onready var obj2 = $"../bola"
@onready var obj3 = $"../chave"
@onready var obj4 = $"../livro"
@onready var obj5 = $"../flor"

func _ready() -> void:
	if obj1 == null:
		Main.objsegurando = 1
	
	if obj2 == null:
		Main.objsegurando = 2
		
	if obj3 == null:
		Main.objsegurando = 3
		
	if obj4 == null:
		Main.objsegurando = 4
		
	if obj5 == null:
		Main.objsegurando = 5

#NN FAÇO A MENOR IDEIA SE FINCIONA, ACHO Q SS

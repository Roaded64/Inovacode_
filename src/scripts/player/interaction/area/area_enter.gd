extends Node2D

signal entered_area

func _ready():
	var area = $"." #corpo aleatório
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	emit_signal("entered_area")
	print("Objeto entrou na área!")

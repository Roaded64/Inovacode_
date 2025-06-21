extends ColorRect
func _ready():
	pass
	
func _process(_delta): #Feito por Gustavo
	if Input.is_anything_pressed(): #Feito por Gustavo
		get_tree().change_scene_to_file("res://src/scenes/menu_scene.tscn") #Feito por Gustavo

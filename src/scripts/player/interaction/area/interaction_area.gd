extends Area2D
class_name InteractionArea

@export var type = 1

var interact: Callable = func():
	pass

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node2D) -> void:
	InteractionManager._register_area(self)

@warning_ignore("unused_parameter")
func _on_body_exited(body: Node2D) -> void:
	InteractionManager._unregister_area(self)

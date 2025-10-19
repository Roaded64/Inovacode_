@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	# Register folder type
	var folder_script = preload("./folder.gd")
	var icon = preload("res://addons/folder/folder_icon.svg")
	add_custom_type("Folder", "Node2D", folder_script, icon)
	
	# Register inspector plugin
	inspector_plugin = preload("./inspector_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
	remove_custom_type("Folder")
	remove_inspector_plugin(inspector_plugin)

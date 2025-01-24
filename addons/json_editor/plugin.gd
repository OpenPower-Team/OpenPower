@tool
extends EditorPlugin

## JSON Editor plugin for Godot 4.x
##
## A visual editor for JSON files that provides both tree view and text editing capabilities.
## Supports all JSON data types and provides real-time validation.

var json_editor: Control

func _enter_tree() -> void:
	# Load scene
	var scene = load("res://addons/json_editor/scenes/json_editor.tscn")
	if scene:
		json_editor = scene.instantiate()
		
		# Add to main screen
		get_editor_interface().get_editor_main_screen().add_child(json_editor)
		_make_visible(false)

func _exit_tree() -> void:
	if json_editor:
		json_editor.queue_free()

func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return "JSON Editor"

func _get_plugin_icon() -> Texture2D:
	return load("res://addons/json_editor/icons/icon.svg") as Texture2D

func _make_visible(visible: bool) -> void:
	if json_editor:
		json_editor.visible = visible

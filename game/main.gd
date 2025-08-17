# REFACTOR: Cleaned up and added full static typing.
extends Control

func _ready() -> void:
	# You can connect all buttons here for clarity instead of the editor
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_singleplayer_button_up() -> void:
	# TODO: Change to the new game_world scene
	get_tree().change_scene_to_file("res://game/game_logic/game_world.tscn")

func _on_multiplayer_button_up() -> void:
	# get_tree().change_scene_to_file("res://game/multiplayer.tscn")
	pass # Not implemented

func _on_world_editor_button_up() -> void:
	get_tree().change_scene_to_file("res://game/editor/world_editor.tscn")

func _on_options_button_up() -> void:
	pass # Replace with function body.
	
func _on_exit_button_up() -> void:
	get_tree().quit()
# FIX: This script was empty. It should handle UI signals for the main menu.
extends Control

func _input(event: InputEvent) -> void:
	# Not yet implemented
	pass

func _on_singleplayer_button_up() -> void:
	get_tree().change_scene_to_file("res://game/game_logic/game_world.tscn")

func _on_multiplayer_button_up() -> void:
	# Not yet implemented
	pass

func _on_world_editor_button_up() -> void:
	get_tree().change_scene_to_file("res://game/editor/WorldEditor.tscn")

func _on_options_button_up() -> void:
	# Not yet implemented
	pass
	
func _on_exit_button_up() -> void:
	get_tree().quit()

extends MainMenu


func _on_world_editor_button_pressed() -> void:
	game_scene_path = "res://game/editor/world_editor.tscn"
	load_game_scene()

extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

func _input(_event):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()


func _on_singleplayer_button_up() -> void:
	get_tree().change_scene_to_file("res://src/singleplayer.tscn")

func _on_multiplayer_button_up() -> void:
	get_tree().change_scene_to_file("res://src/multiplayer.tscn")

func _on_world_editor_button_up() -> void:
	get_tree().change_scene_to_file("res://src/editor/WorldEditor.tscn")

func _on_options_button_up() -> void:
	pass # Replace with function body.
	
func _on_exit_button_up() -> void:
	get_tree().quit()

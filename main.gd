extends Node

@onready var world: World = $World

func _ready() -> void:
	ECS.world = world

func _process(delta):
	print("yes")
	#ECS.world.process(delta, 'input')
	if not GameState.paused:
		print("yes")
		ECS.world.process(delta, 'editor')

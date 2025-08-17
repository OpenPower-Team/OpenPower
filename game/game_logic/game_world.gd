extends Node

# This node is the root of our main game scene.
# Its primary job is to manage the ECS world and process systems in the correct order.

@onready var world: World = $World

func _ready() -> void:
	# Assign the world to the global ECS singleton so systems can access it.
	ECS.world = world
	print("GECS DEV: GameWorld ready. ECS world assigned.")
	
	# The WorldInitializationSystem will run automatically on the first frame
	# because its query will find entities (or lack thereof) and trigger.

func _process(delta: float) -> void:
	if not ECS.world:
		return
		
	# Process systems based on their group name in the scene tree.
	# The order here is critical for logical consistency.
	ECS.world.process(delta, "Initialization") # Runs once, then does nothing.
	ECS.world.process(delta, "Gameplay")       # For population, stability, AI, etc.

func _physics_process(delta: float) -> void:
	if not ECS.world:
		return
	
	ECS.world.process(delta, "Physics")        # For any future physics-based logic.

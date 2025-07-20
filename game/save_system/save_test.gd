extends Node

## Example class demonstrating save system usage
@export var tosave_player_health := 100
@export var tosave_player_level := 1
@export var tosave_player_name := "Player"
@export var tosave_game_time := 0.0
@export var player_speed := 300 # This won't be saved (no 'tosave' in name)

func _ready():
	print("\n=== Save System Test ===")
	print("Save files will be stored in:")
	print(SaveSystem.get_save_directory())
	
	# Print initial values
	print("\n=== Initial Values ===")
	print_values()
	
	# Save current state
	print("\nSaving game...")
	var save_result := SaveSystem.save_game("test_save", [self])
	print("Save result: ", "OK" if save_result == OK else "Error: ", save_result)
	print("Full save path: ", SaveSystem.get_save_path("test_save"))
	
	# Modify values to test loading
	tosave_player_health = 50
	tosave_player_level = 2
	tosave_player_name = "TestPlayer"
	tosave_game_time = 123.45
	
	print("\n=== Modified Values ===")
	print_values()
	
	# Load saved state
	print("\nLoading game...")
	var load_result := SaveSystem.load_game("test_save", [self])
	print("Load result: ", "OK" if load_result == OK else "Error: ", load_result)
	
	# Verify values were restored
	print("\n=== Loaded Values ===")
	print_values()

func print_values():
	print("Player Health: ", tosave_player_health)
	print("Player Level: ", tosave_player_level)
	print("Player Name: ", tosave_player_name)
	print("Game Time: ", tosave_game_time)
	print("Speed (not saved): ", player_speed)

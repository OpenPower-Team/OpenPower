extends Node

## Autoload singleton for managing game saves
##
## Saves ALL @export variables containing "tosave" in their names from ANY nodes passed to save_game()
## Works across all scripts as long as:
## 1. The node is included in the nodes array parameter
## 2. The variable is marked with @export
## 3. The variable name contains "tosave" (case insensitive)
const SAVE_DIR := "user://saves/"
const SAVE_EXT := ".tres"

## Saves all marked (@export with 'tosave') properties from target nodes
func save_game(save_name: String, nodes: Array[Node]) -> Error:
	print("\n=== Saving Game ===")
	print("Save directory: ", SAVE_DIR)
	
	# Ensure save directory exists
	var dir := DirAccess.open("user://")
	if dir == null:
		print("ERROR: Cannot access user:// directory")
		return ERR_CANT_OPEN
	
	if not dir.dir_exists(SAVE_DIR):
		print("Creating save directory...")
		var err := dir.make_dir_recursive(SAVE_DIR)
		if err != OK:
			print("ERROR: Failed to create save directory (", err, ")")
			return err
	
	var save_data := SaveData.create()
	print("Created new SaveData resource (version ", save_data.version, ")")
	
	# Collect all tosave properties from nodes
	for node in nodes:
		var node_data := {}
		var props := _get_tosave_properties(node)
		print("\nProcessing node: ", node.name, " (", props.size(), " tosave properties)")
		
		for prop in props:
			node_data[prop.name] = node.get(prop.name)
			print("  - ", prop.name, ": ", node_data[prop.name])
		
		if not node_data.is_empty():
			save_data.data[node.get_path()] = node_data
	
	# Save to resource file
	var save_path := SAVE_DIR.path_join(save_name + SAVE_EXT)
	print("\nSaving to: ", save_path)
	var err := ResourceSaver.save(save_data, save_path)
	
	if err == OK:
		print("Save successful!")
	else:
		print("ERROR: Save failed (", err, ")")
	
	return err

## Loads game state and applies to target nodes
func load_game(save_name: String, nodes: Array[Node]) -> Error:
	var save_path := SAVE_DIR.path_join(save_name + SAVE_EXT)
	if not ResourceLoader.exists(save_path):
		return ERR_FILE_NOT_FOUND
	
	var save_data: SaveData = ResourceLoader.load(save_path)
	if not save_data.is_version_compatible():
		return ERR_INVALID_DATA
	
	# Apply saved data to nodes
	for node in nodes:
		var node_path := node.get_path()
		if node_path in save_data.data:
			for prop in save_data.data[node_path]:
				if node.get(prop) != null:  # Check if property exists by trying to get it
					node.set(prop, save_data.data[node_path][prop])
				else:
					print("  - WARNING: Property ", prop, " not found on node")
	
	return OK

## Returns array of property dictionaries marked with 'tosave' in their names
func _get_tosave_properties(node: Node) -> Array[Dictionary]:
	var tosave_props: Array[Dictionary] = []
	
	for prop in node.get_property_list():
		# Skip non-exported properties and methods
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		
		# Check if property name contains 'tosave'
		if "tosave" in prop.name.to_lower():
			# Create explicit dictionary with required fields
			var prop_dict := {
				"name": prop.name,
				"type": prop.type,
				"usage": prop.usage,
				"hint": prop.hint,
				"hint_string": prop.hint_string
			}
			tosave_props.append(prop_dict)
	
	return tosave_props

## Returns the full path to save files directory
func get_save_directory() -> String:
	return ProjectSettings.globalize_path("user://saves/")

## Returns the full path to a specific save file
func get_save_path(save_name: String) -> String:
	return ProjectSettings.globalize_path(SAVE_DIR.path_join(save_name + SAVE_EXT))

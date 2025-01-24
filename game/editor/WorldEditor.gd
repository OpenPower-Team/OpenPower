extends Node2D

# Onready variable to hold the Sprite2D node
@onready var map_image = $Sprite2D

# Lists and dictionary to store data for continents, players, and regions
var list_continents = []
var list_players = []
var dict_regions = {}

# Called when the node enters the scene tree for the first time
func _ready():
	# Import JSON data into the respective lists and dictionary
	self.list_continents = import_file("res://data/continents.json")
	self.list_players = import_file("res://data/players.json")
	self.dict_regions = import_file("res://data/regions.json")

	# Load user interface components for continents and players
	load_continents()
	load_players()

## INPUT FUNCTIONS

# Handles unhandled input events, particularly for mouse button clicks
func _unhandled_input(event):
	# Check if the left mouse button was pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var pos = get_local_mouse_position() # Get the current mouse position
		var color = "#" + str(map_image.texture.get_image().get_pixelv(pos).to_html(false)) # Get the color of the clicked pixel
		
		# Check if texture or image is missing
		if map_image.texture == null or map_image.texture.get_image() == null:
			print("Texture or image is missing")
			return
		
		# If the color is valid and not white or black
		if color != null and color != "#ffffff" and color != "#000000":
			get_node("CanvasLayer/Panel_region").visible = true # Show the region panel
			get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").set_text(str(color)) # Display the color code
			
			# Check if the color exists in the regions dictionary
			if color in self.dict_regions:
				# Set text and options based on the region data
				get_node("CanvasLayer/Panel_region/VB/GC/LE_Name").set_text(str(dict_regions[color][0]))
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").select(dict_regions[color][1])
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").select(dict_regions[color][2])
			else:
				# If color not in the regions dictionary, add a default entry
				dict_regions[color] = ["NA", 0, 0]
				get_node("CanvasLayer/Panel_region/VB/GC/LE_Name").set_text(str(dict_regions[color][0]))
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").select(0)
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").select(0)
		else:
			# Hide the region panel if the color is invalid
			get_node("CanvasLayer/Panel_region").visible = false
			_on_button_region_save_button_up()

# Handles input events, specifically for the Esc key
func _input(_event):
	# Check if the cancel action (Esc key) was just released
	if Input.is_action_just_released("ui_cancel"):
		# If validation panel is not visible, go to main menu
		if get_node("CanvasLayer/Panel_validation").visible == false:
			get_tree().change_scene_to_file("res://Levels/0. Main Menu/Main Menu.tscn")
		# If validation panel is visible, hide it
		if get_node("CanvasLayer/Panel_validation").visible == true:
			get_node("CanvasLayer/Panel_validation").visible = false

## PANEL CONTINENTS FUNCTIONS

# Load the continent data into the UI
func load_continents():
	# If the continent list is null, initialize with "NA"
	if list_continents == null:
		self.list_continents = ["NA"]
	
	# Iterate over each continent line
	for lines in self.list_continents:
		# Create UI elements for each continent
		var HB_continent = HBoxContainer.new()
		var name1 = "HB_continent" + str(get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count())
		HB_continent.name = name1
		var line_continent = LineEdit.new()
		line_continent.text = lines
		line_continent.custom_minimum_size = Vector2(280.0, 31.0)
		var delete_button = Button.new()
		delete_button.text = "Delete"
		
		# Add the continent to the UI, except for "NA"
		if lines != "NA":
			get_node("CanvasLayer/Panel_continents/VB/VB_continents").add_child(HB_continent)
			get_node("CanvasLayer/Panel_continents/VB/VB_continents/" + name1).add_child(line_continent)
			var number = get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count()
			delete_button.connect("pressed", _on_button_delete_continent_pressed.bind(number))
			get_node("CanvasLayer/Panel_continents/VB/VB_continents/" + name1).add_child(delete_button)
		
		# Add continent name to the options in the region panel
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").add_item(lines)

# Add a new continent to the UI
func _on_button_add_continent_button_up():
	var HB_continent = HBoxContainer.new()
	var name1 = "HB_continent" + str(get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count())
	HB_continent.name = name1
	get_node("CanvasLayer/Panel_continents/VB/VB_continents").add_child(HB_continent)
	var line_continent = LineEdit.new()
	line_continent.custom_minimum_size = Vector2(280.0, 31.0)
	get_node("CanvasLayer/Panel_continents/VB/VB_continents/" + name1).add_child(line_continent)
	var delete_button = Button.new()
	delete_button.text = "Delete"
	var number = get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count()
	delete_button.connect("pressed", _on_button_delete_continent_pressed.bind(number))
	get_node("CanvasLayer/Panel_continents/VB/VB_continents/" + name1).add_child(delete_button)

# Save the continents list and update the options in the region panel
func _on_button_save_continent_button_up():
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").clear() # Clear existing options
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").add_item("NA") # Add default option
	self.list_continents = ["NA"] # Reset continent list
	
	# Add each line from the UI to the continent list
	for line_continent in get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_children():
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").add_item(line_continent.get_children()[0].text)
		self.list_continents.append(line_continent.get_children()[0].text)
	
	# Export the updated continent list to JSON
	export_file("res://data/continents.json", list_continents)

# Delete a continent from the UI
func _on_button_delete_continent_pressed(number : int):
	get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_children()[number - 1].queue_free()
	print(number)

# Close the continent panel
func _on_button_close_continent_button_up():
	get_node("CanvasLayer/Panel_continents").visible = false

## PANEL PLAYER FUNCTIONS

# Load player data into the UI
func load_players():
	# If the player list is null, initialize with "NA"
	if list_players == null:
		self.list_players = ["NA"]
	
	# Iterate over each player line
	for lines in self.list_players:
		# Create UI elements for each player
		var HB_player = HBoxContainer.new()
		var name1 = "HB_player" + str(get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count())
		HB_player.name = name1
		var line_player = LineEdit.new()
		line_player.text = lines
		line_player.custom_minimum_size = Vector2(280.0, 31.0)
		var delete_button = Button.new()
		delete_button.text = "Delete"
		
		# Add the player to the UI, except for "NA"
		if lines != "NA":
			get_node("CanvasLayer/Panel_players/VB/VB_players").add_child(HB_player)
			get_node("CanvasLayer/Panel_players/VB/VB_players/" + name1).add_child(line_player)
			var number = get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count()
			delete_button.connect("pressed", _on_button_delete_player_pressed.bind(number))
			get_node("CanvasLayer/Panel_players/VB/VB_players/" + name1).add_child(delete_button)
		
		# Add player name to the options in the region panel
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").add_item(lines)

# Add a new player to the UI
func _on_button_add_player_button_up():
	var HB_player = HBoxContainer.new()
	var name1 = "HB_player" + str(get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count())
	HB_player.name = name1
	get_node("CanvasLayer/Panel_players/VB/VB_players").add_child(HB_player)
	var line_player = LineEdit.new()
	line_player.custom_minimum_size = Vector2(280.0, 31.0)
	get_node("CanvasLayer/Panel_players/VB/VB_players/" + name1).add_child(line_player)
	var delete_button = Button.new()
	delete_button.text = "Delete"
	var number = get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count()
	delete_button.connect("pressed", _on_button_delete_player_pressed.bind(number))
	get_node("CanvasLayer/Panel_players/VB/VB_players/" + name1).add_child(delete_button)

# Save the player list and update the options in the region panel
func _on_button_save_player_button_up():
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").clear() # Clear existing options
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").add_item("NA") # Add default option
	self.list_players = ["NA"] # Reset player list
	
	# Add each line from the UI to the player list
	for line_players in get_node("CanvasLayer/Panel_players/VB/VB_players").get_children():
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").add_item(line_players.get_children()[0].text)
		self.list_players.append(line_players.get_children()[0].text)
	
	# Export the updated player list to JSON
	export_file("res://data/players.json", list_players)

# Close the player panel
func _on_button_close_players_button_up():
	get_node("CanvasLayer/Panel_players").visible = false

# Delete a player from the UI
func _on_button_delete_player_pressed(number : int):
	get_node("CanvasLayer/Panel_players/VB/VB_players").get_children()[number - 1].queue_free()
	print(number)

## PANEL REGION FUNCTIONS

# Change the name of the region when the text is changed
func _on_le_name_text_changed(new_text):
	var color = get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").get_text()
	dict_regions[color][0] = new_text # Update the region name in the dictionary

# Select a continent from the options
func _on_ob_continent_item_selected(index):
	var color = get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").get_text()
	dict_regions[color][1] = index # Update the continent index in the dictionary

# Select an owner from the options
func _on_ob_owner_item_selected(index):
	var color = get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").get_text()
	dict_regions[color][2] = index # Update the owner index in the dictionary

# Save the region data to a JSON file
func _on_button_region_save_button_up():
	export_file("res://data/regions.json", dict_regions)

# Close the region panel
func _on_button_region_close_button_up():
	get_node("CanvasLayer/Panel_region").visible = false

## SYSTEM FUNCTIONS

# Import data from a JSON file and convert it to a list or dictionary
func import_file(filepath):
	var file = FileAccess.open(filepath, FileAccess.READ) # Open the file for reading
	if file != null:
		return JSON.parse_string(file.get_as_text().replace("_", " ")) # Parse the JSON data
	else:
		print("Failed to open file:", filepath)
		return null

# Export a list or dictionary to a JSON file
func export_file(filepath, my_file):
	var content = JSON.stringify(my_file, "\t") # Convert the data to a JSON string
	var file = FileAccess.open(filepath, FileAccess.WRITE) # Open the file for writing
	file.store_string(content.replace(" ", " ")) # Store the JSON string in the file

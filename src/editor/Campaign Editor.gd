extends Node2D
@onready var map_image = $Sprite2D
var list_continents = []
var list_players = []
var dict_regions = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.list_continents = import_file("res://data/continents.json")
	self.list_players = import_file("res://data/players.json")
	self.dict_regions = import_file("res://data/regions.json")
	
	load_continents()
	load_players()



## INPUT FUNCTIONS
# When clicking on region, find color code and cllect information from the region dictionary and related list
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var pos = get_local_mouse_position()
		var color = "#" + str(map_image.texture.get_image().get_pixelv(pos).to_html(false))
		if map_image.texture == null or map_image.texture.get_image() == null:
			print("Texture or image is missing")
			return
		if color != null && color != "#ffffff" && color != "#000000":
			get_node("CanvasLayer/Panel_region").visible = true
			get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").set_text(str(color))
			if color in self.dict_regions:
				get_node("CanvasLayer/Panel_region/VB/GC/LE_Name").set_text(str(dict_regions[color][0]))
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").select(dict_regions[color][1])
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").select(dict_regions[color][2])
			else: #color not in self.dict_regions:
				dict_regions[color] = ["NA",0,0]
				get_node("CanvasLayer/Panel_region/VB/GC/LE_Name").set_text(str(dict_regions[color][0]))
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").select(0)
				get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").select(0)
		else:
			get_node("CanvasLayer/Panel_region").visible = false
			_on_button_region_save_button_up()
		
#Esc button
func _input(_event):
	if Input.is_action_just_released("ui_cancel"):
		if get_node("CanvasLayer/Panel_validation").visible == false:
			get_tree().change_scene_to_file("res://Levels/0. Main Menu/Main Menu.tscn")
		if get_node("CanvasLayer/Panel_validation").visible == true:
			get_node("CanvasLayer/Panel_validation").visible = false

## PANEL CONTINENTS FUNCTIONS
# check the file if empty, put contents region options
func load_continents():
	if list_continents == null:
		self.list_continents = ["NA"]
	for lines in self.list_continents:
		var HB_continent = HBoxContainer.new()
		var name1 = "HB_continent"+str(get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count())
		HB_continent.name = name1
		var line_continent = LineEdit.new()
		line_continent.text = lines
		line_continent.custom_minimum_size = Vector2(280.0,31.0)
		var delete_button = Button.new()
		delete_button.text = "Delete"
		if lines != "NA":
			get_node("CanvasLayer/Panel_continents/VB/VB_continents").add_child(HB_continent)
			get_node("CanvasLayer/Panel_continents/VB/VB_continents/"+name1).add_child(line_continent)
			var number = get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count()
			delete_button.connect("pressed", _on_button_delete_continent_pressed.bind(number))
			get_node("CanvasLayer/Panel_continents/VB/VB_continents/"+name1).add_child(delete_button)
			
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").add_item(lines)

#Add new continent
func _on_button_add_continent_button_up():
	var HB_continent = HBoxContainer.new()
	var name1 = "HB_continent"+str(get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count())
	HB_continent.name = name1
	get_node("CanvasLayer/Panel_continents/VB/VB_continents").add_child(HB_continent)
	var line_continent = LineEdit.new()
	line_continent.custom_minimum_size = Vector2(280.0,31.0)
	get_node("CanvasLayer/Panel_continents/VB/VB_continents/"+name1).add_child(line_continent)
	var delete_button = Button.new()
	delete_button.text = "Delete"
	var number = get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_child_count()
	delete_button.connect("pressed", _on_button_delete_continent_pressed.bind(number))
	get_node("CanvasLayer/Panel_continents/VB/VB_continents/"+name1).add_child(delete_button)
	
#Save the continent list and update the continent options on panel region
func _on_button_save_continent_button_up():
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").clear()
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").add_item("NA")
	self.list_continents = ["NA"]
	for line_continent in get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_children():
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Continent").add_item(line_continent.get_children()[0].text)
		self.list_continents.append(line_continent.get_children()[0].text)
	export_file("res://data/continents.json", list_continents)

func _on_button_delete_continent_pressed(number : int):
	get_node("CanvasLayer/Panel_continents/VB/VB_continents").get_children()[number-1].queue_free()
	print(number)

#Close continent panel
func _on_button_close_continent_button_up():
	get_node("CanvasLayer/Panel_continents").visible = false

## PANEL PLAYER FUNCTIONS
# check the file if empty, put contents region options
func load_players():
	if list_players == null:
		self.list_players = ["NA"]
	for lines in self.list_players:
		var HB_player = HBoxContainer.new()
		var name1 = "HB_player"+str(get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count())
		HB_player.name = name1
		var line_player = LineEdit.new()
		line_player.text = lines
		line_player.custom_minimum_size = Vector2(280.0,31.0)
		var delete_button = Button.new()
		delete_button.text = "Delete"
		if lines != "NA":
			get_node("CanvasLayer/Panel_players/VB/VB_players").add_child(HB_player)
			get_node("CanvasLayer/Panel_players/VB/VB_players/"+name1).add_child(line_player)
			var number = get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count()
			delete_button.connect("pressed", _on_button_delete_player_pressed.bind(number))
			get_node("CanvasLayer/Panel_players/VB/VB_players/"+name1).add_child(delete_button)
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").add_item(lines)

func _on_button_add_player_button_up():
	var HB_player = HBoxContainer.new()
	var name1 = "HB_player"+str(get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count())
	HB_player.name = name1
	get_node("CanvasLayer/Panel_players/VB/VB_players").add_child(HB_player)
	var line_player = LineEdit.new()
	line_player.custom_minimum_size = Vector2(280.0,31.0)
	get_node("CanvasLayer/Panel_players/VB/VB_players/"+name1).add_child(line_player)
	var delete_button = Button.new()
	delete_button.text = "Delete"
	var number = get_node("CanvasLayer/Panel_players/VB/VB_players").get_child_count()
	delete_button.connect("pressed", _on_button_delete_player_pressed.bind(number))
	get_node("CanvasLayer/Panel_players/VB/VB_players/"+name1).add_child(delete_button)

#Save the player list and update the player options on panel region
func _on_button_save_player_button_up():
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").clear()
	get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").add_item("NA")
	self.list_players = ["NA"]
	for line_players in get_node("CanvasLayer/Panel_players/VB/VB_players").get_children():
		get_node("CanvasLayer/Panel_region/VB/GC/OB_Owner").add_item(line_players.get_children()[0].text)
		self.list_players.append(line_players.get_children()[0].text)
	export_file("res://data/players.json", list_players)

func _on_button_close_players_button_up():
	get_node("CanvasLayer/Panel_players").visible = false
	
func _on_button_delete_player_pressed(number : int):
	get_node("CanvasLayer/Panel_players/VB/VB_players").get_children()[number-1].queue_free()
	print(number)

## PANEL REGION FUNCTIONS
func _on_le_name_text_changed(new_text):
	var color = get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").get_text()
	dict_regions[color][0] = new_text

func _on_ob_continent_item_selected(index):
	var color = get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").get_text()
	dict_regions[color][1] = index
	
func _on_ob_owner_item_selected(index):
	var color = get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").get_text()
	dict_regions[color][2] = index

func _on_button_region_save_button_up():
	export_file("res://data/regions.json", dict_regions)

func _on_button_region_close_button_up():
	get_node("CanvasLayer/Panel_region").visible = false


		
## SYSTEM FUNCTIONS
#Import JSON files and converts to lists or dictionary
func import_file(filepath):
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file != null:
		return JSON.parse_string(file.get_as_text().replace("_", " "))
	else:
		print("Failed to open file:", filepath)
		return null

#Export lists or dictionaries to JSON files
func export_file(filepath, my_file):
	var content = JSON.stringify(my_file, "\t")
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_string(content.replace(" ", " "))

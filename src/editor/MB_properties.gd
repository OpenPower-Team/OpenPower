extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready():
	#Add button with text "Players", Id=1
	get_popup().add_item("Players", 1)
	#Add button with text "Continents", Id=2
	get_popup().add_item("Continents", 2)
	#Calls function when either button is pressed, id is passed through
	get_popup().id_pressed.connect(_on_item_menu_pressed)
	
#Function used when either button pressed.
func _on_item_menu_pressed(id: int):
	#Make panel_players visible, other menus invisible
	if id == 1:
		get_node("../../Panel_players").visible = true
		get_node("../../Panel_continents").visible = false
	#Make panel_continents visible, other menus invisible
	if id == 2:
		get_node("../../Panel_continents").visible = true
		get_node("../../Panel_players").visible = false

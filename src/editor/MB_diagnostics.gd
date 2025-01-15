extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready():
	#Add button with text "Validate", Id=1
	get_popup().add_item("Validate", 1)
	#Add button with text "Simulate", Id=2
	get_popup().add_item("Simulate", 2)
	#Calls function when either button is pressed, id is passed through
	get_popup().id_pressed.connect(_on_item_menu_pressed)

#Function used when either button pressed.
func _on_item_menu_pressed(id: int):
	#Validate button loops through region file and checks for NA values. also counts the regions in the file
	if id == 1:
		var total_regions = 0
		var total_warnings = 0
		get_node("../../Panel_validation").visible = true
		var dict_regions = get_node("../../..").dict_regions
		for color in dict_regions:
			total_regions = total_regions + 1
			var region = Label.new()
			region.text = ("Region " + str(color))
			
			if dict_regions[color][0] == "NA":
				total_warnings = total_warnings + 1
				var warningname = Label.new()
				warningname.text = " Missing Name value"
				get_node("../../Panel_validation/Panel_val_details/SC/VB").add_child(region)
				get_node("../../Panel_validation/Panel_val_details/SC/VB").add_child(warningname)
			if dict_regions[color][1] == 0:
				total_warnings = total_warnings + 1
				var warningcontinent = Label.new()
				warningcontinent.text = " Missing Continent value"
				get_node("../../Panel_validation/Panel_val_details/SC/VB").add_child(region)
				get_node("../../Panel_validation/Panel_val_details/SC/VB").add_child(warningcontinent)
		
		get_node("../../Panel_validation/Panel_val_summary/VB/HB/Label_sum_regions_input").set_text(str(total_regions))
		get_node("../../Panel_validation/Panel_val_summary/VB/HB2/Label_sum_warnings_input").set_text(str(total_warnings))	
	
	#Simulate button will initiate an instance of game.
	if id == 2:
		print("test 2")
	

#Open up the details panel on the validation pop-up
func _on_button_validation_details_button_up():
	if get_node("../../Panel_validation/Panel_val_details").visible == true:
		get_node("../../Panel_validation/Panel_val_details").visible = false
	else:
		get_node("../../Panel_validation/Panel_val_details").visible = true

#Close the details panel on the validation pop-up
func _on_button_close_validation_button_up():
	get_node("../../Panel_validation").visible = false

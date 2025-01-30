extends MenuButton

# References to UI elements
@onready var validation_panel = $"../../Panel_validation"
@onready var details_panel = $"../../Panel_validation/Panel_val_details"
@onready var validation_container = $"../../Panel_validation/Panel_val_details/SC/VB"
@onready var regions_count_label = $"../../Panel_validation/Panel_val_summary/VB/HB/Label_sum_regions_input"
@onready var warnings_count_label = $"../../Panel_validation/Panel_val_summary/VB/HB2/Label_sum_warnings_input"
@onready var map_image = $"../../../Sprite2D"

var db: SQLite

func _ready():
	get_popup().add_item("Validate", 1)
	get_popup().id_pressed.connect(_on_item_menu_pressed)
	db = get_node("../../..").db  # Get database reference from main node

func _on_item_menu_pressed(id: int):
	if id == 1:
		validate_regions()

func validate_regions():
	# Clear previous validation results
	for child in validation_container.get_children():
		child.queue_free()
	
	var total_warnings = 0
	var image_colors = get_image_colors()
	var db_colors = get_database_colors()
	
	# Check colors present in image but missing in database
	for color in image_colors:
		if not color in db_colors:
			total_warnings += 1
			add_warning_message("Region %s" % color, "Missing in database")
	
	# Check colors present in database but missing in image
	for color in db_colors:
		if not color in image_colors:
			total_warnings += 1
			add_warning_message("Region %s" % color, "Not found on map")
	
	# Update summary
	regions_count_label.text = str(image_colors.size())
	warnings_count_label.text = str(total_warnings)
	validation_panel.visible = true

func get_image_colors() -> Array:
	var colors = []
	var image = map_image.texture.get_image()
	
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color = "#" + image.get_pixel(x, y).to_html(false)
			if color != "#ffffff" and color != "#000000" and not color in colors:
				colors.append(color)
	
	return colors

func get_database_colors() -> Array:
	var colors = []
	db.query("SELECT ID_COLOR FROM REGION")
	
	for result in db.query_result:
		colors.append(result.ID_COLOR)
	
	return colors

func add_warning_message(region: String, warning: String):
	var region_label = Label.new()
	region_label.text = region
	
	var warning_label = Label.new()
	warning_label.text = " " + warning
	
	validation_container.add_child(region_label)
	validation_container.add_child(warning_label)

func _on_button_validation_details_button_up():
	details_panel.visible = !details_panel.visible

func _on_button_close_validation_button_up():
	validation_panel.visible = false

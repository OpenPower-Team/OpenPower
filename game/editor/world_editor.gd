# REFACTOR: This is the main controller for the editor scene.
# It manages state, handles input, and coordinates UI panels.
extends Node2D

@onready var _map_image: Sprite2D = $Sprite2D
@onready var _region_panel: Panel = $CanvasLayer/Panel_region
@onready var _owner_option_button: OptionButton = $CanvasLayer/Panel_region/VB/GC/OB_Owner
@onready var _color_code_label: Label = $CanvasLayer/Panel_region/VB/GC/Label_Colorcode
@onready var _region_name_edit: LineEdit = $CanvasLayer/Panel_region/VB/GC/LE_Name
@onready var _diagnostics_menu: MenuButton = $CanvasLayer/Panel_toolbar/MB_diagnostics

var _map_validator: MapValidator = MapValidator.new()

func _ready() -> void:
	_load_countries_into_options()
	_diagnostics_menu.validation_requested.connect(_on_validation_requested)

func _unhandled_input(event: InputEvent) -> void:
	# Only process clicks if no UI panel is blocking the view
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if _region_panel.visible:
			return

		var pos: Vector2 = get_local_mouse_position()
		var image: Image = _map_image.texture.get_image()
		
		if not image or pos.x < 0 or pos.y < 0 or pos.x >= image.get_width() or pos.y >= image.get_height():
			return
			
		var color_hex: String = "#" + image.get_pixelv(pos).to_html(false)
		
		# Ignore clicks on borders/background
		if color_hex != "#ffffff" and color_hex != "#000000":
			_show_region_panel(color_hex)

func _load_countries_into_options() -> void:
	_owner_option_button.clear()
	var countries: Array = DBManager.query("SELECT ID FROM COUNTRY ORDER BY ID")
	for country in countries:
		_owner_option_button.add_item(country.ID)

func _show_region_panel(color_hex: String) -> void:
	_region_panel.visible = true
	_color_code_label.text = color_hex
	
	var results: Array = DBManager.query("SELECT * FROM REGION WHERE ID_COLOR = ?", [color_hex])
	
	if not results.is_empty():
		var region: Dictionary = results[0]
		_region_name_edit.text = region.REGION_NAME
		_select_option_item(_owner_option_button, region.OWNER_PLTC_ID)
	else:
		_region_name_edit.text = "New Region"
		_owner_option_button.select(0)

func _select_option_item(button: OptionButton, text_to_find: String) -> void:
	for i in range(button.item_count):
		if button.get_item_text(i) == text_to_find:
			button.select(i)
			return
	button.select(0) # Default to first item if not found

func _on_button_region_save_button_up() -> void:
	var color: String = _color_code_label.text
	var region_name: String = _region_name_edit.text
	var owner_id: String = _owner_option_button.get_item_text(_owner_option_button.selected)
	
	DBManager.save_region(color, region_name, owner_id)
	
	_region_panel.visible = false

func _on_button_region_close_button_up() -> void:
	_region_panel.visible = false

func _on_validation_requested() -> void:
	var results: Dictionary = _map_validator.validate_map_against_db(_map_image.texture.get_image())
	var map_colors: PackedStringArray = _map_validator._get_image_colors(_map_image.texture.get_image())
	_diagnostics_menu.display_results(results, map_colors.size())

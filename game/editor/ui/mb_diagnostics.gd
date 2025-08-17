# REFACTOR: This script is now purely for UI control.
# It calls the MapValidator and displays the results.
extends MenuButton

signal validation_requested
signal validation_closed

@onready var _validation_panel: Panel = $"../../Panel_validation"
@onready var _details_panel: Panel = $"../../Panel_validation/Panel_val_details"
@onready var _validation_container: VBoxContainer = $"../../Panel_validation/Panel_val_details/SC/VB"
@onready var _regions_count_label: Label = $"../../Panel_validation/Panel_val_summary/VB/HB/Label_sum_regions_input"
@onready var _warnings_count_label: Label = $"../../Panel_validation/Panel_val_summary/VB/HB2/Label_sum_warnings_input"

func _ready() -> void:
	get_popup().add_item("Validate Map", 1)
	get_popup().id_pressed.connect(_on_item_menu_pressed)

func _on_item_menu_pressed(id: int) -> void:
	if id == 1:
		validation_requested.emit()

func display_results(results: Dictionary, map_colors_count: int) -> void:
	# Clear previous validation results
	for child in _validation_container.get_children():
		child.queue_free()
	
	var total_warnings: int = 0
	
	for color in results.map_only:
		total_warnings += 1
		_add_warning_message("Region %s" % color, "Missing in database")

	for color in results.db_only:
		total_warnings += 1
		_add_warning_message("Region %s" % color, "Not found on map")
		
	_regions_count_label.text = str(map_colors_count)
	_warnings_count_label.text = str(total_warnings)
	_validation_panel.visible = true

func _add_warning_message(region: String, warning: String) -> void:
	# REFACTOR: Using a horizontal container for better alignment.
	var hbox := HBoxContainer.new()
	var region_label := Label.new()
	region_label.text = region
	region_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var warning_label := Label.new()
	warning_label.text = warning
	warning_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	hbox.add_child(region_label)
	hbox.add_child(warning_label)
	_validation_container.add_child(hbox)

func _on_button_validation_details_button_up() -> void:
	_details_panel.visible = not _details_panel.visible

func _on_button_close_validation_button_up() -> void:
	_validation_panel.visible = false
	validation_closed.emit()

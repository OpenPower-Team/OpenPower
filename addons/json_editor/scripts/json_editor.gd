@tool
extends Control

enum ValueType {
	STRING,
	NUMBER,
	BOOLEAN,
	DICTIONARY,
	ARRAY
}

# Node references
@onready var file_path_edit: LineEdit = %FilePathEdit
@onready var json_edit: TextEdit = %JsonEdit
@onready var status_label: Label = %StatusLabel
@onready var file_dialog: FileDialog = %FileDialog
@onready var json_tree: Tree = %JsonTree
@onready var edit_dialog: Window = %EditDialog
@onready var edit_key: LineEdit = %EditKey
@onready var edit_value: LineEdit = %EditValue
@onready var add_dialog: Window = %AddDialog
@onready var add_key: LineEdit = %AddKey
@onready var add_value: LineEdit = %AddValue
@onready var type_option: OptionButton = %TypeOption
@onready var edit_type_option: OptionButton = %EditTypeOption

# Data management
var current_file_path: String = ""
var current_data: Variant
var current_item: TreeItem

func _ready() -> void:
	# Disconnect all possible old connections
	_disconnect_all_signals()

	# Reconnect all signals
	_connect_all_signals()

	# Initialize interface
	_initialize_interface()

func _disconnect_all_signals() -> void:
	# Button signals
	if %LoadButton.pressed.is_connected(_on_load_pressed):
		%LoadButton.pressed.disconnect(_on_load_pressed)
	if %SaveButton.pressed.is_connected(_on_save_pressed):
		%SaveButton.pressed.disconnect(_on_save_pressed)
	if %BrowseButton.pressed.is_connected(_on_browse_pressed):
		%BrowseButton.pressed.disconnect(_on_browse_pressed)

	# File dialog signals
	if file_dialog.file_selected.is_connected(_on_file_selected):
		file_dialog.file_selected.disconnect(_on_file_selected)

	# Tree view signals
	if json_tree.item_activated.is_connected(_on_tree_item_activated):
		json_tree.item_activated.disconnect(_on_tree_item_activated)

	# Edit dialog signals
	if %EditConfirm.pressed.is_connected(_on_edit_confirm):
		%EditConfirm.pressed.disconnect(_on_edit_confirm)
	if %EditCancel.pressed.is_connected(_on_edit_cancel):
		%EditCancel.pressed.disconnect(_on_edit_cancel)
	if %DeleteButton.pressed.is_connected(_on_delete_pressed):
		%DeleteButton.pressed.disconnect(_on_delete_pressed)
	if %AddNewButton.pressed.is_connected(_on_add_new_pressed):
		%AddNewButton.pressed.disconnect(_on_add_new_pressed)
	if edit_dialog.close_requested.is_connected(_on_edit_cancel):
		edit_dialog.close_requested.disconnect(_on_edit_cancel)

	# Add dialog signals
	if %AddConfirm.pressed.is_connected(_on_add_confirm):
		%AddConfirm.pressed.disconnect(_on_add_confirm)
	if %AddCancel.pressed.is_connected(_on_add_cancel):
		%AddCancel.pressed.disconnect(_on_add_cancel)
	if add_dialog.close_requested.is_connected(_on_add_cancel):
		add_dialog.close_requested.disconnect(_on_add_cancel)

	# Type selection signals
	if type_option.item_selected.is_connected(_on_type_selected):
		type_option.item_selected.disconnect(_on_type_selected)

func _connect_all_signals() -> void:
	# Button signals
	%LoadButton.pressed.connect(_on_load_pressed)
	%SaveButton.pressed.connect(_on_save_pressed)
	%BrowseButton.pressed.connect(_on_browse_pressed)
	file_dialog.file_selected.connect(_on_file_selected)

	# Tree view signals
	json_tree.item_activated.connect(_on_tree_item_activated)

	# Edit dialog signals
	%EditConfirm.pressed.connect(_on_edit_confirm)
	%EditCancel.pressed.connect(_on_edit_cancel)
	%DeleteButton.pressed.connect(_on_delete_pressed)
	%AddNewButton.pressed.connect(_on_add_new_pressed)
	edit_dialog.close_requested.connect(_on_edit_cancel)

	# Add dialog signals
	%AddConfirm.pressed.connect(_on_add_confirm)
	%AddCancel.pressed.connect(_on_add_cancel)
	add_dialog.close_requested.connect(_on_add_cancel)

	# Type selection signals
	type_option.item_selected.connect(_on_type_selected)

func _initialize_interface() -> void:
	# Set tree column titles
	json_tree.set_column_title(0, "Key")
	json_tree.set_column_title(1, "Value")
	json_tree.set_column_expand(0, true)
	json_tree.set_column_expand(1, true)
	json_tree.set_column_custom_minimum_width(0, 150)
	json_tree.set_column_custom_minimum_width(1, 150)

	# Set file dialog
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = PackedStringArray(["*.json ; JSON Files"])

	# Initialize type selection dropdown
	type_option.clear()
	type_option.add_item("String", ValueType.STRING)
	type_option.add_item("Number", ValueType.NUMBER)
	type_option.add_item("Boolean", ValueType.BOOLEAN)
	type_option.add_item("Dictionary", ValueType.DICTIONARY)
	type_option.add_item("Array", ValueType.ARRAY)

	# Initialize edit dialog type selection
	edit_type_option.clear()
	edit_type_option.add_item("String", ValueType.STRING)
	edit_type_option.add_item("Number", ValueType.NUMBER)
	edit_type_option.add_item("Boolean", ValueType.BOOLEAN)

	# Set window parent
	edit_dialog.gui_embed_subwindows = false
	add_dialog.gui_embed_subwindows = false

func _update_tree_view(data: Variant) -> void:
	json_tree.clear()
	var root = json_tree.create_item()
	root.set_text(0, "Root")
	root.set_metadata(0, {
		"is_container": true,
		"container_data": data,
		"parent_data": null,
		"key": null
	})
	_add_json_to_tree(data, root)

func _add_json_to_tree(data: Variant, parent: TreeItem) -> void:
	match typeof(data):
		TYPE_DICTIONARY:
			for key in data:
				var item = json_tree.create_item(parent)
				item.set_text(0, str(key))
				if typeof(data[key]) in [TYPE_DICTIONARY, TYPE_ARRAY]:
					_add_json_to_tree(data[key], item)
					item.set_metadata(0, {
						"is_container": true,
						"container_data": data[key],
						"parent_data": data,
						"key": key
					})
				else:
					item.set_text(1, str(data[key]))
					item.set_metadata(0, {"key": key, "value": data[key], "parent_data": data})
		TYPE_ARRAY:
			for i in range(data.size()):
				var item = json_tree.create_item(parent)
				item.set_text(0, str(i))
				if typeof(data[i]) in [TYPE_DICTIONARY, TYPE_ARRAY]:
					_add_json_to_tree(data[i], item)
					item.set_metadata(0, {
						"is_container": true,
						"container_data": data[i],
						"parent_data": data,
						"key": i
					})
				else:
					item.set_text(1, str(data[i]))
					item.set_metadata(0, {"key": i, "value": data[i], "parent_data": data})

func _on_tree_item_activated() -> void:
	var selected = json_tree.get_selected()
	if not selected:
		return

	var metadata = selected.get_metadata(0)
	if not metadata:
		return

	if metadata.get("is_container", false):
		current_item = selected
		edit_key.text = str(metadata.get("key", ""))
		edit_value.text = "Container type"
		edit_value.editable = false
		%EditTypeOption.visible = false
		%EditTypeLabel.visible = false
		%AddNewButton.visible = true
		var is_root = metadata["parent_data"] == null
		%DeleteButton.visible = not is_root
		edit_key.editable = not is_root
		edit_dialog.popup_centered()
	else:
		current_item = selected
		edit_key.text = str(metadata["key"])
		edit_value.text = str(metadata["value"])
		edit_value.editable = true
		%EditTypeOption.visible = true
		%EditTypeLabel.visible = true
		%AddNewButton.visible = false
		%DeleteButton.visible = true
		edit_key.editable = true

		var value = metadata["value"]
		match typeof(value):
			TYPE_INT, TYPE_FLOAT:
				%EditTypeOption.select(ValueType.NUMBER)
			TYPE_BOOL:
				%EditTypeOption.select(ValueType.BOOLEAN)
			_:
				%EditTypeOption.select(ValueType.STRING)

		edit_dialog.popup_centered()

func _on_edit_confirm() -> void:
	if not current_item:
		return

	var metadata = current_item.get_metadata(0)
	var parent_data = metadata["parent_data"]
	var old_key = metadata.get("key", "")
	var new_key = edit_key.text

	if metadata.get("is_container", false):
		var container_data = metadata["container_data"]
		if typeof(parent_data) == TYPE_DICTIONARY and old_key != new_key:
			parent_data.erase(old_key)
			parent_data[new_key] = container_data
	else:
		var new_value = edit_value.text
		var selected_type = %EditTypeOption.get_selected_id()

		match selected_type:
			ValueType.STRING:
				new_value = str(new_value)
			ValueType.NUMBER:
				if new_value.is_valid_int():
					new_value = new_value.to_int()
				elif new_value.is_valid_float():
					new_value = new_value.to_float()
				else:
					_show_status("Invalid number format", true)
					return
			ValueType.BOOLEAN:
				if new_value.to_lower() in ["true", "false"]:
					new_value = new_value.to_lower() == "true"
				else:
					_show_status("Invalid boolean value", true)
					return

		if typeof(parent_data) == TYPE_DICTIONARY:
			if old_key != new_key:
				parent_data.erase(old_key)
			parent_data[new_key] = new_value
		elif typeof(parent_data) == TYPE_ARRAY:
			parent_data[old_key] = new_value

	_update_tree_view(current_data)
	json_edit.text = JSON.stringify(current_data, "\t")
	edit_dialog.hide()

func _on_edit_cancel() -> void:
	edit_dialog.hide()

func _on_add_confirm() -> void:
	if not current_item:
		return

	var metadata = current_item.get_metadata(0)
	var container_data = metadata["container_data"]
	var new_key = add_key.text
	var new_value = add_value.text
	var selected_type = type_option.get_selected_id()

	match selected_type:
		ValueType.STRING:
			new_value = str(new_value)
		ValueType.NUMBER:
			if new_value.is_valid_int():
				new_value = new_value.to_int()
			elif new_value.is_valid_float():
				new_value = new_value.to_float()
			else:
				_show_status("Invalid number format", true)
				return
		ValueType.BOOLEAN:
			if new_value.to_lower() in ["true", "false"]:
				new_value = new_value.to_lower() == "true"
			else:
				_show_status("Invalid boolean value", true)
				return
		ValueType.DICTIONARY:
			new_value = {}
		ValueType.ARRAY:
			new_value = []

	if typeof(container_data) == TYPE_DICTIONARY:
		if new_key.is_empty():
			_show_status("Key cannot be empty", true)
			return
		container_data[new_key] = new_value
	elif typeof(container_data) == TYPE_ARRAY:
		container_data.append(new_value)

	if metadata["parent_data"] == null:
		current_data = container_data

	_update_tree_view(current_data)
	json_edit.text = JSON.stringify(current_data, "\t")
	add_dialog.hide()

func _on_add_cancel() -> void:
	add_dialog.hide()

func _on_save_pressed() -> void:
	if current_file_path.is_empty():
		_show_status("Please load or specify a file path first", true)
		return

	var json = JSON.new()
	var error = json.parse(json_edit.text)
	if error != OK:
		_show_status("JSON parse error: " + json.get_error_message(), true)
		return

	if JsonEditorManager.save_json(current_file_path, json.get_data()):
		_show_status("Save successful")
	else:
		_show_status("Save failed", true)

func _on_browse_pressed() -> void:
	file_dialog.popup_centered_ratio(0.7)

func _on_file_selected(path: String) -> void:
	file_path_edit.text = path
	_on_load_pressed()

func _show_status(message: String, is_error: bool = false) -> void:
	status_label.text = message
	status_label.modulate = Color.RED if is_error else Color.GREEN

func _on_delete_pressed() -> void:
	if not current_item:
		return

	var metadata = current_item.get_metadata(0)
	if metadata["parent_data"] == null:
		_show_status("Cannot delete root node", true)
		return

	var parent_data = metadata["parent_data"]
	var key = metadata["key"]

	if typeof(parent_data) == TYPE_DICTIONARY:
		parent_data.erase(key)
	elif typeof(parent_data) == TYPE_ARRAY:
		parent_data.remove_at(key)
		for i in range(key, parent_data.size()):
			var item = json_tree.get_root().find_child(str(i + 1), true, false)
			if item:
				var item_metadata = item.get_metadata(0)
				if item_metadata:
					item_metadata["key"] = i
					item.set_text(0, str(i))

	_update_tree_view(current_data)
	json_edit.text = JSON.stringify(current_data, "\t")
	edit_dialog.hide()

func _on_add_new_pressed() -> void:
	if not current_item:
		return

	var metadata = current_item.get_metadata(0)
	if not metadata.get("is_container", false):
		return

	edit_dialog.hide()
	add_key.text = ""
	add_value.text = ""
	type_option.select(0)
	add_value.editable = true
	add_dialog.popup_centered()

func _on_type_selected(index: int) -> void:
	var type = type_option.get_item_id(index)
	add_value.editable = type not in [ValueType.DICTIONARY, ValueType.ARRAY]
	if not add_value.editable:
		add_value.text = "Container type"
	else:
		add_value.text = ""

func _on_load_pressed() -> void:
	var path = file_path_edit.text
	if path.is_empty():
		_show_status("Please enter a file path", true)
		return

	var data = JsonEditorManager.load_json(path)
	if data == null:
		_show_status("Load failed", true)
		return

	current_data = data
	json_edit.text = JSON.stringify(data, "\t")
	current_file_path = path
	_show_status("Load successful")
	_update_tree_view(data)

func _on_path_text_submitted(new_text : String = ""):
	if new_text != "":
		current_file_path = new_text
		_on_load_pressed()

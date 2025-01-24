class_name JsonEditorManager
extends RefCounted

static func load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)

	if error != OK:
		print("JSON parse error: ", json.get_error_message())
		return null

	return json.get_data()

static func save_json(path: String, data: Variant) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(data, "\t"))
	return true
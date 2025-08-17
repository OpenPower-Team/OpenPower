# REFACTOR: All validation logic is now in this class, decoupled from UI.
# It returns pure data, which the UI can then display.
class_name MapValidator
extends RefCounted

# Result structure: { "db_only": [], "map_only": [] }
func validate_map_against_db(map_image: Image) -> Dictionary:
	var validation_results := {
		"db_only": [],
		"map_only": []
	}
	
	var map_colors: PackedStringArray = _get_image_colors(map_image)
	var db_colors_data: Array = DBManager.get_all_region_colors()
	var db_colors := PackedStringArray()
	for item in db_colors_data:
		db_colors.append(item["ID_COLOR"])

	var map_colors_set := {}
	for color in map_colors: map_colors_set[color] = true
	
	var db_colors_set := {}
	for color in db_colors: db_colors_set[color] = true

	# Check for colors in map but not in DB
	for color in map_colors:
		if not db_colors_set.has(color):
			validation_results.map_only.append(color)
	
	# Check for colors in DB but not in map
	for color in db_colors:
		if not map_colors_set.has(color):
			validation_results.db_only.append(color)
			
	return validation_results

func _get_image_colors(image: Image) -> PackedStringArray:
	var colors := PackedStringArray()
	if not image:
		return colors
		
	var used_colors := {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color_obj: Color = image.get_pixel(x, y)
			# Ignore pure white and black, often used for borders/background
			if color_obj == Color.WHITE or color_obj == Color.BLACK:
				continue
				
			var color_hex: String = "#" + color_obj.to_html(false)
			if not used_colors.has(color_hex):
				used_colors[color_hex] = true
				colors.append(color_hex)
	return colors

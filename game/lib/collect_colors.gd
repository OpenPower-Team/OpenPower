extends Node

func collect_colors_to_json(image_path: String, output_file: String) -> void:
	# Завантажуємо зображення
	var image = Image.new()
	var error = image.load(image_path)
	
	if error != OK:
		print("Помилка завантаження зображення:", error)
		return
	
	# Переконуємося, що зображення у форматі RGB
	if not image.format_has_alpha():
		image.convert(Image.FORMAT_RGB8)
	else:
		image.convert(Image.FORMAT_RGBA8)
	
	# Множина для унікальних кольорів
	var colors_set := {}
	
	# Обходимо кожен піксель зображення
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color = image.get_pixel(x, y)
			var hex_color = "#" + color.to_html(false)
			colors_set[hex_color] = "UnknownRegion"
	
	# Конвертуємо результат у JSON
	var json_data = JSON.stringify(colors_set, "\t")
	
	# Записуємо у файл
	var file = FileAccess.open(output_file, FileAccess.ModeFlags.WRITE)
	if error != OK:
		print("Помилка запису у файл:", error)
		return
	
	file.store_string(json_data)
	file.close()
	print("Кольори успішно збережено у", output_file)

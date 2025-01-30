extends Node2D

@onready var map_image = $Sprite2D
@onready var owner_option = $CanvasLayer/Panel_region/VB/GC/OB_Owner
var db : SQLite

func _ready():
	init_database()
	load_countries()

func init_database():
	db = SQLite.new()
	db.path = "res://data/data.sqlite3"
	if not db.open_db():
		push_error("Failed to open database")
		return
	
	# Create tables if not exists
	db.query("""
		CREATE TABLE IF NOT EXISTS REGION (
			ID_COLOR TEXT PRIMARY KEY,
			REGION_NAME TEXT,
			OWNER_PLTC_ID TEXT REFERENCES COUNTRY(ID)
		)
	""")
	
	db.query("""
		CREATE TABLE IF NOT EXISTS COUNTRY (
			ID TEXT PRIMARY KEY,
			NAME TEXT
		)
	""")

func load_countries():
	owner_option.clear()
	db.query("SELECT ID FROM COUNTRY ORDER BY ID")
	for country in db.query_result:
		owner_option.add_item(country.ID)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var pos = get_local_mouse_position()
		if map_image.texture == null || map_image.texture.get_image() == null:
			print("Texture or image missing")
			return
			
		var color = "#" + str(map_image.texture.get_image().get_pixelv(pos).to_html(false))
		if color != "#ffffff" && color != "#000000":
			show_region_panel(color)

func show_region_panel(color: String):
	get_node("CanvasLayer/Panel_region").visible = true
	get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").text = color
	db.query("SELECT ID_COLOR FROM REGION")
	#print("All colors in database: ", db.query_result)  # Debug output
	 
	db.query("SELECT * FROM REGION WHERE ID_COLOR = '%s'" % color) 
	print("Query result: ", db.query_result)  # Debug output
	
	if db.query_result.size() > 0:
		var region = db.query_result[0]
		get_node("CanvasLayer/Panel_region/VB/GC/LE_Name").text = region.REGION_NAME
		select_country(region.OWNER_PLTC_ID)
	else:
		get_node("CanvasLayer/Panel_region/VB/GC/LE_Name").text = "New Region"
		owner_option.select(0)

func select_country(country_code: String):
	for i in range(owner_option.item_count):
		if owner_option.get_item_text(i) == country_code:
			owner_option.select(i)
			return
	owner_option.select(0)

func _on_button_region_save_button_up():
	var color = get_node("CanvasLayer/Panel_region/VB/GC/Label_Colorcode").text
	var region_name = get_node("CanvasLayer/Panel_region/VB/GC/LE_Name").text
	var country_code = owner_option.get_item_text(owner_option.selected)
	
	db.query("""
		INSERT OR REPLACE INTO REGION 
		(ID_COLOR, REGION_NAME, OWNER_PLTC_ID) 
		VALUES ('%s', '%s', '%s')
	""" % [color, region_name, country_code])
	
	get_node("CanvasLayer/Panel_region").visible = false

func _on_button_region_close_button_up():
	get_node("CanvasLayer/Panel_region").visible = false

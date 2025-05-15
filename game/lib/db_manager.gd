extends Node

class_name DBManager

var db_path: String

func _init(db_path: String):
	self.db_path = db_path

func _ready():
	pass

func connect_to_db():
	var db = SQLite.new()
	db.path = self.db_path
	var error = db.open_db()
	if error != OK:
		push_error("Failed to connect to the database: ", error)
		return null
	return db

func fetch_countries():
	var db = connect_to_db()
	if db == null:
		return []
	var query = "SELECT ID, FLAG FROM COUNTRY"
	var result = db.execute(query)
	db.close()
	return result

func fetch_regions(country_id: String):
	var db = connect_to_db()
	if db == null:
		return []
	var query = "SELECT ID_COLOR, REGION_NAME, OWNER_PLTC_ID FROM REGION WHERE OWNER_PLTC_ID = ?"
	var result = db.execute(query, [country_id])
	db.close()
	return result

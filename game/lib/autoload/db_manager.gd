# REFACTOR: This is now an autoload singleton for global access.
# It handles all database connections and queries, keeping that logic
# separate from UI or game systems.
extends Node

const DB_PATH: String = "res://data/data.sqlite3"
var _db: SQLite

func _ready() -> void:
	_db = SQLite.new()
	_db.path = DB_PATH
	if not _db.open_db():
		push_error("GECS DEV: Failed to open database at path: %s" % DB_PATH)

# Generic query function to handle errors and parameter binding safely.
func query(statement: String, params: Array = []) -> Array:
	if not _db:
		push_error("GECS DEV: Database is not open.")
		return []

	# FIX: Execute the query first into a generic Variant.
	var query_execution_result = _db.query_with_bindings(statement, params)
	
	# FIX: Check for errors BEFORE trying to assign to the typed Array variable.
	# The SQLite wrapper returns false on failure.
	if not query_execution_result:
		push_error("GECS DEV: DB Query Error on '%s': %s" % [statement, _db.error_message])
		return []
		
	var result: Array = _db.query_result
	return result

func get_all_countries() -> Array:
	return query("SELECT ID, FLAG FROM COUNTRY")

func get_regions_for_country(country_id: String) -> Array:
	var sql: String = "SELECT ID_COLOR, REGION_NAME, OWNER_PLTC_ID, POP_15, POP_15_65, POP_65 FROM REGION WHERE OWNER_PLTC_ID = ?"
	return query(sql, [country_id])

func get_all_region_colors() -> Array:
	return query("SELECT ID_COLOR FROM REGION")

# FIX: Renamed 'name' to 'region_name' to avoid shadowing Node.name.
func save_region(color: String, region_name: String, owner_id: String) -> void:
	var sql: String = """
		INSERT OR REPLACE INTO REGION (ID_COLOR, REGION_NAME, OWNER_PLTC_ID)
		VALUES (?, ?, ?)
	"""
	query(sql, [color, region_name, owner_id])
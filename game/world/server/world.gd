extends Node

var countries: Array
var db_manager: DBManager

func _ready():
	db_manager = DBManager.new("res://data/data.sqlite3")
	load_countries()

func load_countries():
	var country_data = db_manager.fetch_countries()
	countries = []
	
	for row in country_data:
		var country_id = row["ID"]
		var country = Country.new(country_id)
		load_regions(country)
		countries.append(country)
	
	print("Loaded data for ", countries.size(), " countries.")
	select_player_country()

func load_regions(country: Country):
	var region_data = db_manager.fetch_regions(country.id)
	
	for row in region_data:
		var region = Region.new(row["ID_COLOR"], row["REGION_NAME"], country)
		region.pop_15 = row["POP_15"]
		region.pop_15_65 = row["POP_15-65"]
		region.pop_65 = row["POP_65"]

func select_player_country():
	print("Selecting player country...")
	# For now, just pick the first country.  Later, get actual player input.
	if countries.size() > 0:
		countries[0].is_player_controlled = true
		print("Country ", countries[0].id, " is now player-controlled.")

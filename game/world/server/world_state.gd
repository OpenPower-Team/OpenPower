extends Node

signal world_paused
signal game_unpaused

# Singleton instance
var instance = null

# Game clock variables
var game_date = {"day": 1, "month": 1, "year": 2001, "hour": 0, "minute": 0}
var game_speed = pow(60, 1 - 1) # multiplier
var _time_passed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	set_process(true)

# Called every frame.
func _process(delta):
	if not paused:
		_time_passed += delta * game_speed
		#print("Time passed:", _time_passed)
		while _time_passed >= 1:
			_time_passed -= 1
			_increment_minute()

## Is the game paused
var paused :bool = false:
	get:
		return paused
	set(v):
		paused = v
		if v:
			world_paused.emit()
		else:
			game_unpaused.emit()

# Increment the game clock by one minute.
func _increment_minute():
	game_date["minute"] += 1
	if game_date["minute"] >= 60:
		game_date["minute"] = 0
		_increment_hour()

# Increment the game clock by one hour.
func _increment_hour():
	game_date["hour"] += 1
	if game_date["hour"] >= 24:
		game_date["hour"] = 0
		_increment_day()

# Increment the game clock by one day.
func _increment_day():
	game_date["day"] += 1
	if game_date["day"] > _days_in_month(game_date["month"], game_date["year"]):
		game_date["day"] = 1
		_increment_month()

# Increment the game clock by one month.
func _increment_month():
	game_date["month"] += 1
	if game_date["month"] > 12:
		game_date["month"] = 1
		_increment_year()

# Increment the game clock by one year.
func _increment_year():
	game_date["year"] += 1

# Get the number of days in a month, considering leap years.
func _days_in_month(month, year):
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			return 29 if (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)) else 28
	return 30

'''
# Save the current game date to a file.
func save_game_date():
	var file = File.new()
	file.open("user://game_date.save", File.WRITE)
	file.store_line(str(game_date["day"]).pad_zeroes(2) + ":" + str(game_date["month"]).pad_zeroes(2) + ":" + str(game_date["year"]) + " " + str(game_date["hour"]).pad_zeroes(2) + ":" + str(game_date["minute"]).pad_zeroes(2))
	file.close()

# Load the game date from a file.
func load_game_date():
	var file = File.new()
	if file.file_exists("user://game_date.save"):
		file.open("user://game_date.save", File.READ)
		var saved_date = file.get_line().strip_edges().split([":", " "])
		game_date["day"] = int(saved_date[0])
		game_date["month"] = int(saved_date[1])
		game_date["year"] = int(saved_date[2])
		game_date["hour"] = int(saved_date[3])
		game_date["minute"] = int(saved_date[4])
		file.close()
'''

class_name Country

var id: String # Use 'id' instead of 'name'
# var total_population: int # Not directly stored in the database for Country
# var gdp: float # Not in the database schema
var regions: Array
var flag: String
var is_player_controlled: bool = false

func _init(id: String):
    self.id = id
    self.regions = []

func add_region(region):
    regions.append(region)

# Not needed, calculated dynamically
# func update_total_population():
#     total_population = 0
#     for region in regions:
#         total_population += region.population
#     emit_signal("total_population_changed", total_population)

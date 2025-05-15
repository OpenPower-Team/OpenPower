class_name Region

var id_color: String # Use 'id_color'
var region_name: String # Use 'region_name'
var pop_15: int
var pop_15_65: int
var pop_65: int
var owner_pltc_id: Country

func _init(id_color: String, region_name: String, owner_pltc_id: Country):
    self.id_color = id_color
    self.region_name = region_name
    self.owner_pltc_id = owner_pltc_id
    owner_pltc_id.add_region(self)

# We don't emit signal, because we don't set population here
# signal population_changed(new_population)

# func set_population(new_population: int):
#     self.population = new_population
#     emit_signal("population_changed", self.population)
#     owner_pltc_id.update_total_population()

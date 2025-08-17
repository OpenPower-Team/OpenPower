class_name WorldInitializationSystem
extends System

# This system runs only once at the start.
var _has_run: bool = false

func query() -> QueryBuilder:
	# This query ensures the system runs only if it hasn't run before
	# and the world is ready. It will return an empty array after the first run.
	return q if not _has_run else q.with_none([Entity])

# FIX: Added underscore to unused parameters to remove warnings.
func process(_entity: Entity, _delta: float) -> void:
	# The process function is just a trigger; all logic is in process_all.
	pass

# FIX: Changed signature to match parent class (must return bool).
# FIX: Added underscore to unused parameters.
func process_all(_entities: Array, _delta: float) -> bool:
	if _has_run:
		return true
	
	print("GECS DEV: WorldInitializationSystem running...")
	var countries_data: Array = DBManager.get_all_countries()
	var country_entities: Dictionary = {}

	# 1. Create Country Entities
	for country_row in countries_data:
		var country_id: String = country_row["ID"]
		var country_entity: Entity = CountryEntity.new()
		country_entity.name = country_id
		
		var country_data_comp := C_CountryData.new()
		country_data_comp.id = country_id
		country_data_comp.flag_path = country_row["FLAG"]
		
		country_entity.add_components([
			country_data_comp,
			C_Stability.new() # Add base stability
		])
		country_entities[country_id] = country_entity

	# 2. Create Region Entities and link them to Countries
	for country_id in country_entities:
		var country_entity: Entity = country_entities[country_id]
		var regions_data: Array = DBManager.get_regions_for_country(country_id)
		
		for region_row in regions_data:
			var region_entity: Entity = RegionEntity.new()
			region_entity.name = region_row["REGION_NAME"]
			
			var region_data_comp := C_RegionData.new()
			region_data_comp.color_id = region_row["ID_COLOR"]
			region_data_comp.region_name = region_row["REGION_NAME"]
			
			var population_comp := C_Population.new()
			population_comp.pop__15 = region_row["POP_15"]
			population_comp.pop_15_65 = region_row["POP_15-65"]
			population_comp.pop_65_ = region_row["POP_65"]
			
			region_entity.add_components([
				region_data_comp,
				population_comp
			])
			
			# Create a parent-child relationship
			var rel_owner: Relationship = Relationship.new(C_OwnerOf.new(), country_entity)
			region_entity.add_relationship(rel_owner)
			
			ECS.world.add_entity(region_entity)

	# 3. Add all country entities to the world
	ECS.world.add_entities(country_entities.values())
	
	print("GECS DEV: World initialized with %d countries and their regions." % country_entities.size())
	_has_run = true
	
	# FIX: Must return a boolean value.
	return true
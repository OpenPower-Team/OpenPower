## System[br]
## The base class for all systems within the ECS framework.[br]
##
## Systems contain the core logic and behavior, processing [Entity]s that have specific [Component]s.[br]
## Each system overrides the [method System.query] and returns a query using the [QueryBuilder] [br]
## exposed as [member System.q] required for it to process an [Entity] and implements the [method System.process] method.[br][br]
## [b]Example:[/b]
##[codeblock]
##     class_name MovementSystem
##     extends System
##
##     func query():
##         return q.with_all([Transform, Velocity])
##
##     func process(entity: Entity, delta: float) -> void:
##         var transform = entity.get_component(Transform)
##         var velocity = entity.get_component(Velocity)
##         transform.position += velocity.direction * velocity.speed * delta
##[/codeblock]
@icon('res://addons/gecs/assets/system.svg')
class_name System
extends Node

## What group this system belongs to. Systems can be organized and run by group
@export var group: String = ''
## Determines whether the system should run even when there are no [Entity]s to process.
@export var process_empty := false
## Is this system active. (Will be skipped if false)
@export var active:= true
## The [QueryBuilder] object exposed for conveinence to use in the system and to create the query.
var q: QueryBuilder

var systemLogger = GECSLogger.new().domain('System')

var _using_subsystems = true

## Override this method and return a [QueryBuilder] to define the required [Component]s for the system.[br]
## If not overridden, the system will run on every update with no entities.
func query() -> QueryBuilder:
	process_empty = true
	return q

## Override this method to define any sub-systems that should be processed by this system.[br]
func sub_systems():
	_using_subsystems = false # If this method is not overridden then we are not using sub systems
	return []

## Runs once after the system has been added to the [World] to setup anything on the system one time[br]
func setup():
	pass

## The main processing function for the system.[br]
## This method should be overridden by subclasses to define the system's behavior.[br]
## [param entity] The [Entity] being processed.[br]
## [param delta] The time elapsed since the last frame.
func process(entity: Entity, delta: float) -> void:
	assert(false, "The 'process' method must be overridden in subclasses if it is not using sub systems.")

## Sometimes you want to process all entities that match the system's query, this method does that.[br]
## This way instead of running one function for each entity you can run one function for all entities.[br]
## By default this method will run the [method System.process] method for each entity.[br]
## but you can override this method to do something different.[br]
## [param entities] The [Entity]s to process.[br]
## [param delta] The time elapsed since the last frame.
func process_all(entities: Array, delta: float) -> bool:
	# If we have no entities and we want to process even when empty do it once and return
	if entities.size() == 0 and process_empty:
		process(null, delta)
		return true
	var did_run = false
	# otherwise process all the entities (wont happen if empty array)
	for entity in entities:
		did_run = true
		process(entity, delta)
		entity.on_update(delta)
	return did_run

## handles the processing of all [Entity]s that match the system's query [Component]s.[br]
## [param delta] The time elapsed since the last frame.
func _handle(delta: float):
	if _handle_subsystems(delta):
		return
	# Set our QueryBuilder RefCounted Object
	q = ECS.world.query
	var did_run := false
	# Query for the entities that match the system's query
	var entities = query().execute()
	did_run = process_all(entities, delta)
	if did_run:
		# Log the whole thing
		_log_handle(entities)
		entities.map(func(e): e.on_update(delta))

func _handle_subsystems(delta: float):
	var subsystems = sub_systems()
	if not _using_subsystems:
		return false
	q = ECS.world.query
	var sub_systems_ran = false
	for sub_sys_tuple in subsystems:
		var did_run = false
		sub_systems_ran = true
		var query = sub_sys_tuple[0]
		var sub_sys_process = sub_sys_tuple[1] as Callable
		var should_process_all = sub_sys_tuple[2] if sub_sys_tuple.size() > 2 else false
		var entities = query.execute() as Array[Entity]
		if should_process_all:
			did_run = sub_sys_process.call(entities, delta)
		else:
			for entity in entities:
				did_run = true
				sub_sys_process.call(entity, delta)
		if did_run:
			# Log the whole thing
			_log_handle(entities)
			entities.map(func(e): e.on_update(delta))
	return sub_systems_ran

func _log_handle(entities):
	systemLogger.trace("""
[%s]
  -> Query: %s
  -> Entities: %s
""" % [self, q, entities])

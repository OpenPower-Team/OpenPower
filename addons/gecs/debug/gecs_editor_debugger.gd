class_name GECSEditorDebugger
extends EditorDebuggerPlugin

## The Debugger session for the current game
var session: EditorDebuggerSession
## The tab that will be added to the debugger window
var debugger_tab = (
	preload("res://addons/gecs/debug/gecs_editor_debugger_tab.tscn").instantiate()
	as GECSEditorDebuggerTab
)
## The debugger messages that will be sent to the editor debugger
var Msg = GECSEditorDebuggerMessages.Msg


func _has_capture(capture):
	# Return true if you wish to handle messages with the prefix "gecs:".
	return capture == "gecs"


func _capture(message: String, data: Array, session_id: int) -> bool:
	if message == Msg.WORLD_INIT:
		# data: [World.get_path()]
		var world = data[0]
		var world_path = data[1]
		debugger_tab.world_init(data[0], data[1])
		return true
	elif message == Msg.SYSTEM_METRIC:
		# data: [system, system_name, elapsed_time]
		var system = data[0]
		var system_name = data[1]
		var elapsed_time = data[2]
		debugger_tab.system_metric(system, system_name, elapsed_time)
		return true
	elif message == Msg.SET_WORLD:
		if data.size() == 0:
			return true
		var world = data[0]
		var world_path = data[1]
		debugger_tab.set_world(world, world_path)
		return true
	elif message == Msg.PROCESS_WORLD:
		# data: [float, String]
		var delta = data[0]
		var group_name = data[1]
		debugger_tab.process_world(delta, group_name)
		return true
	elif message == Msg.EXIT_WORLD:
		debugger_tab.exit_world()
		return true
	elif message == Msg.ENTITY_ADDED:
		# data: [Entity, NodePath]
		debugger_tab.entity_added(data[0], data[1])
		return true
	elif message == Msg.ENTITY_REMOVED:
		# data: [Entity, NodePath]
		debugger_tab.entity_removed(data[0], data[1])
		return true
	elif message == Msg.ENTITY_DISABLED:
		# data: [Entity, NodePath]
		debugger_tab.entity_disabled(data[0], data[1])
		return true
	elif message == Msg.ENTITY_ENABLED:
		# data: [Entity, NodePath]
		debugger_tab.entity_enabled(data[0], data[1])
		return true
	elif message == Msg.SYSTEM_ADDED:
		# data: [System, group, process_empty, active, paused, NodePath]
		debugger_tab.system_added(data[0], data[1], data[2], data[3], data[4], data[5])
		return true
	elif message == Msg.SYSTEM_REMOVED:
		# data: [System, NodePath]
		debugger_tab.system_removed(data[0], data[1])
		return true
	elif message == Msg.ENTITY_COMPONENT_ADDED:
		# data: [ent.get_instance_id(), comp.get_instance_id(), ClassUtils.get_type_name(comp), comp.serialize()]
		debugger_tab.entity_component_added(data[0], data[1], data[2], data[3])
		return true
	elif message == Msg.ENTITY_COMPONENT_REMOVED:
		# data: [Entity, Variant]
		debugger_tab.entity_component_removed(data[0], data[1])
		return true
	elif message == Msg.ENTITY_RELATIONSHIP_ADDED:
		# data: [Entity, Relationship]
		debugger_tab.entity_relationship_added(data[0], data[1])
		return true
	elif message == Msg.ENTITY_RELATIONSHIP_REMOVED:
		# data: [Entity, Relationship]
		debugger_tab.entity_relationship_removed(data[0], data[1])
		return true
	elif message == Msg.COMPONENT_PROPERTY_CHANGED:
		# data: [Entity, Component, property_name, old_value, new_value]
		debugger_tab.entity_component_property_changed(data[0], data[1], data[2], data[3], data[4])
		return true
	return false


func _setup_session(session_id):
	# Add a new tab in the debugger session UI containing a label.
	debugger_tab.name = "GECS"  # Will be used as the tab title.
	session = get_session(session_id)
	# Listens to the session started and stopped signals.
	session.started.connect(
		func():
			print("GECS Debug Session started")
			debugger_tab.active = true
	)
	session.stopped.connect(
		func():
			print("GECS Debug Session stopped")
			debugger_tab.active = false
	)
	session.add_session_tab(debugger_tab)

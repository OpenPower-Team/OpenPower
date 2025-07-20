@tool
class_name SaveData
extends Resource

## Versioned save data resource for storing game state
@export var version := 1.0
@export var data := {} # Dictionary of {node_path: {property: value}}

## Creates a new save data instance with current version
static func create() -> SaveData:
	var save := SaveData.new()
	save.version = 1.0
	save.data = {}
	return save

## Checks if the save data version is compatible
func is_version_compatible() -> bool:
	return version >= 1.0 and version < 2.0 # Version 1.x is compatible
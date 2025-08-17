class_name C_CountryData
extends Component

## The unique identifier for the country (e.g., "USA", "GER").
@export var id: String = ""
## Path to the country's flag texture.
@export var flag_path: String = ""
## A flag to identify the player's country.
@export var is_player: bool = false
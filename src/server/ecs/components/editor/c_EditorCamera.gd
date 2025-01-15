class_name CEditorCamera
extends Component

@export var zoom: float = 1.0
@export var min_zoom: float = 0.1
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.1
@export var is_dragging: bool = false
@export var drag_start: Vector2 = Vector2.ZERO
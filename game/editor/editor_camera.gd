# REFACTOR: Added static typing and exported variables for tunability.
extends Camera2D

@export var zoom_speed: float = 0.05
@export var min_zoom: float = 0.1
@export var max_zoom: float = 5.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
		# Use inverse transform to correctly pan with camera rotation/scale
		position -= event.relative * (1.0 / zoom.x)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			_zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			_zoom_out()

func _zoom_in() -> void:
	var new_zoom: Vector2 = zoom * (1.0 + zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _zoom_out() -> void:
	var new_zoom: Vector2 = zoom * (1.0 - zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
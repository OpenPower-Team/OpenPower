extends Node3D

@export var rotate_speed: float = 10
var last_mouse_pos: Vector2
var rotating: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and rotating:
		var mouse_pos = event.position
		var delta = mouse_pos - last_mouse_pos

		# Rotate around the Y-axis (horizontal rotation)
		rotate_y(deg_to_rad(-delta.x * rotate_speed))

		# Rotate around the X-axis (vertical rotation) with limits
		var new_rotation_x = rotation_degrees.x - delta.y * rotate_speed
		new_rotation_x = clamp(new_rotation_x, -90, 90)  # Limit the x rotation to -90 to 90 degrees
		rotation_degrees.x = new_rotation_x

		last_mouse_pos = mouse_pos

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				rotating = true
				last_mouse_pos = event.position
			else:
				rotating = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE)

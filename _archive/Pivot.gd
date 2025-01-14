extends Node3D

@export var rotate_speed : float = 0.1
@export var zoom_speed : float = 1
var last_mouse_pos : Vector2
var rotating : bool = false
@export var min_zoom_distance : float = 1.0
@export var max_zoom_distance : float = 50.0
@export var initial_zoom : float = 0.0

func _ready():
	if Input:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	position = Vector3(0, 0, -initial_zoom)  # Set initial position along the Z-axis
	rotation = $Camera3D.rotation if $Camera3D else Vector3.ZERO
	print("Camera control script initialized")
	print("Initial position: ", position)
	print("Initial rotation: ", rotation)

func _input(event):
	if event is InputEventMouseMotion and rotating:
		if last_mouse_pos:
			var delta = event.position - last_mouse_pos
			rotate_y(deg_to_rad(-delta.x * rotate_speed))
			rotate_x(deg_to_rad(-delta.y * rotate_speed))
		last_mouse_pos = event.position
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			rotating = event.pressed
			if rotating:
				last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if Input:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var zoom_direction = -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1
			var zoom_amount = zoom_direction * zoom_speed
			var forward_vector = transform.basis.x.normalized() if transform.basis.x else Vector3.FORWARD
			var new_position = position + forward_vector * zoom_amount
			var distance_to_pivot = new_position.length()
			print("Current position: ", position)
			print("Forward vector: ", forward_vector)
			print("Zoom amount: ", zoom_amount)
			print("New position: ", new_position)
			print("Distance to pivot: ", distance_to_pivot)
			if distance_to_pivot >= min_zoom_distance and distance_to_pivot <= max_zoom_distance:
				position = new_position
				print("Position updated to: ", position)
			else:
				print("Zoom constrained by min/max limits")

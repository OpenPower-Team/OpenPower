extends Camera2D

func zoom_in():
	var current_zoom = self.zoom
	if get_node("../CanvasLayer/Panel_validation").visible == false:
		self.set_zoom(current_zoom * 1.05)
	
func zoom_out():
	var current_zoom = self.zoom
	if get_node("../CanvasLayer/Panel_validation").visible == false:
		self.set_zoom(current_zoom * 0.95)
	
#Drag around camera
func move_offset(event):
	var rel_x = event.relative.x
	var rel_y = event.relative.y
	var cam_pos = self.get_offset()
	var current_zoom = self.zoom
	
	cam_pos.x -= rel_x / current_zoom.x
	cam_pos.y -= rel_y / current_zoom.y
	self.set_offset(cam_pos)

func _unhandled_input(event):
	if event is InputEventMouseMotion and event.button_mask > 0:
		self.move_offset(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		self.zoom_in()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		self.zoom_out()

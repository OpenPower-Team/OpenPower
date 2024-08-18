extends Label

func _process(delta):
	var fps = Engine.get_frames_per_second()
	var memory = OS.get_static_memory_usage() / 1024 / 1024  # Convert to MB
	
	text = "FPS: %d\nRAM: %.2f MB" % [fps, memory]

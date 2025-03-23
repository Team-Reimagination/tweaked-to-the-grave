extends Node2D

@onready var cam = $Camera
var canInput = true;

func _process(_delta: float) -> void:
	if canInput:
		cam.offset.x = lerp(cam.offset.x, clampf(get_global_mouse_position().x - 640.0, -640.0, 640.0) / 50, 0.3)
		cam.offset.y = lerp(cam.offset.y, clampf(get_global_mouse_position().y - 480.0, -480.0, 480.0) / 50, 0.3)
	else:
		cam.offset.x = lerp(cam.offset.x, clampf(0, -640.0, 640.0) / 50, 0.3)
		cam.offset.y = lerp(cam.offset.y, clampf(0, -480.0, 480.0) / 50, 0.3)

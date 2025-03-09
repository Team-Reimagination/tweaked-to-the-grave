extends Node3D

@onready var player = $Objects/Ship;
@onready var camera = $Camera;

static var rotateBound = 10;
static var maxBoundMod = 10;
static var vertOffset = rotateBound;

func _process(_delta: float) -> void:
	vertOffset = (rotateBound - 8.5) if player.position.y < 0 else (rotateBound + 5.0)
	
	camera.h_offset = 0.0
	camera.v_offset = 0.0
	camera.rotation.y = 0.0
	camera.rotation.x = 0.0
	
	if (abs(player.position.x) >= rotateBound):
		camera.h_offset = clampf(((rotateBound + player.position.x) if player.position.x < 0.0 else (player.position.x - rotateBound)) * 1.2, -maxBoundMod, maxBoundMod)
		camera.rotation.y = camera.h_offset / 80
	
	if (abs(player.position.y) >= vertOffset):
		camera.v_offset = clampf(((vertOffset + player.position.y) if player.position.y < 0.0 else (player.position.y - vertOffset)) * 1.2, -maxBoundMod, maxBoundMod)
		camera.rotation.x = camera.v_offset / -80

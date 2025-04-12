extends Node3D

@export var type = 'player_bullet';
@onready var scene = self.get_parent().get_parent();

func _ready() -> void:
	self.position = get_meta("spawnPosition")
	rotation_degrees.x = -90
	scale = Vector3(0.8,0.8,0.8)
	
func _process(delta: float) -> void:
	position.z -= 500 * delta #movement propossitions

	if position.z < -500: #kill if too far away
		queue_free()

func killYourself():
	queue_free()

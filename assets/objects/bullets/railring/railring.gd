extends Node3D

@onready var scene = self.get_parent().get_parent();

func _ready() -> void:
	self.position = get_meta("spawnPosition")
	rotation_degrees.x = -90
	scale = Vector3(0.8,0.8,0.8)
	
func _process(delta: float) -> void:
	position.z -= 500 * delta
	scene.entityProcess(self)

	if position.z < -500:
		queue_free()

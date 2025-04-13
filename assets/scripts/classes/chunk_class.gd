class_name TTTG_Chunk
extends Node3D

@onready var scene = get_parent().get_parent()

@onready var startPos = $StartPos
@onready var endPos = $EndPos

func _ready() -> void:
	position.y = scene.levelDefs.floor.y

func _process(delta: float) -> void:
	position.z += scene.scrollSpeed * delta * scene.scrollModFLOOR[1] * (scene.btmF.scale.z*2.0)
	
	if get_child_count() <= 2:
		self.queue_free()

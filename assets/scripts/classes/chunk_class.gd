class_name TTTG_Chunk
extends Node3D

@export var nextChunk : TTTG_Chunk
@export var isSubChunk : bool
@export var chanceWeight: float = 1.0

@onready var scene = get_parent().get_parent()

@onready var startPos = $StartPos
@onready var endPos = $EndPos

func _process(delta: float) -> void:
	position.z += scene.scrollSpeed * delta * scene.scrollModFLOOR[1] * (scene.btmF.scale.z*2.0)
	
	if get_child_count() <= 2:
		self.queue_free()

func passReady():
	for a in self.get_children():
		if a is not Marker3D: a.isReady = true

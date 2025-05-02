class_name TTTG_Chunk
extends Node3D

@export var nextChunk : TTTG_Chunk
@export var isSubChunk : bool
@export var chanceWeight: float = 1.0

var doMove = false

@onready var scene = get_parent().get_parent()

@onready var startPos = $StartPos
@onready var endPos = $EndPos

func _process(delta: float) -> void:
	if doMove: position.z += PlayGlobals.moveSpeed(delta, scene);
	
	if get_child_count() <= 2:
		self.queue_free()

func passReady():
	for a in self.get_children():
		if a is not Marker3D:
			a.isReady = true

func victory_screech():
	for a in self.get_children():
		if a is not Marker3D and a.isGameplayObject:
			a.visible = false
			a.queue_free()

class_name TTTG_Chunk
extends Node3D

@export var chanceWeight: float = 1.0
@export var cloneCount : int = 3

var doMove = false

@onready var scene = get_parent().get_parent()

@onready var startPos = $StartPos
@onready var endPos = $EndPos

func _ready() -> void:
	passNotReady()

func _process(delta: float) -> void:
	if doMove: position.z += PlayGlobals.moveSpeed(delta, scene);

func reset(isRecursive = false):
	passNotReady()
	for a in self.get_children():
		if a is not Marker3D:
			a.reset()

func passNotReady():
	doMove = false
	for a in self.get_children():
		if a is not Marker3D:
			a.disabled = true

func passReady():
	doMove = true
	for a in self.get_children():
		if a is not Marker3D:
			a.disabled = false

func victory_screech():
	for a in self.get_children():
		if a is not Marker3D and a.isGameplayObject:
			a.visible = false
			a.queue_free()

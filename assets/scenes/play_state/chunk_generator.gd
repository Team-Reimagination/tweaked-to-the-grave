extends Node3D

@onready var scene = get_parent()

var bgChunks = []
var bgChunkNode;

var curBGChunk
var prevBGChunk

func prepareChunks() -> void:
	bgChunkNode = load("res://assets/data/chunks/SHR_Background.tscn").instantiate()
	bgChunks = bgChunkNode.get_child(2).get_children()
	
	for a in bgChunks:
		a.owner = null
		a.get_parent().remove_child(a)
	
func makeBGChunk():
	var newChunk = bgChunks.pick_random()
	
	scene.spawnOBJ(newChunk)

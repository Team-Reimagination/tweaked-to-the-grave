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
	var newChunk = bgChunks.pick_random().duplicate()
	var ogPos = Vector2(0.0,0.0);
	
	scene.spawnOBJ(newChunk)
	
	if curBGChunk == null:
		curBGChunk = newChunk
	else:
		prevBGChunk = curBGChunk
		curBGChunk = newChunk
		ogPos = Vector2(prevBGChunk.endPos.global_position.x, prevBGChunk.endPos.global_position.z)
		
	newChunk.position.x = 0.0 + (0.0 - newChunk.startPos.global_position.x)
	newChunk.position.y = scene.levelDefs.floor.y
	newChunk.position.z = ogPos.y + (ogPos.y - newChunk.startPos.global_position.z)

func _process(_delta: float) -> void:
	if curBGChunk != null:
		if curBGChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end - 100: makeBGChunk()

extends Node3D

@onready var scene = get_parent()

var bgChunks = []
var bgChunkNode;

var predictedBGChunk
var curBGChunk
var prevBGChunk

func prepareChunks() -> void:
	bgChunkNode = load("res://assets/data/chunks/"+PlayGlobals.levelID+"/background.tscn").instantiate()
	bgChunks = bgChunkNode.get_children()
	
	for a in bgChunks:
		a.owner = null
		a.get_parent().remove_child(a)
		
	bgChunks = bgChunks.filter(func(x): return !x.isSubChunk)
	
func makeBGChunk():
	var chunker = bgChunks.pick_random() if predictedBGChunk == null else predictedBGChunk
	var newChunk = chunker.duplicate()
	var ogPos = 0.0;
	
	scene.spawnOBJ(newChunk)
	
	if curBGChunk == null:
		curBGChunk = newChunk
	else:
		ogPos = curBGChunk.endPos.global_position.z
		prevBGChunk = curBGChunk
		curBGChunk = newChunk
		
	newChunk.position.x = 0.0 + (0.0 - newChunk.startPos.global_position.x)
	newChunk.position.y = scene.levelDefs.floor.y
	newChunk.position.z = ogPos
	
	newChunk.passReady()
	newChunk.visible = true
	
	if newChunk.nextChunk != null: predictedBGChunk = newChunk.nextChunk
	else: predictedBGChunk = null
	
	if newChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()

func _process(_delta: float) -> void:
	if curBGChunk != null:
		if curBGChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()

extends Node3D

@onready var scene = get_parent()

var bgChunks = []
var bgChunkWeights = []
var bgChunkNode;
var predictedBGChunk
var curBGChunk
var prevBGChunk

var lvChunks = []
var lvChunkWeights = []
var lvChunkNode;
var predictedLVChunk
var curLVChunk
var prevLVChunk

var rng = RandomNumberGenerator.new()

func prepareChunks() -> void:
	#BACKGROUND
	bgChunkNode = load("res://assets/data/chunks/"+PlayGlobals.levelID+"/background.tscn").instantiate()
	bgChunks = bgChunkNode.get_children()
	
	for a in bgChunks:
		a.owner = null
		a.get_parent().remove_child(a)
		
	bgChunks = bgChunks.filter(func(x): return !x.isSubChunk)
	for a in bgChunks:
		bgChunkWeights.append(a.chanceWeight)
	
	#LEVEL
	lvChunkNode = load("res://assets/data/chunks/"+PlayGlobals.levelID+"/level.tscn").instantiate()
	lvChunks = lvChunkNode.get_children()
	
	for a in lvChunks:
		a.owner = null
		a.get_parent().remove_child(a)
		
	lvChunks = lvChunks.filter(func(x): return !x.isSubChunk)
	for a in lvChunks:
		lvChunkWeights.append(a.chanceWeight)
		
func makeBGChunk():
	var chunker = bgChunks[rng.rand_weighted(bgChunkWeights)] if predictedBGChunk == null else predictedBGChunk
	var newChunk = chunker.duplicate()
	var ogPos = 0.0;
	
	for a in newChunk.get_children(true):
		a = a.duplicate()
	
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
	
	newChunk.doMove = true
	
	if newChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()

func makeLVChunk():
	var chunker2 = lvChunks[rng.rand_weighted(lvChunkWeights)] if predictedLVChunk == null else predictedLVChunk
	var newChunk2 = chunker2.duplicate()
	var ogPos2 = -scene.levelDefs.fog.distance.end;
	
	scene.spawnOBJ(newChunk2)
	
	for a in newChunk2.get_children(true):
		a = a.duplicate()
	
	if curLVChunk == null:
		curLVChunk = newChunk2
	else:
		ogPos2 = curLVChunk.endPos.global_position.z
		prevLVChunk = curLVChunk
		curLVChunk = newChunk2
		
	newChunk2.position.x = 0.0 + (0.0 - newChunk2.startPos.global_position.x)
	newChunk2.position.y = scene.levelDefs.floor.y
	newChunk2.position.z = ogPos2
	
	newChunk2.passReady()
	newChunk2.visible = true
	
	newChunk2.doMove = scene.callForMovement
	
	if newChunk2.nextChunk != null: predictedLVChunk = newChunk2.nextChunk
	else: predictedLVChunk = null
	
	if newChunk2.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*1.5: makeLVChunk()

func _process(_delta: float) -> void:
	if curBGChunk != null:
		if curBGChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()
		
	if curLVChunk != null and !scene.hasBitchWon:
		if curLVChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*1.5: makeLVChunk()

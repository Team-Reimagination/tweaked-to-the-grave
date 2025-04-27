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

func makeLVChunk():
	var chunker = lvChunks[rng.rand_weighted(lvChunkWeights)] if predictedLVChunk == null else predictedLVChunk
	var newChunk = chunker.duplicate()
	var ogPos = -scene.levelDefs.fog.distance.end;
	
	scene.spawnOBJ(newChunk)
	
	if curLVChunk == null:
		curLVChunk = newChunk
	else:
		ogPos = curLVChunk.endPos.global_position.z
		prevLVChunk = curLVChunk
		curLVChunk = newChunk
		
	newChunk.position.x = 0.0 + (0.0 - newChunk.startPos.global_position.x)
	newChunk.position.y = scene.levelDefs.floor.y
	newChunk.position.z = ogPos
	
	newChunk.passReady()
	newChunk.visible = true
	
	if newChunk.nextChunk != null: predictedLVChunk = newChunk.nextChunk
	else: predictedLVChunk = null
	
	if newChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()

func _process(_delta: float) -> void:
	if curBGChunk != null:
		if curBGChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()
		
	if curLVChunk != null and !scene.hasBitchWon:
		if curLVChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeLVChunk()

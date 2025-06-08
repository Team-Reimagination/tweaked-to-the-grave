extends Node3D

@onready var scene = get_parent()

var bgChunks = []
var bgChunkWeights = []
var usedChunks = []

var bgChunkNode;

var curBGChunk
var prevBGChunk

var lvChunks = []
var lvChunkWeights = []
var lvUsedChunks = []

var lvChunkNode;

var curLVChunk
var prevLVChunk

var rng = RandomNumberGenerator.new()

func prepareChunks() -> void:
	#BACKGROUND
	bgChunkNode = load("res://assets/data/chunks/"+PlayGlobals.levelID+"/background.tscn")
	if not bgChunkNode:
		return
	
	bgChunkNode = bgChunkNode.instantiate()
	
	for chunk in bgChunkNode.get_children():
		for count in range(chunk.cloneCount):
			var chu = chunk.duplicate()
			chu.visible = true
			
			for a in chu.get_children(true):
				a = a.duplicate()
		
			scene.spawnOBJ(chu)
			
			bgChunks.append(chu)
			bgChunkWeights.append(chu.chanceWeight)
			
			chu.global_position.z = -(2 << 11)
	
	#LEVEL
	lvChunkNode = load("res://assets/data/chunks/"+PlayGlobals.levelID+"/level.tscn")
	if not lvChunkNode:
		return
	
	lvChunkNode = lvChunkNode.instantiate()
	
	for chunk in lvChunkNode.get_children():
		for count in range(chunk.cloneCount):
			var chu = chunk.duplicate()
			chu.visible = true
			
			for a in chu.get_children(true):
				a = a.duplicate()
		
			scene.spawnOBJ(chu)
			
			lvChunks.append(chu)
			lvChunkWeights.append(chu.chanceWeight)
			
			chu.global_position.z = -(2 << 11)
		
func makeBGChunk():
	if bgChunks.size() == 0: return;
	var newChunk = bgChunks[rng.rand_weighted(bgChunkWeights)]
	
	var ogPos = 0.0;
	
	if curBGChunk == null:
		curBGChunk = newChunk
	else:
		ogPos = curBGChunk.endPos.global_position.z
		prevBGChunk = curBGChunk
		curBGChunk = newChunk
		
	newChunk.global_position.x = 0.0 + (0.0 - newChunk.startPos.global_position.x)
	newChunk.global_position.y = scene.levelDefs.floor.y
	newChunk.global_position.z = ogPos
	
	newChunk.passReady()
	
	usedChunks.push_back(newChunk)
	var indexy = bgChunks.find(newChunk)
	bgChunks.remove_at(indexy)
	bgChunkWeights.remove_at(indexy)
	
	if newChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()

func makeLVChunk():
	if lvChunks.size() == 0: return;
	var newChunk = lvChunks[rng.rand_weighted(lvChunkWeights)]
	
	var ogPos = -scene.levelDefs.fog.distance.end;
	
	if curLVChunk == null:
		curLVChunk = newChunk
	else:
		ogPos = curLVChunk.endPos.global_position.z - (scene.levelDefs.chunkSpace if (scene.levelDefs.has("chunkSpace")) else 0.0)
		prevLVChunk = curLVChunk
		curLVChunk = newChunk
	
	newChunk.global_position.x = 0.0 + (0.0 - newChunk.startPos.global_position.x)
	newChunk.global_position.y = scene.levelDefs.floor.y
	newChunk.global_position.z = ogPos
	
	newChunk.passReady()
	
	lvUsedChunks.push_back(newChunk)
	var indexy = lvChunks.find(newChunk)
	lvChunks.remove_at(indexy)
	lvChunkWeights.remove_at(indexy)
	
	if newChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*1.5: makeLVChunk()

func _process(_delta: float) -> void:
	if curBGChunk != null:
		if curBGChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*2: makeBGChunk()
	
		if usedChunks.size() != 0:
			if usedChunks[0].endPos.global_position.z > 100:
				usedChunks[0].reset()
				usedChunks[0].global_position.z = -(2 << 11)
				
				bgChunks.push_back(usedChunks[0])
				bgChunkWeights.push_back(usedChunks[0].chanceWeight)
				usedChunks.erase(usedChunks[0])
	
	if curLVChunk != null and !scene.hasBitchWon:
		if curLVChunk.startPos.global_position.z >= -scene.levelDefs.fog.distance.end*1.5: makeLVChunk()
		
		if lvUsedChunks.size() != 0:
			if lvUsedChunks[0].endPos.global_position.z > 100:
				lvUsedChunks[0].reset()
				lvUsedChunks[0].global_position.z = -(2 << 11)
				
				lvChunks.push_back(lvUsedChunks[0])
				lvChunkWeights.push_back(lvUsedChunks[0].chanceWeight)
				lvUsedChunks.erase(lvUsedChunks[0])

extends Node

var transState = preload("res://assets/scenes/[SUB-SCENES]/transition/transition.tscn")
var loading = preload("res://assets/scenes/loading/loading.tscn")
var ass = null;

var doTransOut = true
var doTransIn = true
var doUnpause = false

var tIN = null

var parentToChange;
var intendedScene;

#i think this is alright

func switchScenes(parent, intendedState = "reset", doOut = true, doIn = true, doUn = false):
	doTransOut = doOut
	doTransIn = doIn
	doUnpause = doUn
	
	if tIN == true: tIN = null
	if tIN == false: tIN = true
	if tIN == null: tIN = false
	
	if not tIN:
		parentToChange = parent
		intendedScene = intendedState
	
	if (tIN and not doTransIn) or (not tIN and not doTransOut):
		changeClothes()
	else:
		if not (tIN == true and intendedScene == "reset"):
			ass = transState.instantiate()
			parent.add_sibling(ass)
			ass.process_mode = Node.PROCESS_MODE_ALWAYS
			
		if not ass == null: ass.mytransrights()

func changeClothes():
	if not tIN:
		PlayGlobals.removeAllSubstates()
		
		if doUnpause: parentToChange.get_tree().paused = false
		Subtitles.clearSubtitles()
		Subtitles.setPlacementY()
		
		if intendedScene == "reset":
			parentToChange.get_tree().reload_current_scene()
			TransFuncs.switchScenes(parentToChange)
		else:
			parentToChange.get_tree().change_scene_to_packed(loading)
			if ass: ass.queue_free()
	else:
		ass.queue_free()
		ass = null

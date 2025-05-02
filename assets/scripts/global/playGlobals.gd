extends Node

var levelID = "SHR"
var levelDefs;
var cutsceneID = 'test'

#DIFFICULTY STUFF
var difficulty = 2
var areWeFNFFreeDownload = false

var diffMod = {
	0: [0.3, true, true, [10,3], 0.5, 10, 1.5, true],
	1: [0.6, true, false, [5,3], 0.75, 10, 1.25, true],
	2: [1.0, true, false, [3,3], 1, 10, 1, true],
	3: [2.0, false, false, [1,3], 1, 5, 0.5, true],
	4: [4.0, false, false, [1,1], 1, 1, 0.0, false]
}

var bulletPower = 1
var canBarrelRoll = true
var canBarrelShoot = true
var lifeCount = [3,3]
var bulletCooldown = 1
var maxLiraLevel = 10
var LiraGainSpeed = 1
var doColelctibles = true

var ownedLira = 0;
var ownedLiraProgress = 0;
var liraLevel = 1;

func prepareGame():
	var diffy = diffMod[difficulty]
	print(diffy)
	
	if areWeFNFFreeDownload:
		setDefaults(diffy)
	else:
		if !SaveSystem.saveData.difficulties.has(str(difficulty)): 
			SaveSystem.curDifficultySave = SaveSystem.difficultySave.duplicate(true)
			setDefaults(diffy)
			
			levelID = "SHR"
			
			SaveSystem.curDifficultySave.lives = lifeCount[0]
			SaveSystem.curDifficultySave.health = lifeCount[1]
			SaveSystem.curDifficultySave.lira = ownedLira
			SaveSystem.curDifficultySave.lirsProgress = ownedLiraProgress
			SaveSystem.curDifficultySave.level = liraLevel
			SaveSystem.curDifficultySave.levelInitials = levelID
			
			SaveSystem.saveGame()
		else:
			SaveSystem.curDifficultySave = SaveSystem.saveData.difficulties[str(difficulty)].duplicate(true)
			setDefaults(diffy)
			
			print("FREE PLAY ", difficulty, "\n", SaveSystem.curDifficultySave)
			
			lifeCount = [SaveSystem.curDifficultySave.lives,SaveSystem.curDifficultySave.health]
			ownedLira = SaveSystem.curDifficultySave.lira
			ownedLiraProgress = SaveSystem.curDifficultySave.lirsProgress
			liraLevel = SaveSystem.curDifficultySave.level
			levelID = SaveSystem.curDifficultySave.levelInitials

func setDefaults(diffy):
	bulletPower = diffy[0]
	canBarrelRoll = diffy[1]
	canBarrelShoot = diffy[2]
	lifeCount = diffy[3]
	bulletCooldown = diffy[4]
	maxLiraLevel = diffy[5]
	LiraGainSpeed = diffy[6]
	doColelctibles = diffy[7]
	
	ownedLira = 0
	ownedLiraProgress = 0
	liraLevel = 1

#SUBSTATE SHIT
var substates = []
func addSubstate(parent, child):
	parent.add_sibling(child)
	child.set_meta("parent", parent);
	substates.push_back(child)
	
func subCallings(node, functionate):
	var parent = node.get_meta("parent", null)
	if parent != null and parent.has_method(functionate): parent.call(functionate)
	
func removeSubstate(sub):
	var ind = substates.find(sub)
	if ind != -1:
		substates[ind].queue_free()
		substates.remove_at(ind)
		
func removeAllSubstates():
	for a in substates:
		a.queue_free()
	substates = []

func getDistance(isBackgroundObject):
	return (levelDefs.fog.distance.end * 2) if !isBackgroundObject else (levelDefs.boss.distance - 50)

func youarenolongermyfriendsoundnowgoaway(doMusicToo = true):
	get_parent().get_tree().call_group('Sound', 'stop')
	if doMusicToo: get_parent().get_tree().call_group('Music', 'stop')

func get_tscn_resources_in_directory(path: String) -> Array[String]:
	var tscn_files: Array[String] = []
	var files := DirAccess.get_files_at(path)
	
	for file in files:
		if file.ends_with(".tscn"):
			tscn_files.append(path.path_join(file))
	
	return tscn_files

func getCutsceneDestination():
	if cutsceneID == 'beginning': return "res://assets/scenes/play_state/play_state.tscn"
	elif cutsceneID == 'end': return "res://assets/scenes/main_menu/main_menu.tscn"
	elif cutsceneID == 'test': return "res://assets/scenes/play_state/play_state.tscn"
	else: return "res://assets/scenes/main_menu/main_menu.tscn"

func getEaseType(Twease):
	if Twease == 'inout': return Tween.EASE_IN_OUT
	elif Twease == 'in': return Tween.EASE_IN
	elif Twease == 'outin': return Tween.EASE_OUT_IN
	else: return Tween.EASE_OUT

func getTransType(twans):
	if twans == 'back': return Tween.TRANS_BACK
	elif twans == 'bounce': return Tween.TRANS_BOUNCE
	elif twans == 'circ': return Tween.TRANS_CIRC
	elif twans == 'cubic': return Tween.TRANS_CUBIC
	elif twans == 'elastic': return Tween.TRANS_ELASTIC
	elif twans == 'expo': return Tween.TRANS_EXPO
	elif twans == 'quad': return Tween.TRANS_QUAD
	elif twans == 'quart': return Tween.TRANS_QUART
	elif twans == 'quint': return Tween.TRANS_QUINT
	elif twans == 'sine': return Tween.TRANS_SINE
	elif twans == 'spring': return Tween.TRANS_SPRING
	else: return Tween.TRANS_LINEAR

func moveSpeed(delta, scene):
	return scene.scrollSpeed * delta * scene.scrollModFLOOR[1] * (scene.btmF.scale.z*2.0)

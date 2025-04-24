extends Node

var optionsData = {
	"video_resolution" = Vector2(1280, 960), ##PC ONLY
	"video_fullscreen" = false, ##PC ONLY
	"video_passion" = false,
	
	"volume_master" = 1.0,
	"volume_music" = 1.0,
	"volume_sfx" = 1.0,
	"volume_ambience" = 1.0,
	
	"gameplay_autofire" = false
}

var achievementData = {
	"_data": {
		
	}
}

var saveData = {
	"unlocked": [],
	"firstTime": [],
	"difficulties": {
		
	}
}

var curDifficultySave = {
	
}
var difficultySave = {
	"levelInitials" = 'SHR',
	"levelName" = 'The Saharaland',
	"lives" = 3,
	"health" = 3,
	"lira" = 0,
	"lirsProgress" = 0,
	"level" = 1
}

var cloudSave;

func saveSave() -> void:
	var saveDefine = {
		"options": optionsData,
		"save": saveData,
		"achievements": achievementData 
	}

	await NG.cloudsave_set_data(1, var_to_str(saveDefine))

func hasNotUnlockedLevel(levID): return saveData.unlocked.find(levID) == -1

func unlockLevelForFree(levID) :
	if hasNotUnlockedLevel(levID):
		saveData.unlocked.append(levID)
		saveSave()
		
func hasNotFirstTImeLevel(levID): return saveData.firstTime.find(levID) == -1

func firstTimeLevelForMe(levID) :
	if hasNotFirstTImeLevel(levID):
		saveData.firstTime.append(levID)
		saveSave()

func saveGame():
	saveData.difficulties[str(PlayGlobals.difficulty)] = curDifficultySave.duplicate(true)
	saveSave()

func eraseDifficultySave(diff = null):
	if diff == null: diff = PlayGlobals.difficulty
	
	saveData.difficulties.erase(str(diff))
	saveSave()
	
func loadSave():
	var data = str_to_var(cloudSave);
	
	saveData = data.save
	optionsData = data.options
	achievementData = data.achievements

func eraseCurrentGameplaySave(curDiff = null):
	curDifficultySave = {}
	if curDiff != null: eraseDifficultySave(curDiff)

func applyImmediateSettings() -> void:
	for a in optionsData.keys():
		applySetting(a, optionsData[a])

func applySetting(type, valuemysanityplease): #this shit has no switch cases :sob:
	if type == 'video_resolution':
		if not OS.has_feature("web"): DisplayServer.window_set_size(valuemysanityplease)
	elif type == 'video_fullscreen':
		if not OS.has_feature("web"): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if valuemysanityplease else DisplayServer.WINDOW_MODE_WINDOWED)
	elif type == 'video_passion':
		Passion.visibility(valuemysanityplease)
	
	elif type == 'volume_master':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(valuemysanityplease))
	elif type == 'volume_music':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(valuemysanityplease))
	elif type == 'volume_sfx':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(valuemysanityplease))
	elif type == 'volume_ambience':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), linear_to_db(valuemysanityplease))

func _ready() -> void:
	cloudSave = await NG.cloudsave_get_data(1)
	
	if len(cloudSave) < 1:
	#if true: #DEV THINGY
		saveSave()
	else:
		loadSave()
		
	applyImmediateSettings()

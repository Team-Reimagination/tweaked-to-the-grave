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
	"difficulties": {
		
	}
}

var curDifficultySave = {
	
}
var difficultySave = {
	"levelInitials" = 'SHR',
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

func saveGame():
	saveData.difficulties[PlayGlobals.difficulty] = curDifficultySave
	saveSave()

func eraseDifficultySave(diff):
	saveData.difficulties.erase(diff)
	saveSave()
	
func loadSave():
	var data = str_to_var(cloudSave);
	
	saveData = data.save
	optionsData = data.options
	achievementData = data.achievements

func eraseCurrentGameplaySave(curDiff = null):
	curDifficultySave = {}
	if curDiff: eraseDifficultySave(curDiff)
	

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

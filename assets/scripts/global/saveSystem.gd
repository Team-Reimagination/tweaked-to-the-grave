extends Node

var optionsData = {} ## will be automatically filled with values on loading save
var _defaultOptionsData = { ## enter the options you want to add
	"video_windowsize" = 0, ##PC ONLY
	"video_windowmode" = 0, ##PC ONLY
	"video_resolution" = 1.0, ##PC ONLY
	"video_passion" = false,
	"video_reducedmotions" = false,
	
	"audio_master" = 1.0,
	"audio_music" = 1.0,
	"audio_sfx" = 1.0,
	"audio_ambience" = 1.0,
	"audio_voicelines" = 1.0,
	"audio_subtitles" = 0,
	
	"gameplay_autofire" = false,
	"gameplay_warningalarm" = true,
	"gameplay_lirabonus" = true
}

var possibleResolutions = [ ## every popular 4:3 game resolutions in increasing order
	Vector2(160, 120),
	Vector2(320, 240),
	Vector2(640, 480),
	Vector2(800, 600),
	Vector2(1024, 768),
	Vector2(1152, 864),
	Vector2(1280, 960),
	Vector2(2048, 1536),
	Vector2(3200, 2400),
	Vector2(4096, 3072),
	Vector2(6400, 4800)
]
# people might be confused by this so i'm gonna document this here
	# name is self explanatory
	# type defines the type of value it saves
	# type: 0 is float (slider); type: 1 is bool (checkbox); type: 2 is array (selector)
	# pc is for pc exclusivity (lowk we need to change it to an array to contain supported platforms)
	# other vars just take a look at the other defines
var optionDefines = { 
	"video_windowsize": {
		"name": "Resolution",
		"type": 2,
		"pc": true,
		"options": ["160x120",
					"320x240",
					"640x480",
					"800x600",
					"1024x768",
					"1152x864",
					"1280x960",
					"2048x1536",
					"3200x2400",
					"4096x3072",
					"6400x4800"]
	},
	"video_windowmode": {
		"name": "Fullscreen",
		"type": 2,
		"pc": true,
		"options": ["Windowed",
					"Borderless",
					"Fullscreen"]
	},
	"video_resolution": {
		"name": "3D Resolution Scale",
		"type": 0,
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"label": 'float'
	},
	"video_passion": {
		"name": "Passion Effects",
		"type": 1
	},
	"video_reducedmotions": {
		"name": "Reduced Motions",
		"type": 1
	},
	"audio_master": {
		"name": "Master Volume",
		"type": 0,
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"label": 'percent'
	},
	"audio_ambience": {
		"name": "Ambience Volume",
		"type": 0,
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"label": 'percent'
	},
	"audio_music": {
		"name": "Music Volume",
		"type": 0,
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"label": 'percent'
	},
	"audio_sfx": {
		"name": "SFX Volume",
		"type": 0,
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"label": 'percent'
	},
	"audio_voicelines": {
		"name": "Voiceline Volume",
		"type": 0,
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"label": 'percent'
	},
	"audio_subtitles": {
		"name": "Subtitles",
		"type": 2,
		"options": ["Off", "Voicelines", "SFX", "All"]
	},
	"gameplay_autofire": {
		"name": "Auto-Fire",
		"type": 1
	},
	"gameplay_warningalarm": {
		"name": "Low Health Warning",
		"type": 1
	},
	"gameplay_lirabonus": {
		"name": "Lira Bonus Prompt",
		"type": 1
	}
}

var achievementData = {}
var _defaultAchievementData = {
	"vars": {
		
	},
	"gotten": []
}
var saveData ={}
var _defaultSaveData = {
	"unlocked": [],
	"firstTime": [],
	"cutscenes": [],
	"highscores": {
		
	},
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
	
func nukeSave() -> void: ## this can also serve as setting default vars
	optionsData = {}
	achievementData = {}
	saveData = {}
	
	setOptionDefaults(false)
	setAchievementDefaults(false)
	setSaveDefaults(false)
		
	saveSave()
	applyImmediateSettings()

func setOptionDefaults(checkExistence) :
	for i in _defaultOptionsData.keys():
		if (checkExistence and not optionsData.has(i)) or !checkExistence: 
			if i == "video_windowsize":
				var minimumRes = DisplayServer.get_display_safe_area().size.x;
				if minimumRes >= DisplayServer.get_display_safe_area().size.y:
					minimumRes = DisplayServer.get_display_safe_area().size.y
				
				for s in len(possibleResolutions):
					if possibleResolutions.get(s).y > minimumRes:
						optionsData.set("video_windowsize", clampi(s - 2, 0, 99))
						break;
			else:
				optionsData.set(i, _defaultOptionsData.get(i))
	
func setAchievementDefaults(checkExistence) :
	for i in _defaultAchievementData.keys():
		if (checkExistence and not achievementData.has(i)) or !checkExistence: achievementData.set(i, _defaultAchievementData.get(i))
	
func setSaveDefaults(checkExistence) :
	for i in _defaultSaveData.keys():
		if (checkExistence and not saveData.has(i)) or !checkExistence: saveData.set(i, _defaultSaveData.get(i))

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

func isNewHighScore(levID, diff, score):
	diff = str(diff)
	
	if diff not in saveData.highscores: return true
	else: return levID not in saveData.highscores[diff] or (levID in saveData.highscores[diff] and saveData.highscores[diff][levID] < score)

func setLevelHighScore(levID, diff, score):
	diff = str(diff)
	
	var gottaSave = false
	if diff not in saveData.highscores:
		saveData.highscores[diff] = {}
		gottaSave = true
	
	if isNewHighScore(levID, diff, score):
		saveData.highscores[diff][levID] = score
		gottaSave = true
	
	if gottaSave: saveSave()
	
func getHighScore(levID, diff):
	diff = str(diff)
	
	return 0 if diff not in saveData.highscores or levID not in saveData.highscores[diff] else saveData.highscores[diff][levID]

func watchedCutscene():
	if !saveData.has("cutscenes"): saveData.cutscenes = []
	if saveData.cutscenes.find(PlayGlobals.cutsceneID) == -1: saveData.cutscenes.append(PlayGlobals.cutsceneID)
	
	saveSave()

func hasWatchedCutscene():
	return saveData.has("cutscenes") and saveData.cutscenes.find(PlayGlobals.cutsceneID) > -1

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
	
	setOptionDefaults(true)
	setAchievementDefaults(true)
	setSaveDefaults(true)
	
	saveSave()

func eraseCurrentGameplaySave(curDiff = null):
	curDifficultySave = {}
	if curDiff != null: eraseDifficultySave(curDiff)

func applyImmediateSettings() -> void:
	for a in optionsData.keys():
		applySetting(a, optionsData[a])

func applySetting(type, valuemysanityplease): #this shit has no switch cases :sob:
	# check if the setting is the correct type, otherwise consider the settings save is corrupted
	var succeededInCheckingType = false;
	if (optionDefines.has(type)):
		if optionDefines.get(type).type == 0 && valuemysanityplease is float:
			succeededInCheckingType = true;
		if optionDefines.get(type).type == 1 && valuemysanityplease is bool:
			succeededInCheckingType = true;
		if optionDefines.get(type).type == 2 && valuemysanityplease is int:
			succeededInCheckingType = true;
		
	if !succeededInCheckingType: 
		resetOptions();
		return;
	
	if type == 'video_windowsize':
		if not OS.has_feature("web"):
			get_tree().root.content_scale_factor = 1;
			DisplayServer.window_set_size(possibleResolutions.get(valuemysanityplease))
			justCenterThisShitAlready()
		return
	elif type == 'video_windowmode':
		if not OS.has_feature("web"): # sumimasen deshita minaide kutedasai onegai.
			var displayModeThing;
			if valuemysanityplease == 0: displayModeThing = DisplayServer.WINDOW_MODE_WINDOWED;
			if valuemysanityplease == 1: displayModeThing = DisplayServer.WINDOW_MODE_FULLSCREEN;
			if valuemysanityplease == 2: displayModeThing = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN;
			
			DisplayServer.window_set_mode(displayModeThing);
		return
	elif type == 'video_resolution':
		if not OS.has_feature("web"): # sumimasen deshita minaide kutedasai onegai.
			get_viewport().scaling_3d_scale = valuemysanityplease;
		return
	elif type == 'video_passion':
		Passion.visibility(valuemysanityplease)
		return
	
	elif type == 'audio_master':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(valuemysanityplease))
		return
	elif type == 'audio_music':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(valuemysanityplease))
		return
	elif type == 'audio_sfx':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(valuemysanityplease))
		return
	elif type == 'audio_ambience':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), linear_to_db(valuemysanityplease))
		return
	elif type == 'audio_voicelines':
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voicelines"), linear_to_db(valuemysanityplease))
		return
	elif type == 'audio_subtitles':
		return
		## 0 - none, 1 - closed captioning, 2 - voicelines, 3 - all
		
	print("didn't do shit 😂")
	
func justCenterThisShitAlready() -> void:
	await get_tree().process_frame 
	var current_screen := DisplayServer.window_get_current_screen()
	var new_position := (DisplayServer.screen_get_size(current_screen) - DisplayServer.window_get_size()) / 2
	var screen_position := DisplayServer.screen_get_position(current_screen)
	DisplayServer.window_set_position(screen_position + new_position)

func _ready() -> void:
	cloudSave = await NG.cloudsave_get_data(1)
	
	if len(cloudSave) < 1:
	#if true: #DEV THINGY
		setOptionDefaults(false)
		setAchievementDefaults(false)
		setSaveDefaults(false)
		saveSave()
	else:
		loadSave()
		
	applyImmediateSettings()

func resetOptions():
	optionsData.clear()
	setOptionDefaults(false)
	
	applyImmediateSettings()
	saveSave()

func resetAchievements():
	achievementData.clear()
	setAchievementDefaults(false)
	
	saveSave()

func resetSaves():
	for i in 5:
		eraseDifficultySave(i)
	
	saveData.clear()
	setSaveDefaults(false)
	
	saveSave()

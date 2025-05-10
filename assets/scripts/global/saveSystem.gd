extends Node

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

var optionsData = {} ## will be automatically filled with values on loading save
var _defaultOptionsData = { ## enter the options you want to add
	"video_resolution" = 0, ##PC ONLY
	"video_fullscreen" = false, ##PC ONLY
	"video_passion" = false,
	"video_reducedmotions" = false,
	
	"audio_master" = 1.0,
	"audio_music" = 1.0,
	"audio_sfx" = 1.0,
	"audio_ambience" = 1.0,
	"audio_voicelines" = 1.0,
	"audio_subtitles" = 0,
	
	"gameplay_autofire" = false
}

var achievementData = {}
var _defaultAchievementData = {
	"_data": {
		
	}
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
	
	for i in _defaultOptionsData.keys():
		optionsData.set(i, _defaultOptionsData.get(i))
	for i in _defaultAchievementData.keys():
		achievementData.set(i, _defaultAchievementData.get(i))
	for i in _defaultSaveData.keys():
		saveData.set(i, _defaultSaveData.get(i))
		
	saveSave()
	applyImmediateSettings()

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
	print(PlayGlobals.cutsceneID)
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
	
	for i in _defaultOptionsData.keys():
		if not optionsData.has(i): optionsData.set(i, _defaultOptionsData.get(i))
	for i in _defaultAchievementData.keys():
		if not achievementData.has(i): achievementData.set(i, _defaultAchievementData.get(i))
	for i in _defaultSaveData.keys():
		if not saveData.has(i): saveData.set(i, _defaultSaveData.get(i))
		
	var minimumRes = DisplayServer.get_display_safe_area().size.x;
	if minimumRes >= DisplayServer.get_display_safe_area().size.y:
		minimumRes = DisplayServer.get_display_safe_area().size.y
	
	for i in len(possibleResolutions):
		if possibleResolutions.get(i).y > minimumRes:
			optionsData.set("video_resolution", clampi(i - 2, 0, 99))
			break;
	
	saveSave()

func eraseCurrentGameplaySave(curDiff = null):
	curDifficultySave = {}
	if curDiff != null: eraseDifficultySave(curDiff)

func applyImmediateSettings() -> void:
	for a in optionsData.keys():
		applySetting(a, optionsData[a])

func applySetting(type, valuemysanityplease): #this shit has no switch cases :sob:
	if type == 'video_resolution':
		if not OS.has_feature("web"): 
			DisplayServer.window_set_size(possibleResolutions.get(valuemysanityplease))
			justCenterThisShitAlready()
		return
	elif type == 'video_fullscreen':
		if not OS.has_feature("web"): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if valuemysanityplease else DisplayServer.WINDOW_MODE_WINDOWED)
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
		saveSave()
	else:
		loadSave()
		
	optionsData['audio_subtitles'] = 3
		
	applyImmediateSettings()

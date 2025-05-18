extends Node3D

@onready var camera = $Camera
@onready var shaders = $Shaders
@onready var hud = $HUD
@onready var countdown = $Audio/Coutndown
@onready var countHand = $HUD/Countdown
@onready var music = $Audio/Music
@onready var chunkLoader = $Objects
@onready var victroy = $Victory
@onready var scripts = $ScriptHandler

var player
var boss

var callForMovement = false
var shadertime = 0.0

#preload
var gameOverState = preload("res://assets/scenes/[SUB-SCENES]/game_over/game_over.tscn")
var gama;
var pauseState = preload("res://assets/scenes/[SUB-SCENES]/pause_menu/pause_menu.tscn")
var dialState = preload("res://assets/scenes/[SUB-SCENES]/dialogue/dialogue.tscn")
var dial

var hasBeenHurt = false

var canInput = false
var canPause = false
var hasBitchWon = false

#BOUND VARIABLES@onready var buttons = [$"New Tries", $Return]
var rotateBound = 13;
var maxBoundMod = 20;
var vertOffset = rotateBound;

#LEVEL VARIABLES
const PATH_LEVELS : String = 'res://assets/data/'
static var levelDefs;

#POWERS
var TRUElira:int = PlayGlobals.ownedLira;
var liraPGR:int = PlayGlobals.ownedLiraProgress;
var currentLevelLira:int = 0
var liraMax:int = 0;
var liraLevel:int = PlayGlobals.liraLevel;

var lifeThreshold = 5000
var lifeLira = PlayGlobals.ownedLira % lifeThreshold

#HEALTH
var levelNum:int = 0;

var lives:int = PlayGlobals.lifeCount[0];
var player_health:int = PlayGlobals.lifeCount[1];
var bossDEF;
var dialogues;

var isWarning = false

var diffuse_pal
var specular_pal

func _ready() -> void:
	Subtitles.setPlacementY(800 if PlayGlobals.difficulty < 4 else 750)
	Subtitles.setPlacementX(1160 if PlayGlobals.difficulty < 4 else null)
	AchievementFuncs.setPlacementY(100)
	
	#make sure you can pause to avoid anything fishy
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	#PREPARE LEVEL
	if FileAccess.file_exists(PATH_LEVELS+'level_'+PlayGlobals.levelID+'.json'):
		PlayGlobals.levelDefs = JSON.parse_string(FileAccess.open(PATH_LEVELS+'level_'+PlayGlobals.levelID+'.json', FileAccess.READ).get_as_text())
			
		buildLevel();
	else :
		print("Could Not Find LEVEL For "+PlayGlobals.levelID+'!')
		return
		
	#DIALOGUES
	if levelDefs.has("dialogue"): dialogues = levelDefs.dialogue.duplicate()
		
	#LIRA FORMULA
	instantLiraLevel()
		
	startLevel()
	player.startLevel()
	hud.postLevelBuild()
	scripts.runFunction("postBuild")
	
	chunkLoader.makeBGChunk()
	chunkLoader.makeLVChunk()
	
func initiateCountdown():
	canPause = true
	
	var county = ["three", "two", "one", "start"]
	countHand.visible = true;
	for i in county.size():
		countdown.stream = load("res://assets/sounds/voice/"+county[i]+".ogg")
		countdown.subtitle = '"'+county[i].substr(0,1).to_upper() + county[i].substr(1,999)+'"'
		countdown.subtitle_play()
		
		countHand.frame = i
		var countTween = get_tree().create_tween()
		
		if !SaveSystem.optionsData.get("video_reducedmotions", false):
			countHand.scale = Vector2(1.1 + 0.5*i, 1 + 0.4*i)
			countTween.tween_property(countHand, "scale", Vector2(1 + 0.1*i, 1 + 0.1*i), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
			countHand.rotation_degrees = -10 - 5 * i
			countTween.parallel().tween_property(countHand, "rotation_degrees", 0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
			countHand.position.y += 30 + 10 * i
			countTween.parallel().tween_property(countHand, "position:y", countHand.position.y - (30 + 10 * i) , 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		else:
			countHand.scale = Vector2(1 + 0.1*i, 1 + 0.1*i)
		
		countHand.self_modulate.a  = 1.0
		countTween.parallel().tween_property(countHand, "self_modulate:a", 0.0 , 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.35)
		
		if i == 1:
			callForMovement = true
			for obj in chunkLoader.get_children():
				if obj is TTTG_Chunk:
					obj.doMove = true
				
		scripts.runFunction("onCountdown", [i])
		
		await get_tree().create_timer(0.5,false).timeout #i like how this delays everything in the function
	
	postCount()

func postCount():
	canInput = true;
	music.play()
	music.volume_db = -15.0
	
	scripts.runFunction("levelStart")
	
	if SaveSystem.hasNotFirstTImeLevel(PlayGlobals.levelID) and !PlayGlobals.areWeFNFFreeDownload:
		$HUD/LevelName.text = "LEVEL "+str(int(levelDefs.id)+1)+": "+str(levelDefs.name)
		get_tree().create_tween().tween_property($HUD/LevelName, "position:y", $HUD/LevelName.position.y - 70, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		get_tree().create_tween().tween_property($HUD/LevelName, "position:y", $HUD/LevelName.position.y + 70, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_delay(5)
		SaveSystem.firstTimeLevelForMe(PlayGlobals.levelID)

func startLevel():
	await get_tree().create_timer(0.9,false).timeout #arbitrary thing but works with transitions in mind so i don't care
	
	if !PlayGlobals.areWeFNFFreeDownload and PlayGlobals.levelID == 'SHR':
		AchievementFuncs.unlockAchievement("SetSail")
	
	initiateCountdown()

func levelUpLiraFormula(lv): #my lira
	return round((80*(pow(lv, 2) - lv + 2))/PlayGlobals.LiraGainSpeed)
	
func levelUpLira():
	liraLevel += 1
	liraPGR = liraPGR - liraMax;
	liraMax = levelUpLiraFormula(liraLevel)
	
	scripts.runFunction("onLevelUp")
	
	hud.levelUpLira()
	player.levelUpLira()

func instantLiraLevel():
	liraMax = levelUpLiraFormula(liraLevel)
	hud.instantLiraLevel()
	player.levelUpLira()
	
func heal(health):
	player_health = min(3, player_health + health)
	if lives > 1 and player_health > 1: isWarning = false;
	
func hurtPlayer():
	hasBeenHurt = true
	player_health -= 1
	
	if player_health > 0:
		camera.shake(5.0, 1.0)
		hud.hurtPlayer()
		player.hurtPlayer()
		
		scripts.runFunction("onHurt")
	else:
		isWarning = false
		lives -= 1
		camera.shake(15.0, 2.0)
		hud.loseLife()
		player.loseLife()
		
		scripts.runFunction("onLifeLoss")
		
	if lives <= 0:
		gameOver()
		hud.gameOver()
		player.gameOver()
		
		scripts.runFunction("onGameOver")
		
func gameOver():
	canPause = false;
	
	if dial != null: dial.ending()

	get_tree().create_tween().tween_property(music, "pitch_scale", 0.00000001, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(0.5, false).timeout
	shaders.gameOver()
	$Audio/HeatStroke.subtitle_play()
	
	await get_tree().create_timer(3.5, false).timeout
	
	gama = gameOverState.instantiate()
	PlayGlobals.addSubstate(self, gama)
	
	process_mode = Node.PROCESS_MODE_DISABLED

@onready var btmF = $Floor
@onready var topF = $Sky
@onready var sun = $Sun
@onready var bg = $Background
var scrollSpeed = 0;
var scrollMod = 1.0

var scrollModFLOOR
var scrollModSKY

func buildLevel():
	levelDefs = PlayGlobals.levelDefs
	levelNum = levelDefs.id

	#SCROLL SPEED
	scrollSpeed = levelDefs.speed;
	
	#FLOOR AND SKY
	btmF.visible = levelDefs.has("floor")
	topF.visible = levelDefs.has("sky")
	
	if (btmF.visible):
		btmF.position.y = levelDefs.floor.y
		if levelDefs.floor.has("distance"): btmF.position.z -= levelDefs.floor.distance
		if levelDefs.floor.has("rotation"): btmF.rotation_degrees += Vector3(levelDefs.floor.rotation[0],levelDefs.floor.rotation[1],levelDefs.floor.rotation[2])
		btmF.mesh.material.set("shader_parameter/uv_scale",Vector2(levelDefs.floor.scale[0], levelDefs.floor.scale[1]))
		btmF.mesh.material.set("shader_parameter/tex",load("res://assets/images/levels/"+PlayGlobals.levelID+"/"+levelDefs.floor.texture+".png"))
		
		scrollModFLOOR = Vector2(levelDefs.floor.scrollMod[0], levelDefs.floor.scrollMod[1]) if levelDefs.floor.has("scrollMod") else Vector2(0,1)
	
	if (topF.visible):
		topF.position.y = levelDefs.sky.y
		if levelDefs.sky.has("distance"): topF.position.z -= levelDefs.sky.distance
		if levelDefs.sky.has("rotation"): topF.rotation_degrees += Vector3(levelDefs.sky.rotation[0],levelDefs.sky.rotation[1],levelDefs.sky.rotation[2])
		topF.mesh.material.set("shader_parameter/uv_scale",Vector2(levelDefs.sky.scale[0], levelDefs.sky.scale[1]))
		topF.mesh.material.set("shader_parameter/tex",load("res://assets/images/levels/"+PlayGlobals.levelID+"/"+levelDefs.sky.texture+".png"))
		
		scrollModSKY = Vector2(levelDefs.sky.scrollMod[0], levelDefs.sky.scrollMod[1]) if levelDefs.sky.has("scrollMod") else Vector2(0,1)
		
	#SUN
	sun.rotate_x(levelDefs.sun.angle[0])
	sun.rotate_y(levelDefs.sun.angle[1])
	sun.rotate_z(levelDefs.sun.angle[2])
	sun.sky_mode = 0 if levelDefs.sun.showSun.to_lower() == "true" else 1
	sun.light_color = Color(levelDefs.sun.color[0]/255, levelDefs.sun.color[1]/255, levelDefs.sun.color[2]/255, 1.0)
	sun.light_energy = levelDefs.sun.energy
	sun.light_indirect_energy = levelDefs.sun.lie
	sun.light_angular_distance = levelDefs.sun.lad
	sun.light_specular = levelDefs.sun.specular
	bg.environment.sky.sky_material.set_sun_angle_max(levelDefs.sun.maxAng)
	bg.environment.sky.sky_material.set_sun_curve(levelDefs.sun.curve)
	
	#BACKGROUND
	bg.environment.sky.sky_material.sky_top_color = Color(levelDefs.background.sky.top[0], levelDefs.background.sky.top[1], levelDefs.background.sky.top[2])/255
	bg.environment.sky.sky_material.sky_horizon_color = Color(levelDefs.background.sky.bottom[0], levelDefs.background.sky.bottom[1], levelDefs.background.sky.bottom[2])/255
	bg.environment.sky.sky_material.sky_curve = levelDefs.background.sky.curve
	
	bg.environment.sky.sky_material.ground_horizon_color = Color(levelDefs.background.ground.top[0], levelDefs.background.ground.top[1], levelDefs.background.ground.top[2])/255
	bg.environment.sky.sky_material.ground_bottom_color = Color(levelDefs.background.ground.bottom[0], levelDefs.background.ground.bottom[1], levelDefs.background.ground.bottom[2])/255
	bg.environment.sky.sky_material.ground_curve = levelDefs.background.ground.curve
	
	#FOG
	bg.environment.fog_light_color = bg.environment.sky.sky_material.ground_bottom_color
	bg.environment.fog_light_energy = levelDefs.fog.energy
	bg.environment.fog_sun_scatter = levelDefs.fog.sunScatter
	bg.environment.fog_density = levelDefs.fog.density
	bg.environment.fog_depth_begin = levelDefs.fog.distance.start
	bg.environment.fog_depth_end = levelDefs.fog.distance.end
	bg.environment.fog_depth_curve = levelDefs.fog.distance.curve
	
	diffuse_pal = load("res://assets/data/shade-gradient/"+PlayGlobals.levelID+"_diffuse.tres")
	specular_pal = load("res://assets/data/shade-gradient/"+PlayGlobals.levelID+"_specular.tres")
	
	#PLAYER
	player = load("res://assets/objects/general/ship/ship.tscn").instantiate()
	spawnOBJ(player)
	player.scale = Vector3(0.4,0.4,0.4)
	
	#BOSS
	bossDEF = levelDefs.boss;
	boss = load("res://assets/objects/bosses/"+bossDEF.type+"/"+bossDEF.type+".tscn").instantiate()
	spawnOBJ(boss)
	boss.position.z = -bossDEF.distance
	boss.position.y = levelDefs.floor.y
	boss.scale = Vector3(bossDEF.scale, bossDEF.scale, bossDEF.scale)
	boss.rotation_degrees.y = bossDEF.rotation
	boss.health = bossDEF.health
	
	#MUSIC
	music.stream = load("res://assets/music/levels/"+PlayGlobals.levelID+".ogg")
	music.play()
	
	#CHUNKS
	chunkLoader.prepareChunks()

func _process(delta: float) -> void:
	#SCENE RESTART
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_R): 
			if Input.is_key_pressed(KEY_SHIFT): PlayGlobals.levelDefs = JSON.parse_string(FileAccess.open(PATH_LEVELS+'level_'+PlayGlobals.levelID+'.json', FileAccess.READ).get_as_text())
			get_tree().reload_current_scene()
		if Input.is_key_pressed(KEY_MINUS): 
			boss.damage(boss.health)
	
	#PAUSING IT, although funnily enough canPause is not needed for now. Will be saved in case there's need.
	if canPause and Input.is_action_just_pressed("Pause_GP"):
		var assback = pauseState.instantiate()
		PlayGlobals.addSubstate(self, assback);
		get_tree().paused = true
		
		scripts.runFunction("onPause")
	
	#SCROLLING
	shadertime += delta * scrollMod;
	for a in [btmF, topF]:
		if a.visible:
			a.mesh.material.set("shader_parameter/uv_offset_speed", Vector2(scrollSpeed, scrollSpeed) * (scrollModFLOOR if a.name == "Floor" else scrollModSKY))
			a.mesh.material.set("shader_parameter/custom_time",shadertime)
	
	#BOUND CAMERA CONTROL
	vertOffset = (rotateBound - 8.0) if player.position.y < 0 else (rotateBound + 2.0)
	
	camera.h_offset = 0.0
	camera.v_offset = 0.0
	camera.rotation.y = 0.0
	camera.rotation.x = 0.0
	
	if (abs(player.position.x) >= rotateBound):
		camera.h_offset = clampf(((rotateBound + player.position.x) if player.position.x < 0.0 else (player.position.x - rotateBound)) * 1.2, -maxBoundMod, maxBoundMod)
		camera.rotation.y = camera.h_offset / 80
	
	if (abs(player.position.y) >= vertOffset):
		camera.v_offset = clampf(((vertOffset + player.position.y) if player.position.y < 0.0 else (player.position.y - vertOffset)) * 1.2, -maxBoundMod, maxBoundMod)
		camera.rotation.x = camera.v_offset / -80
		
	#LIRA LEVEL
	if liraPGR >= liraMax and liraLevel < PlayGlobals.maxLiraLevel:
		levelUpLira()
	
	if lifeLira > lifeThreshold:
		lifeLira -= 5000
		giveMeLife()
		
	#WARNING
	$Audio/Warning.volume_db = lerpf($Audio/Warning.volume_db, -10 if isWarning else -80, 0.3)
	if (player_health == 1 or lives == 1) and not isWarning and not hasBitchWon:
		isWarning = true
		$Audio/Warning.showSubtitles()
		
	#DIALOGUE
	if canInput and canPause and dialogues != null:
		if dialogues.size() > 0 and dialogues[0][0] >= boss.health / bossDEF.health * 100.0:
			loadDialogue()
			
func loadDialogue(dially = dialogues[0][1]):
	if dial != null: dial.queue_free()
	
	dial = dialState.instantiate()
	hud.add_child(dial)
	dial.startDialogue(dially)
	dial.position = Vector2(335.0,835.0)
	dialogues.pop_front()
	dial.set_meta("parent", self)
	
func wellithinkitstimetomoveonok():
	get_tree().paused = false
	scripts.runFunction("onUnpause")
	
#setting application
func applySetting(type, value):
	if type == 'gameplay_autofire':
		player.autofire = value
	
func spawnOBJ(obj): #spawn to the right group
	$Objects.add_child(obj)

var unlockedLevel = false
var firstTimeLevel = false
var newHighScore = false

func completeLevel():
	scripts.runFunction("onLevelComplete")
	
	if SaveSystem.hasNotUnlockedLevel(PlayGlobals.levelID):
		SaveSystem.unlockLevelForFree(PlayGlobals.levelID)
		unlockedLevel = true
	
	if SaveSystem.isNewHighScore(PlayGlobals.levelID, PlayGlobals.difficulty, currentLevelLira):
		newHighScore = true
		SaveSystem.setLevelHighScore(PlayGlobals.levelID, PlayGlobals.difficulty, currentLevelLira)
	
	hud.abracadabrahocuspocusnowyouwilldisappear(0.5)
	
	if levelDefs.nextLevel == 'complete':
		shaders.wyczernienie(0.0)
	else:
		get_tree().create_tween().tween_property(camera, "posi:z", 0.0, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
		get_tree().create_tween().tween_property(camera, "posi:y", 4.0, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
		
		get_tree().create_tween().tween_property(player, "position", Vector3(0.0,0.0,-20.0), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)

	if levelDefs.nextLevel == 'complete' and !PlayGlobals.areWeFNFFreeDownload:
			await get_tree().create_timer(0.5, false).timeout
			
			PlayGlobals.cutsceneID = 'aend'
			setCurrentSave()
			
			TransFuncs.switchScenes(self, "res://assets/scenes/cutscene/cutscene.tscn", false, false)
	else:
		$Audio/Victory.play()
		$Audio/Victory.volume_db = -5.0;

		victroy.start()

func setCurrentSave():
	SaveSystem.curDifficultySave.level = liraLevel
	SaveSystem.curDifficultySave.lirsProgress = liraPGR
	SaveSystem.curDifficultySave.lira = TRUElira
	SaveSystem.curDifficultySave.lives = lives
	SaveSystem.curDifficultySave.health = player_health
	
	SaveSystem.curDifficultySave.levelInitials = levelDefs.nextLevel
	if levelDefs.nextLevel == 'complete': SaveSystem.curDifficultySave.levelName = "SAVE COMPLETE"
	else:
		if FileAccess.file_exists(PATH_LEVELS+'level_'+levelDefs.nextLevel+'.json'):
			var tempLook = JSON.parse_string(FileAccess.open(PATH_LEVELS+'level_'+levelDefs.nextLevel+'.json', FileAccess.READ).get_as_text())
			SaveSystem.curDifficultySave.levelName = tempLook.name
		else :
			print("Could Not Find LEVEL For "+levelDefs.nextLevel+'!')
	
	SaveSystem.saveGame()

func nextLevel():
	PlayGlobals.prepareGame()
	PlayGlobals.levelID = levelDefs.nextLevel

func addLira(lira):
	TRUElira += lira
	liraPGR += lira
	currentLevelLira += lira
	lifeLira += lira

func giveMeLife():
	scripts.runFunction("onExtraLife")
	lives += 1
	$"Audio/1up".subtitle_play()
	hud.giveMeLife()
	isWarning = false;

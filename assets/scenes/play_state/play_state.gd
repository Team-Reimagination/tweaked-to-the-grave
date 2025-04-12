extends Node3D

@onready var camera = $Camera
@onready var shaders = $Shaders
@onready var countdown = $Audio/Coutndown
@onready var countHand = $HUD/Countdown
var player
var boss;

#preload
var gameOverState = preload("res://assets/scenes/[SUB-SCENES]/game_over/game_over.tscn")
var gama;
var pauseState = preload("res://assets/scenes/[SUB-SCENES]/pause_menu/pause_menu.tscn")

var canInput = false
var canPause = true

#BOUND VARIABLES
var rotateBound = 13;
var maxBoundMod = 20;
var vertOffset = rotateBound;

#LEVEL VARIABLES
const PATH_LEVELS : String = 'res://assets/data/'
static var levelDefs;

#POWERS
var TRUElira:int = 0;
var liraPGR:int = 0;
var liraMax:int = 0;
var liraLevel:int = 0;

#HEALTH
var levelNum:int = 0;

var lives:int = PlayGlobals.lifeCount[0];
var player_health:int = PlayGlobals.lifeCount[1];
var bossDEF;

var isWarning = false

func _ready() -> void:
	#make sure you can pause to avoid anything fishy
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	#PREPARE LEVEL
	if true:#!PlayGlobals.levelDefs:
		if FileAccess.file_exists(PATH_LEVELS+'level_'+PlayGlobals.levelID+'.json'):
			PlayGlobals.levelDefs = JSON.parse_string(FileAccess.open(PATH_LEVELS+'level_'+PlayGlobals.levelID+'.json', FileAccess.READ).get_as_text())
			
			buildLevel();
		else :
			print("Could Not Find LEVEL For "+PlayGlobals.levelID+'!')
	else:
		buildLevel();
		
	#LIRA FORMULA
	if liraLevel == 0: levelUpLira()
	else:
		$HUD.levelUpLira()
		player.levelUpLira()
		
	startLevel()
	player.startLevel()
	$HUD.postLevelBuild()
	
func initiateCountdown():
	var county = ["three", "two", "one", "start"]
	countHand.visible = true;
	for i in county.size():
		countdown.stream = load("res://assets/sounds/voice/"+county[i]+".ogg")
		countdown.play()
		
		countHand.frame = i
		var countTween = get_tree().create_tween()
		
		countHand.scale = Vector2(1.1 + 0.5*i, 1 + 0.4*i)
		countTween.tween_property(countHand, "scale", Vector2(1 + 0.1*i, 1 + 0.1*i), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		countHand.rotation_degrees = -10 - 5 * i
		countTween.parallel().tween_property(countHand, "rotation_degrees", 0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		countHand.position.y += 30 + 10 * i
		countTween.parallel().tween_property(countHand, "position:y", countHand.position.y - (30 + 10 * i) , 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		countHand.self_modulate.a  = 1.0
		countTween.parallel().tween_property(countHand, "self_modulate:a", 0.0 , 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.35)
		
		await get_tree().create_timer(0.5,false).timeout #i like how this delays everything in the function
	canInput = true;
	$Audio/Music.play()
	$Audio/Music.volume_db = -10.0

func startLevel():
	await get_tree().create_timer(0.75,false).timeout #arbitrary thing but works with transitions in mind so i don't care
	
	initiateCountdown()

func levelUpLiraFormula(lv): #my lira
	return round((25*(pow(lv, 2) - lv + 2))/PlayGlobals.LiraGainSpeed)
	
func levelUpLira():
	liraLevel += 1
	liraPGR = liraPGR - liraMax;
	liraMax = levelUpLiraFormula(liraLevel)
	
	$HUD.levelUpLira()
	player.levelUpLira()
	
func restartHealth():
	player_health = 3
	
func hurtPlayer():
	player_health -= 1
	
	if player_health > 0:
		camera.shake(5.0, 1.0)
		$HUD.hurtPlayer()
		player.hurtPlayer()
	else:
		isWarning = false
		lives -= 1
		camera.shake(15.0, 2.0)
		$HUD.loseLife()
		player.loseLife()
		
	if lives <= 0:
		gameOver()
		$HUD.gameOver()
		player.gameOver()
		
func gameOver():
	canPause = false;
	
	var musicFade = get_tree().create_tween()
	musicFade.tween_property($Audio/Music, "pitch_scale", 0.00000001, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var speedTween = get_tree().create_tween()
	speedTween.tween_property(self, "scrollSpeed", 0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(0.5, false).timeout
	shaders.gameOver()
	$Audio/HeatStroke.play()
	
	await get_tree().create_timer(3.5, false).timeout
	
	gama = gameOverState.instantiate()
	PlayGlobals.addSubstate(self, gama)
	
	process_mode = Node.PROCESS_MODE_DISABLED

@onready var btmF = $Floor
@onready var topF = $Sky
@onready var sun = $Sun
@onready var bg = $Background
var scrollSpeed = 0;
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
		btmF.mesh.material.uv1_scale = Vector3(levelDefs.floor.scale[0], levelDefs.floor.scale[1], levelDefs.floor.scale[2])
		btmF.mesh.material.albedo_texture = load("res://assets/images/levels/"+PlayGlobals.levelID+"/"+levelDefs.floor.texture+".png")
		scrollModFLOOR = Vector3(levelDefs.floor.scrollMod[0], levelDefs.floor.scrollMod[1], levelDefs.floor.scrollMod[2]) if levelDefs.floor.has("scrollMod") else Vector3(0,1,0)
	
	if (topF.visible):
		topF.position.y = levelDefs.sky.y
		topF.mesh.material.uv1_scale = Vector3(levelDefs.sky.scale[0], levelDefs.sky.scale[1], levelDefs.sky.scale[2])
		topF.mesh.material.albedo_texture = load("res://assets/images/levels/"+PlayGlobals.levelID+"/"+levelDefs.sky.texture+".png")
		scrollModSKY = Vector3(levelDefs.sky.scrollMod[0], levelDefs.sky.scrollMod[1], levelDefs.sky.scrollMod[2]) if levelDefs.sky.has("scrollMod") else Vector3(0,1,0)
		
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
	
	#PLAYER
	player = load("res://assets/objects/general/ship/ship.tscn").instantiate()
	spawnOBJ(player)
	#player.position.y = -20.0
	player.scale = Vector3(0.4,0.4,0.4)
	
	#BOSS
	bossDEF = levelDefs.boss;
	boss = load("res://assets/objects/bosses/"+bossDEF.type+"/"+bossDEF.type+".tscn").instantiate()
	spawnOBJ(boss)
	boss.position.z = -bossDEF.distance
	boss.position.y = levelDefs.floor.y
	boss.scale = Vector3(bossDEF.scale, bossDEF.scale, bossDEF.scale)
	boss.rotation_degrees.y = bossDEF.rotation
	
	#MUSIC
	$Audio/Music.stream = load("res://assets/music/levels/"+PlayGlobals.levelID+".ogg")
	$Audio/Music.play()

func _process(delta: float) -> void:
	#SCENE RESTART
	if Input.is_key_pressed(KEY_R): get_tree().reload_current_scene()
	
	#PAUSING IT, although funnily enough canPause is not needed for now. Will be saved in case there's need.
	if canPause and Input.is_action_just_pressed("Pause_GP"):
		var assback = pauseState.instantiate()
		PlayGlobals.addSubstate(self, assback);
		get_tree().paused = true
	
	#SCROLLING
	for a in [btmF, topF]:
		a.mesh.material.uv1_offset -= scrollSpeed * delta * (scrollModFLOOR if a.name == "Floor" else scrollModSKY)
	
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
		
	#WARNING
	$Audio/Warning.volume_db = lerpf($Audio/Warning.volume_db, -10 if isWarning else -80, 0.3)
	if (player_health == 1 or lives == 1) and not isWarning:
		isWarning = true
	
func wellithinkitstimetomoveonok():
	get_tree().paused = false
	
#setting application
func applySetting(type, value):
	if type == 'autofire':
		player.autofire = value
	
func spawnOBJ(obj): #spawn to the right group
	$Objects.add_child(obj)

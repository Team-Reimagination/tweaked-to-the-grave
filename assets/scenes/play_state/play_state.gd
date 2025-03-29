extends Node3D

@onready var player = $Objects/Ship;
@onready var camera = $Camera;
@onready var shaders = $Shaders;

var gameOverState = preload("res://assets/scenes/[SUB-SCENES]/game_over/game_over.tscn")
var gama;

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
static var levelNum:int = 0;

var lives:int = PlayGlobals.lifeCount[0];
var player_health:int = PlayGlobals.lifeCount[1];
var boss_health:float = 1200;
var cur_boss_health:float = 1200;

var isWarning = false

func _ready() -> void:
	PlayGlobals.applyDifficulty()
	
	#PREPARE LEVEL
	if !PlayGlobals.levelDefs:
		if FileAccess.file_exists(PATH_LEVELS+'level_'+PlayGlobals.levelID+'.json'):
			PlayGlobals.levelDefs = JSON.parse_string(FileAccess.open(PATH_LEVELS+'level_'+PlayGlobals.levelID+'.json', FileAccess.READ).get_as_text())
			levelDefs = PlayGlobals.levelDefs
			levelNum = levelDefs.id
			
			buildLevel();
		else :
			print("Could Not Find LEVEL For "+PlayGlobals.levelID+'!')
	else:
		levelDefs = PlayGlobals.levelDefs
		buildLevel();
		
	#LIRA FORMULA
	if liraLevel == 0: levelUpLira()
	else:
		$HUD.levelUpLira()
		player.levelUpLira()

func levelUpLiraFormula(lv):
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
	var musicFade = get_tree().create_tween()
	musicFade.tween_property($Audio/Music, "pitch_scale", 0.00000001, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var speedTween = get_tree().create_tween()
	speedTween.tween_property(self, "scrollSpeed", 0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(0.5).timeout
	shaders.gameOver()
	$Audio/HeatStroke.play()
	
	await get_tree().create_timer(3.5).timeout
	
	gama = gameOverState.instantiate()
	PlayGlobals.addSubstate(self, gama)
	
	self.process_mode = Node.PROCESS_MODE_DISABLED

@onready var btmF = $Floor
@onready var topF = $Sky
@onready var sun = $Sun
@onready var bg = $Background
var scrollSpeed = 0;
var scrollModFLOOR
var scrollModSKY

func preloadShit():
	var bull = await $ResourcePreloader.get_resource("railring").instantiate()
	add_child(bull)
	bull.hide()

func buildLevel():
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
	
	#HEALTH
	boss_health = levelDefs.bosshealth
	cur_boss_health = boss_health
	
	#MUSIC
	$Audio/Music.stream = load("res://assets/music/levels/"+PlayGlobals.levelID+".ogg")
	$Audio/Music.play()

func _process(delta: float) -> void:
	
	if Input.is_key_pressed(KEY_R): get_tree().reload_current_scene()
	
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
	
func spawnOBJ(obj):
	$Objects.add_child(obj)

func entityProcess(obj):
	if obj.position.z > 0:
		obj.queue_free()

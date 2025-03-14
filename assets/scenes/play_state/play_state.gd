extends Node3D

@onready var player = $Objects/Ship;
@onready var camera = $Camera;

#BOUND VARIABLES
static var rotateBound = 10;
static var maxBoundMod = 10;
static var vertOffset = rotateBound;

#LEVEL VARIABLES
const PATH_LEVELS : String = 'res://assets/data/'
static var levelID = "SHR";
@export var levelDefs:Dictionary;

func _ready() -> void:
	#PREPARE LEVEL
	if !levelDefs:
		if FileAccess.file_exists(PATH_LEVELS+'level_'+levelID+'.json'):
			levelDefs = JSON.parse_string(FileAccess.open(PATH_LEVELS+'level_'+levelID+'.json', FileAccess.READ).get_as_text())
			
			buildLevel();
		else :
			print("Could Not Find LEVEL For "+levelID+'!')
	else:
		buildLevel();
	
@onready var btmF = $Floor
@onready var topF = $Sky
@onready var sun = $Sun
var scrollSpeed = 0;
var scrollModFLOOR
var scrollModSKY

func buildLevel():
	btmF.visible = levelDefs.has("floor")
	topF.visible = levelDefs.has("sky")
	
	scrollSpeed = levelDefs.speed;
	
	if (btmF.visible):
		btmF.position.y = levelDefs.floor.y
		btmF.mesh.material.uv1_scale = Vector3(levelDefs.floor.scale[0], levelDefs.floor.scale[1], levelDefs.floor.scale[2])
		btmF.mesh.material.albedo_texture = load("res://assets/images/levels/"+levelID+"/"+levelDefs.floor.texture+".png")
		scrollModFLOOR = Vector3(levelDefs.floor.scrollMod[0], levelDefs.floor.scrollMod[1], levelDefs.floor.scrollMod[2]) if levelDefs.floor.has("scrollMod") else Vector3(0,1,0)
	
	if (topF.visible):
		topF.position.y = levelDefs.sky.y
		topF.mesh.material.uv1_scale = Vector3(levelDefs.sky.scale[0], levelDefs.sky.scale[1], levelDefs.sky.scale[2])
		topF.mesh.material.albedo_texture = load("res://assets/images/levels/"+levelID+"/"+levelDefs.sky.texture+".png")
		scrollModSKY = Vector3(levelDefs.sky.scrollMod[0], levelDefs.sky.scrollMod[1], levelDefs.sky.scrollMod[2]) if levelDefs.sky.has("scrollMod") else Vector3(0,1,0)
		
	sun.rotate_x(levelDefs.sun.angle[0])
	sun.rotate_y(levelDefs.sun.angle[1])
	sun.rotate_z(levelDefs.sun.angle[2])
	print(sun.rotation)

func _process(delta: float) -> void:
	
	if Input.is_key_pressed(KEY_R): get_tree().reload_current_scene()
	
	#SCROLLING
	for a in [btmF, topF]:
		a.mesh.material.uv1_offset -= scrollSpeed * delta * (scrollModFLOOR if a.name == "Floor" else scrollModSKY)
	
	#BOUND CAMERA CONTROL
	vertOffset = (rotateBound - 8.5) if player.position.y < 0 else (rotateBound + 5.0)
	
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

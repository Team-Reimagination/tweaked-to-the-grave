class_name TTTG_Entity
extends Area3D

@onready var scene = get_parent().get_parent()
var model;

@export var type = "";
@export var doProcessDistanceFade = true
@export var hasModel = true
@export var overridePos : Vector3 = Vector3(-INF,-INF,-INF)
@export var shortRenderDistance = false
@export var isBackgroundObject = true
@export var isGameplayObject = false
@export var overrideKillDistance = -INF

@export var floorHeightAdjustment = false
@export var yMOD = 0.0

var distanceFadePhase = -1;
var isDying = false

@export var disabled = false

var meshInstances = []
var meshesWithOverlay = []

func reset(isRecursive = false):
	isDying = false

func _ready() -> void:
	while scene.name != "PlayState": scene = scene.get_parent()
	
	if hasModel:
		model = $Model
		meshInstances = model.find_children("*", "MeshInstance3D", true, true).filter(func(x): return x.material_override != null)
	
	if PlayGlobals.levelDefs != null:
		for a in meshInstances:
			a.material_override = a.material_override.duplicate()
			
			a.material_override.set("shader_parameter/diffuse_gradient", scene.diffuse_pal)
			a.material_override.set("shader_parameter/specular_gradient", scene.specular_pal)

func _process(_delta: float) -> void:
	if disabled: return
	
	if floorHeightAdjustment: overridePos.y = scene.btmF.global_position.y + yMOD * scale.y
	
	for a in ["x","y","z"]:
		if overridePos[a] != -INF: self.global_position[a] = overridePos[a]
	
	if doProcessDistanceFade and PlayGlobals.levelDefs != null:
		if distanceFadePhase == 0 and self.global_position.z > -100:
			for a in meshInstances:
				a.material_override.set("shader_parameter/fade_start", 15)
				a.material_override.set("shader_parameter/fade_end", 30)
					
			distanceFadePhase = 1
		elif distanceFadePhase != 0 and self.global_position.z < -100:
			for a in meshInstances:
				a.material_override.set("shader_parameter/fade_start", PlayGlobals.getDistance(shortRenderDistance))
				a.material_override.set("shader_parameter/fade_end", PlayGlobals.getDistance(shortRenderDistance) - (100 if !shortRenderDistance else 30))
					
			distanceFadePhase = 0

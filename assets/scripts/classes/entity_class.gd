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

var distanceFadePhase = 0;
var isReady : bool = false
var isDying = false

var meshInstances = []
var meshesWithOverlay = []

func _ready() -> void:
	while scene.name != "PlayState": scene = scene.get_parent()
	
	if hasModel:
		model = $Model
	
	if doProcessDistanceFade and PlayGlobals.levelDefs != null:
		meshInstances = model.find_children("*", "MeshInstance3D", true, true).filter(func(x): return x.material_override != null)
	
		for a in meshInstances:
			a.material_override = a.material_override.duplicate()
			a.material_override.set("shader_parameter/fade_start", PlayGlobals.getDistance(shortRenderDistance))
			a.material_override.set("shader_parameter/fade_end", PlayGlobals.getDistance(shortRenderDistance) - 100)

func _process(_delta: float) -> void:
	if overridePos != Vector3(-INF,-INF,-INF):
		self.global_position = overridePos
	
	if self.global_position.z > 100 and type != 'boss' and !isDying:
			self.queue_free()
	
	if isReady:
		if doProcessDistanceFade and PlayGlobals.levelDefs != null and !isBackgroundObject:
			if distanceFadePhase == 0 and self.global_position.z > -100:
				for a in meshInstances:
					a.material_override.set("shader_parameter/fade_start", 15)
					a.material_override.set("shader_parameter/fade_end", 30)
					
				distanceFadePhase = 1

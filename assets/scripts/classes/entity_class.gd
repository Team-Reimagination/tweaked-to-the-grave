class_name TTTG_Entity
extends Area3D

@onready var scene = get_parent().get_parent()
var model;

@export var type = "";
@export var doProcessDistanceFade = true
@export var hasModel = true
@export var overridePos : Vector3 = Vector3(-INF,-INF,-INF)
@export var shortRenderDistance = true

var distanceFadePhase = 0;
var isReady : bool = false

var meshInstances = []
var meshesWithOverlay = []

func _ready() -> void:
	if hasModel:
		model = $Model
	
	if doProcessDistanceFade and PlayGlobals.levelDefs != null:
		meshInstances = model.find_children("*", "MeshInstance3D", true, true).filter(func(x): return x.material_overlay != null)
		meshesWithOverlay = model.find_children("*", "MeshInstance3D", true, true)
	
		for a in meshesWithOverlay:
			a.material_overlay.set("shader_parameter/fade_start", PlayGlobals.getDistance(shortRenderDistance))
			a.material_overlay.set("shader_parameter/fade_end", PlayGlobals.getDistance(shortRenderDistance) - 100)
					
		for a in meshInstances:
			a.mesh.surface_get_material(0).distance_fade_min_distance = PlayGlobals.getDistance(shortRenderDistance)
			a.mesh.surface_get_material(0).distance_fade_max_distance = PlayGlobals.getDistance(shortRenderDistance) - 100

func _process(_delta: float) -> void:
	if overridePos != Vector3(-INF,-INF,-INF):
		self.global_position = overridePos
	
	if self.global_position.z > 100 and type != 'boss':
			self.queue_free()
	
	if isReady:
		if doProcessDistanceFade and PlayGlobals.levelDefs != null:
			if distanceFadePhase == 0 and self.global_position.z > -100:
				for a in meshesWithOverlay:
					a.material_overlay.set("shader_parameter/fade_start", 10)
					a.material_overlay.set("shader_parameter/fade_end", 20)
					
				for a in meshInstances:
					a.mesh.surface_get_material(0).distance_fade_min_distance = 10
					a.mesh.surface_get_material(0).distance_fade_max_distance = 20
				distanceFadePhase = 1

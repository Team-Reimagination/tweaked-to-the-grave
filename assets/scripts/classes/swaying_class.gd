class_name TTTG_Swaying
extends TTTG_Fallable

@export var swaySpeed = 1.0
var timing = 0.0
var rotato

func reset(isRecursive = false):
	super.reset(isRecursive)
	
	timing = 0.0

func _ready() -> void:
	super._ready()
	rotato = $Model.rotation_degrees

func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)
	
	if !isDying:
		timing += delta * swaySpeed
		$Model.rotation_degrees.x = rotato.x + (sin(timing) * ($Rotation.rotation_degrees.x) - (sin(timing) * ($Rotation.rotation_degrees.x))/2)
		$Model.rotation_degrees.y = rotato.y + (cos(timing) * ($Rotation.rotation_degrees.y) - (cos(timing) * ($Rotation.rotation_degrees.y))/2)
		$Model.rotation_degrees.z = rotato.z + (sin(timing+0.5) * ($Rotation.rotation_degrees.z) - (sin(timing+0.5) * ($Rotation.rotation_degrees.z))/2)
		
		$Hitbox.rotation_degrees = $Model.rotation_degrees
		$Narrowbox.rotation_degrees = $Model.rotation_degrees

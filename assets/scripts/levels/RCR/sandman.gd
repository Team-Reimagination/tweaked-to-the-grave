extends Node

@onready var scene = get_parent().get_parent()
var marker: Marker3D
var timer = -1.0

func postBuild(_vars) -> void:
	marker = Marker3D.new()
	marker.position = Vector3(0.0,scene.levelDefs.floor.y,0.0)
	
	marker.position.y = scene.levelDefs.floor.y + (sin(timer)+1)*22
	
func _process(delta: float) -> void:
	if !scene.hasBitchWon and scene.lives > 0 and scene.canInput:
		timer += delta / 25
		marker.position.y = scene.levelDefs.floor.y + (sin(timer)+1)*22
	else:
		if scene.hasBitchWon or scene.lives <= 0: marker.position.y = lerp(marker.position.y, scene.levelDefs.floor.y, 0.07)
	
	scene.btmF.position.y = marker.position.y
	
	if scene.player.global_position.y < marker.position.y and scene.player.canBeHit and scene.canInput and !scene.hasBitchWon: scene.hurtPlayer()

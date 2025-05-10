extends Node

@onready var scene = get_parent().get_parent()
var marker: Marker3D
var timer = -1.0

var surface : Parallax2D
var sand : Parallax2D

func postBuild(_vars) -> void:
	marker = Marker3D.new()
	marker.position = Vector3(0.0,scene.levelDefs.floor.y,0.0)
	
	marker.position.y = scene.levelDefs.floor.y + (sin(timer)+1)*14
	
	#SAND
	sand = Parallax2D.new()
	scene.hud.lowLayer.add_child(sand)
	
	var sandy: Sprite2D = Sprite2D.new()
	sandy.texture = load("res://assets/images/levels/RCR/rising_sand.png")
	sandy.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sandy.region_enabled = true
	sandy.region_rect = Rect2(Vector2(0.0,0.0), Vector2(1280, sandy.texture.get_height()*10))
	sandy.position.x = 640
	sand.add_child(sandy)
	
	sand.autoscroll = Vector2(0,-20)
	
	#SURFACE
	surface = Parallax2D.new()
	scene.hud.lowLayer.add_child(surface)
	
	var surfy: Sprite2D = Sprite2D.new()
	surfy.texture = load("res://assets/images/levels/RCR/rising_sand_surface.png")
	surface.add_child(surfy)
	
	surface.autoscroll = Vector2(20,0.0)
	surface.repeat_times = 30;
	surface.repeat_size.x = surfy.texture.get_width()
	
func onBossDefeat(_vars):
	sand.visible = false
	surface.visible = false

func _process(delta: float) -> void:
	if !scene.hasBitchWon and scene.lives > 0 and scene.canInput:
		timer += delta / 25
		marker.position.y = scene.levelDefs.floor.y + (sin(timer)+1)*14
	else:
		if scene.hasBitchWon or scene.lives <= 0: marker.position.y = lerp(marker.position.y, scene.levelDefs.floor.y, 0.07)
	
	scene.btmF.global_position.y = marker.position.y
	surface.get_child(0).position.y = scene.camera.unproject_position(Vector3(scene.btmF.global_position.x, scene.btmF.global_position.y, -20)).y
	sand.get_child(0).position.y = surface.get_child(0).position.y + surface.get_child(0).texture.get_height()/3 + sand.get_child(0).region_rect.size.y/2
	
	if scene.player.global_position.y < marker.position.y and scene.player.canBeHit and scene.canInput and !scene.hasBitchWon: scene.hurtPlayer()

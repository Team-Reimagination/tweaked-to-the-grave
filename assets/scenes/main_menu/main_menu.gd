extends Node2D

@onready var cam = $Camera
var canInput = true;
var isTransitioning = false
var canSkip = true

var zoomMod = 1.0
var posMod = Vector2.ZERO
var posForMod = Vector2.ZERO
var rotMod = 0.0
var rotForMod = 0.0

var gloTimer = 0.0;
var watimer = 0.0;

func _process(delta: float) -> void:
	if canInput: #parallax with mouse dependent on if it's the state's turn to use the mouse or not
		cam.offset.x = lerp(cam.offset.x, clampf(get_global_mouse_position().x - 640.0, -640.0, 640.0) / 50, 0.3)
		cam.offset.y = lerp(cam.offset.y, clampf(get_global_mouse_position().y - 480.0, -480.0, 480.0) / 50, 0.3)
	else:
		cam.offset.x = lerp(cam.offset.x, clampf(0, -640.0, 640.0) / 50, 0.3)
		cam.offset.y = lerp(cam.offset.y, clampf(0, -480.0, 480.0) / 50, 0.3)
		
	if isTransitioning: #sweet camerashots when about to transition into gameplay
		gloTimer += delta
		watimer += delta
		
		zoomMod = 1 + sin(gloTimer*4.5)*0.10
		
		while watimer > 1.0/5:
			watimer -= 1.0/5
			posForMod = Vector2(randf_range(-500, 500),randf_range(-500, 500))
			rotForMod = randf_range(-10, 10)
			
		posMod = Vector2(lerpf(posMod.x,posForMod.x, 0.002), lerpf(posMod.y,posForMod.y, 0.002))
		rotMod = rotForMod
		
		cam.zoom.x = lerpf(cam.zoom.x, 1.75 * zoomMod, 0.3)
		cam.zoom.y = cam.zoom.x
		cam.set_position(Vector2(lerpf(cam.position.x, 640.0 + posMod.x, 0.3), lerpf(cam.position.y, 920.0 + posMod.y, 0.3)))
		cam.rotation_degrees = rotMod
		
		if (Input.is_action_just_pressed("Accept_UI") or CustomCursor.isMouseJustPressed("left")) and canSkip: TransFuncs.switchScenes(self, "res://assets/scenes/play_state/play_state.tscn" if !isNewGame else "res://assets/scenes/cutscene/cutscene.tscn", false, !isNewGame)

var isNewGame = false

func someNew():
	isNewGame = true

func wellithinkitstimetomoveonok(): #hand materaliza
	PlayGlobals.youarenolongermyfriendsoundnowgoaway()
	$Music/Loop.stop()
	
	if !PlayGlobals.areWeFNFFreeDownload:
		isTransitioning = true
		
		$ParallaxBackground/Grave.wellithinkitstimetomoveonok()
		$Music/End.play()
		
		$Shaders.visible = true
		$Shaders/Flash.color.a = 1.0
		$Shaders/Pixelation.material["shader_parameter/pixel_size"] = 0.1;
		get_tree().create_tween().tween_property($Shaders/Flash, "color:a", 0.0, 0.5).set_ease(Tween.EASE_OUT)
		
		get_tree().create_tween().tween_property($ParallaxBackground/Logo, "modulate:a", 0.0, 0.1).set_ease(Tween.EASE_OUT)
		
		await get_tree().create_timer(1.5).timeout
		get_tree().create_tween().tween_property($Shaders/Pixelation.material, "shader_parameter/pixel_size", 100.0, 5.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		await get_tree().create_timer(2.0).timeout
		canSkip = false
		TransFuncs.switchScenes(self, "res://assets/scenes/play_state/play_state.tscn" if !isNewGame else "res://assets/scenes/cutscene/cutscene.tscn", true, !isNewGame)
	else:
		MenuSounds.playMenuSound("select")
		TransFuncs.switchScenes(self, "res://assets/scenes/play_state/play_state.tscn")

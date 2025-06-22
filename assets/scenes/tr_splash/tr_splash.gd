extends Node2D

func _ready() -> void:
	$Cloud.visible = false

func _process(_delta: float) -> void:
	#print($Splash.frame);
	if !$Cloud.visible: ready()
	
	if ($Cloud.animation == "Appear" and !$Cloud.is_playing()): $Cloud.play("Loop")
	if ($Cloud.animation == "Move" and !$Cloud.is_playing()): $Cloud.play("Pulsate")
	
	if (Input.is_action_just_pressed("Accept_UI") or CustomCursor.isMouseJustPressed("left")): switchScene()

func ready():
	$Cloud.visible = true;
	$Cloud.play("Appear")
	
	$Music.play()
	$Music.volume_db = 0.0
	$Music.finished.connect(func(): switchScene());
	
	get_tree().create_tween().tween_property($Camera2D, "zoom", Vector2(1.0,1.0), 3.0);
	
	await get_tree().create_timer(3.2, true).timeout
	$Cloud.play("Move")
	var tweener = get_tree().create_tween()
	
	tweener.parallel().tween_property($Background.material, "shader_parameter/redFloat", 1.0, 1.48)
	tweener.parallel().tween_property($Background.material, "shader_parameter/greenFloat", 1.0, 1.48)
	tweener.parallel().tween_property($Background.material, "shader_parameter/redAdd", 0.0, 1.48)
	tweener.parallel().tween_property($Background.material, "shader_parameter/greenAdd", 0.0, 1.48)
	tweener.parallel().tween_property($Background.material, "shader_parameter/blueAdd", 0.0, 1.48)
	tweener.parallel().tween_property($Background.material, "shader_parameter/checkAlpha", 0.08, 0.79).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	
	await get_tree().create_timer(0.09, true).timeout
	$Text.play("Text")
	
	await get_tree().create_timer(4.31, true).timeout
	tweener = get_tree().create_tween()
	tweener.parallel().tween_property($FadeLines.material, "shader_parameter/barPos", 0.0, 0.88)

func switchScene():
	TransFuncs.switchScenes(self, "res://assets/scenes/main_menu/main_menu.tscn", false)

extends Node2D

var frameState = 0;
var fadeTween;

func _ready() -> void:
	$TR.visible = false

func _process(_delta: float) -> void:
	#print($Splash.frame);
	if (!$Splash/Music.playing && $Splash.frame >= 1 && $Splash.frame < 10): $Splash/Music.play()
	
	if (Input.is_action_just_pressed("Accept_UI") or CustomCursor.isMouseJustPressed("left")): switchScene()
	
	if ((frameState == 0 && $Splash.frame >= 96)
	|| (frameState == 1 && $Splash.frame >= 106)
	|| (frameState == 2 && $Splash.frame >= 170)):
		tweenHandler();
		

func tweenHandler():
	frameState += 1;
	if fadeTween:
		fadeTween.kill()
	fadeTween = get_tree().create_tween()
	
	if (frameState == 1):
		fadeTween.tween_property($Shaders/ColorMod.material, "shader_parameter/offsets", Vector4(1.0, 1.0, 1.0, 0.0), 0.4).set_trans(Tween.TRANS_QUART)
	elif (frameState == 2):
		fadeTween.tween_property($Shaders/ColorMod.material, "shader_parameter/offsets", Vector4(0.0, 0.0, 0.0, 0.0), 0.25).set_trans(Tween.TRANS_QUART)
	elif (frameState == 3):
		fadeTween.tween_property($Shaders/ColorMod.material, "shader_parameter/offsets", Vector4(-1.0, -1.0, -1.0, 0.0), 0.5).set_trans(Tween.TRANS_QUART)
		
		await fadeTween.finished
		tweenHandler()
	elif (frameState == 4):
		$Splash.visible = false
		$TR.visible = true
		fadeTween.tween_property($Shaders/ColorMod.material, "shader_parameter/offsets", Vector4(0.0, 0.0, 0.0, 0.0), 0.5).set_trans(Tween.TRANS_QUART)
		$TR/Music2.play()
		
		await get_tree().create_timer(3.0).timeout
		tweenHandler()
	elif (frameState == 5):
		fadeTween.tween_property($Shaders/ColorMod.material, "shader_parameter/offsets", Vector4(-1.0, -1.0, -1.0, 0.0), 0.5)
		await get_tree().create_timer(2.25, false).timeout
		switchScene();
		
func switchScene():
	TransFuncs.switchScenes(self, "res://assets/scenes/main_menu/main_menu.tscn", false)

func _on_tree_entered() -> void:
	$Shaders/ColorMod.material.set("shader_parameter/multipliers", [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0])

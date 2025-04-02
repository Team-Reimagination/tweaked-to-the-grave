extends Node2D

func _ready() -> void:
	if not OS.has_feature("web"): get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/sbb_splash/sbb_splash.tscn") #call deferred prevents warning about it being busy adding children, bruh
	else:
		$Sprite2D.visible = true
	
func _process(_delta: float) -> void:
	if $Sprite2D.offset.y > 0:
		get_tree().change_scene_to_file("res://assets/scenes/sbb_splash/sbb_splash.tscn")
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): 
		$Sprite2D.offset.y += 20

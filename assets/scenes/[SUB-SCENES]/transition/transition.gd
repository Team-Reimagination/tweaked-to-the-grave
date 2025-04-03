extends Control

@onready var trans = $Shaders/Transition
var twa;

func mytransrights() -> void:
	twa = get_tree().create_tween()
	
	trans.material["shader_parameter/time"] = 0.75 if not TransFuncs.tIN else -2.25
	twa.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(trans.material, "shader_parameter/time", 3.0 if not TransFuncs.tIN else 0.0, 1)
	
	twa.finished.connect(TransFuncs.changeClothes.bind())

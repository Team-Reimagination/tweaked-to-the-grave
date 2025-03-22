extends CanvasLayer

@onready var scene = self.get_parent();

@onready var warning = $Vignette
@onready var warnTimer = $VignetteTimer

@onready var fire = $Burn

var strengthWarn = 0;
var moveStr = 0.5

func _ready() -> void:
	fire.material["shader_parameter/distortionStrength"] = -1.5

func gameOver():
	var ass = get_tree().create_tween()
	ass.tween_property(fire.material, "shader_parameter/distortionStrength", 4.0, 5.0).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	var ass2 = get_tree().create_tween()
	ass2.tween_property(self, "moveStr", 0.0, 2.0).set_delay(2.0)

func _process(delta: float) -> void:
	warning.material["shader_parameter/outerRadius"] = 3.5 + sin(warnTimer.time_left*3.1)
	warning.material["shader_parameter/MainAlpha"] = strengthWarn
	
	strengthWarn = lerpf(strengthWarn, 1.0 if scene.isWarning else 0.0, 0.02)
	
	if warnTimer.time_left <= 0:
		warnTimer.start(2.0)
	
	fire.material["shader_parameter/fireMovement"].y -= delta*moveStr

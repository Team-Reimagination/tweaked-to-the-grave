extends CanvasLayer

@onready var scene = self.get_parent();

@onready var warning = $Vignette
@onready var warnTimer = $VignetteTimer
@onready var fire = $Burn
@onready var flash = $Flash

var strengthWarn = 0;
var moveStr = 0.5

func wybielenie(time):
	flash.color = Color(1.0,1.0,1.0,1.0);
	get_tree().create_tween().tween_property(flash, "color:a", 0.0, time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
func wyczernienie(time):
	flash.color = Color(0.0,0.0,0.0,0.0);
	get_tree().create_tween().tween_property(flash, "color:a", 1.0, time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

func _ready() -> void:
	#prep
	fire.material.set("shader_parameter/distortionStrength",-2.0)

func gameOver():
	#swim upwards, fire
	var ass = get_tree().create_tween()
	ass.tween_property(fire.material, "shader_parameter/distortionStrength", 4.0, 4.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	ass.parallel().tween_property(self, "moveStr", 0.0, 3.0).set_delay(2.0)

func _process(delta: float) -> void:
	#always set the warning, but only show it if you really need to
	warning.material.set("shader_parameter/outerRadius", 3.5 + sin(warnTimer.time_left*3.1))
	warning.material.set("shader_parameter/MainAlpha", strengthWarn)
	
	strengthWarn = lerpf(strengthWarn, 1.0 if scene.isWarning else 0.0, 0.02)
	
	if warnTimer.time_left <= 0: #timers don't support loops apparently in godot :(
		warnTimer.start(2.0)
	
	fire.material["shader_parameter/fireMovement"].y -= delta*moveStr

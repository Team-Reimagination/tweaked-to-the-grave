extends Camera3D

var posi = Vector3(0.0,4.0,0.0)
var roti = Vector3(0.0,0.0,0.0)

var strength = 0.0
var shakeMod = Vector3.ZERO
var shakePos = Vector3.ZERO

var rotiMod = Vector3.ZERO
var rotiPos = Vector3.ZERO

func shake(stt, time):
	strength = stt
	
	var shakeT = get_tree().create_tween()
	shakeT.tween_property(self, "strength", 0, time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func _process(_delta: float) -> void:
	if strength >= 0.01:
		shakeMod = Vector3(randf_range(-1,1)*strength, randf_range(-1,1)*strength, 0.0)
		rotiMod = Vector3(0.0, 0.0, randf_range(-1,1)*strength)
		
		for i in ["x", "y", "z"]:
			shakePos[i] = lerpf(shakePos[i], shakeMod[i], 0.5)
			rotiPos[i] = lerpf(rotiPos[i], rotiMod[i], 0.25)
	else:
		if shakePos != Vector3.ZERO: shakePos = Vector3.ZERO
		if rotiPos != Vector3.ZERO: rotiPos = Vector3.ZERO
	
	position = posi + shakePos
	rotation_degrees = roti + rotiPos

extends Node2D

@onready var backgroundGradient = $BackgroundColor/Gradient
@onready var friendGroupHeads = $FriendGroupHeads

func _ready() -> void:
	backgroundGradient.material.set("shader_parameter/Color1",Vector3(0.0,0.0,0.0))
	backgroundGradient.material.set("shader_parameter/Color2",Vector3(0.0,0.0,0.0))
	backgroundGradient.material.set("shader_parameter/Color1Alpha",0.0)
	backgroundGradient.material.set("shader_parameter/Color2Alpha",0.0)
	
	friendGroupHeads.modulate.a = 0.0
	
	setBGColor(20, 0, 40, 'top')
	setBGColor(90, 0.7, 0.3, 'bottom')
	fadeBackground(5.0, 'in')
	
	setBGColor(180, 60, 120, 'top', 15)
	setBGColor(0.45, 0.75, 0.4, 'bottom', 20)
	
	myHeadScrolls(-10)
	myHeadScrolls(-80, 5)
	
func getBackgroundColor(id):
	return backgroundGradient.material["shader_parameter/Color"+str(id)]

func fadeBackground(time, type = 'in'):
	var tweeny = get_tree().create_tween()
	
	tweeny.tween_property(friendGroupHeads, "modulate:a", 1.0 if type == 'in' else 0.0, time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	tweeny.set_parallel(true).tween_property(backgroundGradient.material, "shader_parameter/Color1Alpha", 1.0 if type == 'in' else 0.0, time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	tweeny.set_parallel(true).tween_property(backgroundGradient.material, "shader_parameter/Color2Alpha", 1.0 if type == 'in' else 0.0, time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)

func setBGColor(red, green, blue, part, time = null):
	if red > 1.0: red /= 255.0
	if green > 1.0: green /= 255.0
	if blue > 1.0: blue /= 255.0
	
	var party = str(1 if part == 'top' else 2)
	
	if time == null:
		print("hi")
		backgroundGradient.material.set("shader_parameter/Color"+party,Vector3(red, green, blue))
	else:
		print("hello")
		var tweener = get_tree().create_tween()
		tweener.tween_property(backgroundGradient.material, "shader_parameter/Color"+party, Vector3(red, green, blue), time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)

func myHeadScrolls(speed, time = null):
	if time == null:
		friendGroupHeads.autoscroll.x = speed
	else:
		var tweener = get_tree().create_tween()
		tweener.tween_property(friendGroupHeads, "autoscroll:x", speed, time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)

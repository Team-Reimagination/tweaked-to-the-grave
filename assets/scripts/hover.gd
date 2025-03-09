extends Sprite2D

var yFloat
var ySpeed
var time = 0;

func _process(delta: float) -> void:
	time += delta
	self.position.y += sin(time * ySpeed) * yFloat
	
	#DEV FUNCTION
	if Input.is_action_just_pressed("Accept_UI"): get_tree().change_scene_to_file("res://assets/scenes/play_state/play_state.tscn")

func _on_tree_entered() -> void:
	yFloat = self.get_meta("y_float", 0);
	ySpeed = self.get_meta("y_speed", 0);

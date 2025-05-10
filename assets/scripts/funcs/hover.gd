extends Sprite2D

var yFloat
var ySpeed
var time = 0;

func _process(delta: float) -> void:
	if SaveSystem.optionsData.get("video_reducedmotions", false): return
	
	time += delta
	self.position.y += sin(time * ySpeed) * yFloat

func _on_tree_entered() -> void:
	yFloat = self.get_meta("y_float", 0);
	ySpeed = self.get_meta("y_speed", 0);

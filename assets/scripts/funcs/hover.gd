extends Sprite2D

var yFloat
var ySpeed
var time = 0;

func _process(delta: float) -> void:
	time += delta
	self.position.y += sin(time * ySpeed) * yFloat

func _on_tree_entered() -> void:
	yFloat = self.get_meta("y_float", 0);
	ySpeed = self.get_meta("y_speed", 0);

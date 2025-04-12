extends Sprite3D

var targScale = 1.5;
var timer = 0.0;

func _process(delta: float) -> void:
	timer += delta;
	
	scale.y = 3.0 + (sin(timer) * (targScale))

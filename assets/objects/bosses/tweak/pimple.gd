extends Sprite3D

var targScale = randf_range(0.15,0.5);
var timer = 0.0;
var scaleOffset = randf_range(-0.5,0.5)
var multiOffset = randf_range(0.9,1.1)
var timeOffset = randf_range(0.5,1.5)

func _process(delta: float) -> void:
	timer += delta * timeOffset;
	
	var onScale = 1.0 + (sin(timer + scaleOffset) * (targScale * multiOffset))
	scale = Vector3(onScale,onScale,onScale)

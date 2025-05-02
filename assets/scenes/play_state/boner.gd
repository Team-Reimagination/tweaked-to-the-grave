extends Label

var yPos = 0.0

func _ready() -> void:
	yPos = position.y
	
func _process(delta: float) -> void:
	position.y = lerpf(position.y, yPos, 0.3)

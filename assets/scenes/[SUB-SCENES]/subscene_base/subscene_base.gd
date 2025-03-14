extends CanvasLayer

@onready var bg = $Background
@onready var scaleRef = $ScaleRef

var scaler = Vector2.ZERO

func _ready() -> void:
	scaler = $ScaleRef.size
	
func _process(_delta: float) -> void:
	bg.size.x = lerp(bg.size.x, scaleRef.size.x, 0.2)
	bg.size.y = lerp(bg.size.y, scaleRef.size.y, 0.2)
	
	bg.position.x = 640 - bg.size.x/2
	bg.position.y = 480 - bg.size.y/2

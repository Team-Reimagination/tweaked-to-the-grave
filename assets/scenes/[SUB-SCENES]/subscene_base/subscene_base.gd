extends CanvasLayer

@onready var bg = $Background
@onready var scaleRef = $ScaleRef

var scaler = Vector2.ZERO
var scaleLerp = 0.4
var posMod = Vector2(0.0,0.0)

func _ready() -> void:
	scaler = $ScaleRef.size
	
func _process(_delta: float) -> void:
	bg.size.x = lerp(bg.size.x, scaleRef.size.x, scaleLerp)
	bg.size.y = lerp(bg.size.y, scaleRef.size.y, scaleLerp)
	
	bg.position.x = 640 - bg.size.x/2 + posMod.x
	bg.position.y = 480 - bg.size.y/2 + posMod.y

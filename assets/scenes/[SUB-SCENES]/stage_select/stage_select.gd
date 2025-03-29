extends CanvasLayer

var scaleFactor = Vector2(0.0,0.0)
@onready var scaleLerp = $"../Base".scaleLerp 

func scalemyfuck():
	scaleFactor = $"../Base/Background".size / $"../Base/ScaleRef".size
	scale = scaleFactor

func _ready() -> void:
	scalemyfuck()
	
func _process(_delta: float) -> void:
	scalemyfuck()

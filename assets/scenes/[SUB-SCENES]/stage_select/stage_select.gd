extends Control

var scaleFactor = Vector2(0.0,0.0)
@onready var scaleLerp = $Base.scaleLerp 

var canInput = true

func scalemyfuck():
	scaleFactor = $Base/Background.size / $ScaleRef.size
	$Inside.scale = scaleFactor

func _ready() -> void:
	scalemyfuck()
	
func _process(_delta: float) -> void:
	scalemyfuck()
	
	if canInput and (Input.is_action_just_pressed("Back_UI") or CustomCursor.isMouseJustPressed("right")):
		moveOn(true, false)
		
	if not canInput and $Base/Background.scale <= Vector2(0.05, 0.05):
		PlayGlobals.removeSubstate(self);

func moveOn(justQuitting, isNewGame):
	canInput = false;
	$ScaleRef.size = Vector2(0.0,0.0)
	get_tree().create_tween().tween_property($Base/Background, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)
		
	if !justQuitting:
		$Inside/Difficulty.mouseBtn = -1
		PlayGlobals.difficulty = $Inside/Difficulty.antiterios
		PlayGlobals.prepareGame()
			
		if isNewGame: PlayGlobals.subCallings(self, "someNew")
		PlayGlobals.subCallings(self, "wellithinkitstimetomoveonok")
	else:
		get_meta("parent").canInput = true

class_name TTTG_Stomping_MultiPath
extends TTTG_Trailing

var moveTween

@export var paths : Array[Dictionary] = [
	{
		"ease": "in",
		"trans": "circ",
		"time": 1.0,
		"wait": 1.0
	},
	{
		"ease": "in",
		"trans": "circ",
		"time": 1.0,
		"wait": 1.0
	},
	{
		"ease": "in",
		"trans": "circ",
		"time": 1.0,
		"wait": 1.0
	}
]
var points = []
var curPoint = 0

func reset(isRecursive = false):
	super.reset(isRecursive)

	if moveTween: moveTween.kill()
	
	curPoint = 0
	
	$Model.position = points[curPoint].position
	$Hitbox.position = points[curPoint].position
	$NarrowBox.position = points[curPoint].position

func _ready() -> void:
	super._ready()
	
	points = $Paths.get_children()
	
	$Model.position = points[curPoint].position
	$Hitbox.position = points[curPoint].position
	$NarrowBox.position = points[curPoint].position

func movemental():
	if disabled: return
	
	super.movemental()
	
	if !isDying:
		var pather = (curPoint + 1) % points.size()
		var curPath = paths[curPoint]
		
		moveTween = get_tree().create_tween()
	
		moveTween.set_parallel(true).tween_property($Model, "position", points[pather].position, curPath.time).set_ease(PlayGlobals.getEaseType(curPath.ease)).set_trans(PlayGlobals.getTransType(curPath.trans))
		moveTween.set_parallel(true).tween_property($Hitbox, "position", points[pather].position, curPath.time).set_ease(PlayGlobals.getEaseType(curPath.ease)).set_trans(PlayGlobals.getTransType(curPath.trans))
		moveTween.set_parallel(true).tween_property($NarrowBox, "position", points[pather].position, curPath.time).set_ease(PlayGlobals.getEaseType(curPath.ease)).set_trans(PlayGlobals.getTransType(curPath.trans))
	
		await moveTween.finished
		print()
		await get_tree().create_timer(curPath.wait, false).timeout

		if disabled: return
		
		else:
			if (curPoint == points.size()-1 and !onlyOnce or curPoint < points.size()-1):
				curPoint = pather
				movemental()

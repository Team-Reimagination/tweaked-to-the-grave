extends CanvasLayer

var isItReady = false

var isTransIn = false
var doDestroyEarly = false

var state = "reset"
var newState

@onready var trans = $Transition
var twa;

func progress():
	if not isTransIn:
		#for obj in get_tree().root.find_children("*", "", true, false):
		#	if obj.has_method("transOut"): obj.call("transOut")
		
		isTransIn = true;
		isItReady = false
		
		PlayGlobals.removeAllSubstates()
		
		if state == "reset":
			get_tree().root.get_child(3).get_tree().reload_current_scene()
		else:
			get_tree().root.get_child(3).get_tree().change_scene_to_packed(newState)
	else:
		get_parent().queue_free()

func start() -> void:
	if state != 'reset': newState = load(state)
	
	twa = get_parent().create_tween()
	
	trans.material["shader_parameter/time"] = 0.0 if not isTransIn else -5.0
	twa.tween_property(trans.material, "shader_parameter/time", 5.0 if not isTransIn else 0.0, 1.5 if not isTransIn else 0.75)
	
	twa.finished.connect(progress.bind())

func _process(_delta: float) -> void:
	if doDestroyEarly and isTransIn:
		get_parent().queue_free()
			
	if not isItReady:
		isItReady = true
		start()

extends Node2D

func _ready() -> void:
	ResourceLoader.load_threaded_request(TransFuncs.intendedScene)
	
func _process(_delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(TransFuncs.intendedScene, progress)

	if progress[0] == 1:
		var packed = ResourceLoader.load_threaded_get(TransFuncs.intendedScene)
		TransFuncs.switchScenes(self)
		
		get_tree().change_scene_to_packed(packed)

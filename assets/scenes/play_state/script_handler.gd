extends Node

const PATH_SCRIPTS = "res://assets/scripts/levels/"

func _ready() -> void:
	if not DirAccess.open(PATH_SCRIPTS+PlayGlobals.levelID+"/"): return
	var scriptDirectory : Array = DirAccess.get_files_at(PATH_SCRIPTS+PlayGlobals.levelID+"/")
	
	if scriptDirectory.size() == 0: return
	else:
		scriptDirectory = scriptDirectory.filter(func(x:String): return x.ends_with(".gd"))
		
		for a in scriptDirectory:
			var casual = Node.new()
			var scripty = load(PATH_SCRIPTS+PlayGlobals.levelID+"/"+a)
			casual.set_script(scripty)
			self.add_child(casual)

func runFunction(ass, vars = []):
	for a in get_children():
		if a.has_method(ass): a.call(ass, vars)

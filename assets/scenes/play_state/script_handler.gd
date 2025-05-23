extends Node

const LEVEL_SCRIPTS = {
	"RCR": [
		preload("res://assets/scripts/levels/RCR/hieroglyphs.gd"),
		preload("res://assets/scripts/levels/RCR/sandman.gd"),
		preload("res://assets/scripts/levels/RCR/stand_ready_for_my_power.gd")
	],
	"SNH": [
		preload("res://assets/scripts/levels/SNH/bossPhase.gd")
	]
}

func _ready() -> void:
	var scripts = LEVEL_SCRIPTS.get(PlayGlobals.levelID, [])
	for script in scripts:
		var node = Node.new()
		node.set_script(script)
		add_child(node)

func runFunction(ass, vars = []):
	for a in get_children():
		if a.has_method(ass): a.call(ass, vars)

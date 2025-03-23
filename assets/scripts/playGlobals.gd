extends Node

var levelID = "SHR"
var levelDefs;

var transState = preload("res://assets/scenes/[SUB-SCENES]/transition/transition.tscn")

func transition(parent, intendedState = "reset", destroyEarly = false):
	var ass = transState.instantiate()
	parent.add_sibling(ass)
	
	var shit = ass.get_child(0)
	
	shit.doDestroyEarly = destroyEarly
	shit.state = intendedState

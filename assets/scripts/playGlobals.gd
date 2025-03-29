extends Node

var levelID = "SHR"
var levelDefs;

#DIFFICULTY STUFF
var difficulty = 2

var diffMod = {
	0: [0.3, true, true, [10,3], 0.5, 10, 1.5, true],
	1: [0.6, true, false, [5,3], 0.75, 10, 1.25, true],
	2: [1.0, true, false, [3,3], 1, 10, 1, true],
	3: [2.0, false, false, [1,3], 1, 5, 0.5, true],
	4: [4.0, false, false, [1,1], 1, 1, 0.0, false]
}

var bulletPower = 1
var canBarrelRoll = true
var canBarrelShoot = true
var lifeCount = [3,3]
var bulletCooldown = 1
var maxLiraLevel = 10
var LiraGainSpeed = 1
var doColelctibles = true

func applyDifficulty():
	var diffy = diffMod[difficulty]
	
	bulletPower = diffy[0]
	canBarrelRoll = diffy[1]
	canBarrelShoot = diffy[2]
	lifeCount = diffy[3]
	bulletCooldown = diffy[4]
	maxLiraLevel = diffy[5]
	LiraGainSpeed = diffy[6]
	doColelctibles = diffy[7]

#TRANSITION
var transState = preload("res://assets/scenes/[SUB-SCENES]/transition/transition.tscn")

func transition(parent, intendedState = "reset", destroyEarly = false):
	var ass = transState.instantiate()
	parent.add_sibling(ass)
	
	var shit = ass.get_child(0)
	
	shit.doDestroyEarly = destroyEarly
	shit.state = intendedState

#SUBSTATE SHIT
var substates = []
func addSubstate(parent, child):
	parent.add_sibling(child)
	substates.push_back(child)
	
func removeSubstate(sub):
	var ind = substates.find(sub)
	if ind != -1:
		substates[ind].queue_free()
		substates.remove_at(ind)
		
func removeAllSubstates():
	for a in substates:
		a.queue_free()
	substates = []

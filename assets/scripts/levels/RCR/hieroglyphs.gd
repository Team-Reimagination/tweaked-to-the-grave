extends Node

@onready var scene = get_parent().get_parent()
@onready var hiero = load("res://assets/objects/spawners/RCR/RCR_Hieroglyphs.tscn").instantiate()

var goString = "eydoo"
var goIndex = 0

var waitTime = 0.5
var started = false

func onDialogue(vars):
	if vars[0] == 6:
		started = true
		start()

func start():
	await get_tree().create_timer(waitTime, false).timeout
	spawnHiero()

func spawnHiero():
	var chara = goString.substr(goIndex, 1)
	var childish = hiero.find_child(chara)
	
	if childish != null:
		var chil = childish.duplicate()
		scene.spawnOBJ(chil)
		
		chil.visible = true
		chil.global_position.z = -20
		
		if chara == 'e':
			chil.global_position.x = randf_range(10, 15);
			chil.global_position.y = scene.player.global_position.y
		elif chara == 'y':
			chil.global_position.x = 0.0;
			chil.global_position.y = 20
		elif chara == 'd':
			chil.global_position.x = 20;
			chil.global_position.y = randf_range(5, 15)
		if chara == 'o':
			chil.global_position.y = randf_range(15, 20);
			chil.global_position.x = scene.player.global_position.x
	
	waitTime = randf_range(4.0,6.0)
	goIndex += 1
	if goIndex >= len(goString): goIndex = 0
	
	if !scene.hasBitchWon and scene.canInput:
		start()

func onBossDefeat(_vars):
	queue_free()

func onGameOver(_vars):
	queue_free()

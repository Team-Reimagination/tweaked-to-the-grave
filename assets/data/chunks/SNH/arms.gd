extends Node3D

@export var warningTime = 1.0
signal attack_complete

var stop = false
var tg;

func _ready() -> void:
	$AttackTimer.start()
	
	await get_tree().create_timer(warningTime if $Warning else 0.0, false).timeout
	stop = true
	
	for a in $Attack.get_children():
		var wasDisabled = a.disabled
		
		if wasDisabled: 
			a.disabled = false
			if a.has_method("movemental"): a.movemental()
			if a.has_method("spawnLogic"): a.spawnLogic()

func _process(delta: float) -> void:
	if $AttackTimer.time_left <= 0.001:
		attack_complete.emit()
		queue_free()
		
	if tg != null and !stop:
		global_position.y = tg.global_position.y

func followY(target): tg = target

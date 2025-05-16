extends Node3D

@export var warningTime = 1.0
signal attack_complete

func _ready() -> void:
	$AttackTimer.start()
	
	await get_tree().create_timer(warningTime if $Warning else 0.0, false).timeout
	for a in $Attack.get_children():
		a.disabled = false

func _process(delta: float) -> void:
	if $AttackTimer.time_left <= 0.001:
		attack_complete.emit()
		queue_free()

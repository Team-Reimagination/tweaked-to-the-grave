class_name TTTG_Obstacle
extends TTTG_Entity

@export var canDie = true
@export var camBeHit = true
@export var health = 0;

func _process(delta: float) -> void:
	super._process(delta)

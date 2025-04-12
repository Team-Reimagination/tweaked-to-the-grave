class_name TTTG_Entity
extends CharacterBody3D

@onready var model = $Model;
@onready var hitbox = $Hitbox;

func _process(_delta: float) -> void:
	if self.position.z > 0:
		self.queue_free()

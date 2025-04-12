class_name TTTG_Entity
extends Area3D

@onready var scene = get_parent().get_parent()
@onready var model = $Model;
@onready var hitbox = $Hitbox;
@export var type = "";

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if self.position.z > 0:
		self.queue_free()

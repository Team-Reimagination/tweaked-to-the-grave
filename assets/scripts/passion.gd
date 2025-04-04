extends Node

var passi = load("res://assets/scenes/[SUB-SCENES]/passionate/passionate.tscn")
var alla

func _ready() -> void:
	alla = passi.instantiate()
	add_child(alla)
	
func visibility(value):
	alla.get_child(0).visible = value;

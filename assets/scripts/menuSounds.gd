extends Node

@onready var switch = AudioStreamPlayer.new()
@onready var select = AudioStreamPlayer.new()
@onready var small_select = AudioStreamPlayer.new()

func _ready() -> void:
	for a in ["switch", "select", "small_select"]:
		var b = get(a)
		add_child(b)
		b.stream = load("res://assets/sounds/ui/"+a+".ogg")
		b.max_polyphony = 10;
		b.bus = 'SFX';

func playMenuSound(type):
	var ty = get(type)
	if ty != null: ty.play()
	else: print("..."+type+" does not exist.")

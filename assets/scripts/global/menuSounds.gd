extends Node

@onready var switch = AudioSubtitlableGeneral.new()
@onready var select = AudioSubtitlableGeneral.new()
@onready var small_select = AudioSubtitlableGeneral.new()
@onready var slider_tick = AudioSubtitlableGeneral.new()
@onready var error = AudioSubtitlableGeneral.new()

var list = ["switch", "select", "small_select", "slider_tick", "error"]
var menuSubtitles = {
	"switch": "Switch Selection",
	"select": "Make Selection",
	"small_select": "Make Selection",
	"slider_tick": "Slider Tick",
	"error": "Error"
}

func _ready() -> void:
	for a in list:
		var b = get(a)
		add_child(b)
		b.add_to_group('Sound')
		b.stream = load("res://assets/sounds/ui/"+a+".ogg")
		b.max_polyphony = 1;
		b.bus = 'SFX';
		b.subtitle = menuSubtitles[a]

func playMenuSound(type, onlyIfNotPlaying = false):
	var ty = get(type)
	if ty != null: 
		if (not onlyIfNotPlaying or (onlyIfNotPlaying and not ty.playing)): ty.subtitle_play()
	else: print("..."+type+" does not exist.")
	
func stopMenuSound(type):
	var ty = get(type)
	if ty != null: ty.stop()
	else: print("..."+type+" does not exist.")
	
func bequietmylittlechud():
	for a in list: get(a).stop()

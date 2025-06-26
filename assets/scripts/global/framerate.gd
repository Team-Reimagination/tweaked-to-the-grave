extends CanvasLayer

var framerate: Label = Label.new()

func _ready() -> void:
	self.layer = 128
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	framerate.top_level = true
	framerate.label_settings = LabelSettings.new()
	framerate.label_settings.font = load("res://assets/fonts/CrookedLogs-Normal.ttf")
	framerate.label_settings.font_size = 16
	
	framerate.position = Vector2(10, 10)
	
	add_child(framerate)
	
func _process(_delta: float) -> void:
	var fps_count = Performance.get_monitor(Performance.TIME_FPS)
	framerate.text = str(fps_count) + " FPS"

extends Node
var pickItUp = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	var bus_index = AudioServer.get_bus_index("Dialogue")
	var peak_volume = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
	
	pickItUp = lerpf(pickItUp, 0.0 if peak_volume < -100 else -SaveSystem.optionsData.get("audio_dialogueattenuation", 10), 0.2)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Dialogue Attenuation"), pickItUp)

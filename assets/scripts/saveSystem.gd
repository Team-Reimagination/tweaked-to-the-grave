extends Node

const SETTING_FILE_PATH = "user://settings.ini"
var settings = ConfigFile.new()

func makeSave() -> void:
	##PC ONLY
	if not OS.has_feature("web"):
		settings.set_value("video", "resolution", Vector2(1280, 960))
		settings.set_value("video", "fullscreen", false)
		
	#ALL DEVICES
	settings.set_value("volume", "master", 1.0)
	settings.set_value("volume", "music", 1.0)
	settings.set_value("volume", "sfx", 1.0)
	settings.set_value("volume", "ambience", 1.0)
	
	settings.set_value("gameplay", "autofire", false)
	
	settings.save(SETTING_FILE_PATH)

func applyImmediateSettings() -> void:
	for sec in settings.get_sections():
		for nam in settings.get_section_keys(sec):
			applySetting(nam, settings.get_value(sec, nam))

func applySetting(type, valuemysanityplease): #this shit has no switch cases :sob:
	if type == 'resolution':
		if not OS.has_feature("web"): DisplayServer.window_set_size(valuemysanityplease)
	elif type == 'fullscreen':
		if not OS.has_feature("web"): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if valuemysanityplease else DisplayServer.WINDOW_MODE_WINDOWED)
	
	elif type == 'master':
		AudioServer.set_bus_volume_db(0, linear_to_db(valuemysanityplease))
	elif type == 'music':
		AudioServer.set_bus_volume_db(1, linear_to_db(valuemysanityplease))
	elif type == 'sfx':
		AudioServer.set_bus_volume_db(2, linear_to_db(valuemysanityplease))
	elif type == 'ambience':
		AudioServer.set_bus_volume_db(3, linear_to_db(valuemysanityplease))

func resetSave() -> void:
	makeSave()
	applyImmediateSettings()

func _ready() -> void:
	var _error := settings.load(SETTING_FILE_PATH)
	
	#if error != OK:
	makeSave()
		
	applyImmediateSettings()

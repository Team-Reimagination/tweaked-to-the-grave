extends Control

var scaleFactor = Vector2(0.0,0.0)
@onready var scaleLerp = $Base.scaleLerp 

var canInput = true

func scalemyfuck():
	scaleFactor = $Base/Background.size / $ScaleRef.size
	$Inside.scale = scaleFactor

func _ready() -> void:
	scalemyfuck()
	$Inside/TextureButton.connect("pressed", func(): SaveSystem.nukeSave())
	for i in $Inside.get_children():
		if (i is not Node): return
		
		var settingNode = i.get_node("./Setting")
		if (settingNode is HSlider):
			settingNode.connect("value_changed", func(value): onvaluechange(i.get_name(), value));
			settingNode.set_value_no_signal(SaveSystem.optionsData.get(i.get_name(), 0));
		if (settingNode is ItemList):
			settingNode.select(SaveSystem.optionsData.get(i.get_name(), 0))
			settingNode.connect("item_selected", func(index): onvaluechange(i.get_name(), index));
		if (settingNode is TextureButton):
			settingNode.connect("toggled", func(value): onvaluechange(i.get_name(), value));
			settingNode.set_pressed_no_signal(SaveSystem.optionsData.get(i.get_name(), false));
	
func _process(_delta: float) -> void:
	scalemyfuck()
	
	if canInput:
		if (Input.is_action_just_pressed("Back_UI") or CustomCursor.isMouseJustPressed("right")):
			canInput = false;
			$ScaleRef.size = Vector2(0.0,0.0)
			get_tree().create_tween().tween_property($Base/Background, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)
		
			get_meta("parent").canInput = true
		
	if not canInput and $Base/Background.scale <= Vector2(0.05, 0.05):
		PlayGlobals.removeSubstate(self);

func onvaluechange(setting:String, value):
	var realLifeValue = SaveSystem.optionsData.set(setting, value)
	SaveSystem.applySetting(setting, value)
	
	get_meta('parent').applySetting(setting, value)

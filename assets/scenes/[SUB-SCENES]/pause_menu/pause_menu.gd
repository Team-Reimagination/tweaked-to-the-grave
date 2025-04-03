extends Control

var scaleFactor = Vector2(0.0,0.0)

@onready var scaleLerp = $Base.scaleLerp 
@onready var optionSliders = [$Inside/QuickOptions/Master, $Inside/QuickOptions/Music, $Inside/QuickOptions/SFX, $Inside/QuickOptions/Ambience]
@onready var optionCheckbox = $Inside/QuickOptions/Autofire
@onready var buttons = [$Inside/Buttons/Resume, $Inside/Buttons/Restart, $Inside/Buttons/Quit]

var buttonScales = [0.0,0.0,0.0]
var selectedButton = 0;
var selectedRow = 0;

var canInput = true

func scalemyfuck():
	scaleFactor = $Base/Background.size / $ScaleRef.size
	$Inside.scale = scaleFactor

func _ready() -> void:
	scalemyfuck()
	
	updateButtonSelection()
	instantScale()

	for butt in buttons:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())
	
	prepareOptions()
	
func instantScale():
	for i in range(buttons.size()):
		buttons[i].scale.x = buttonScales[i]
		buttons[i].scale.y = buttons[i].scale.x

func setting_change(value, obj):
	SaveSystem.settings.set_value(obj.optionCategory, obj.optionValue, value)
	SaveSystem.applySetting(obj.optionValue, value)
	get_meta('parent').applySetting(obj.optionValue, value)
	
func prepareOptions():
	for ob in optionSliders:
		ob.value = SaveSystem.settings.get_value(ob.optionCategory, ob.optionValue)
		ob.value_changed.connect(setting_change.bind(ob))
	
	optionCheckbox.set_pressed(SaveSystem.settings.get_value(optionCheckbox.optionCategory, optionCheckbox.optionValue))
	optionCheckbox.toggled.connect(setting_change.bind(optionCheckbox))
		
func greyButtons():
	for i in range(buttons.size()):
		buttons[i].self_modulate = Color(0.4,0.4,0.4)
		buttonScales[i] = 0.9;

func updateScale():
	buttonScales[selectedButton] = 1.0

func updateButtonSelection():
	greyButtons()
	buttons[selectedButton].self_modulate = Color(1.0,1.0,1.0)
	buttonScales[selectedButton] = 1.0
	
func _process(_delta: float) -> void:
	scalemyfuck()
	
	for i in range(buttons.size()):
		buttons[i].scale.x = lerp(buttons[i].scale.x, buttonScales[i], 0.3)
		buttons[i].scale.y = buttons[i].scale.x
	
	if canInput:
		if Input.is_action_just_pressed("Back_UI"): leave(true)
		
	if not canInput and $Base/Background.scale <= Vector2(0.05, 0.05):
		PlayGlobals.removeSubstate(self);

func mouse_button(button):
	if canInput:
		if selectedButton != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		selectedButton = button.get_meta("ID", 0)
		updateButtonSelection()
		updateScale()

func process_button():
	if canInput:
		leave(selectedButton != 2)
		
		if selectedButton == 1:
			PlayGlobals.youarenolongermyfriendsoundnowgoaway()
			TransFuncs.switchScenes(get_meta("parent"), "reset", false, false)
		elif selectedButton == 2:
			MenuSounds.playMenuSound('select')
			TransFuncs.switchScenes(get_meta("parent"), "res://assets/scenes/main_menu/main_menu.tscn", true, true, true)

func leave(doLeave):
	canInput = false;
	$ScaleRef.size = Vector2(0.0,0.0)
	get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property($Base/Background, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)
		
	if doLeave: PlayGlobals.subCallings(self, "wellithinkitstimetomoveonok")

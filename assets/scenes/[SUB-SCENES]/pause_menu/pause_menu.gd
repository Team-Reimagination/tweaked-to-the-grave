extends Control

var scaleFactor = Vector2(0.0,0.0)

@onready var scaleLerp = $Base.scaleLerp 
@onready var optionSliders = [$Inside/QuickOptions/Master, $Inside/QuickOptions/SFX, $Inside/QuickOptions/Music, $Inside/QuickOptions/Voice, $Inside/QuickOptions/Ambience]
@onready var optionCheckbox = $Inside/QuickOptions/Autofire
@onready var buttons = [$Inside/Buttons/Resume, $Inside/Buttons/Restart, $Inside/Buttons/Quit]

@onready var boxer = $Inside/QuickColor

var buttonScales = [0.0,0.0,0.0]
var selectedButton = 0;
var selectedRow = 0;

var boxPositions = Vector2(0.0,0.0)
var boxSizes = Vector2(0.0,0.0)
var boxAlpha = 0.0

var canInput = true
var isSliding = false

func scalemyfuck():
	scaleFactor = $Base/Background.size / $ScaleRef.size
	$Inside.scale = scaleFactor

func _ready() -> void:
	scalemyfuck()
	
	updateButtonSelection()
	instantScale()
	
	boxerMove()
	instantBoxMove()

	for butt in buttons:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())
	
	prepareOptions()
	
func instantScale():
	for i in range(buttons.size()):
		buttons[i].scale.x = buttonScales[i]
		buttons[i].scale.y = buttons[i].scale.x

func boxerMove():
	var whatToUse = $Inside/QuickOptions/Autofire/Rectangle
	if selectedButton == 4: whatToUse = $Inside/QuickOptions/Master/Rectangle if selectedRow == 0 else $Inside/QuickOptions/SFX/Rectangle
	elif selectedButton == 5: whatToUse = $Inside/QuickOptions/Music/Rectangle if selectedRow == 0 else $Inside/QuickOptions/Voice/Rectangle
	elif selectedButton == 8: whatToUse = $Inside/QuickOptions/Ambience/Rectangle
	
	boxSizes = whatToUse.size
	boxPositions = whatToUse.global_position

func instantBoxMove():
		boxer.size = boxSizes
		boxer.position = boxPositions
		boxer.self_modulate.a = boxAlpha

func setting_change(value, obj):
	SaveSystem.optionsData.set(obj.optionValue, value)
	SaveSystem.applySetting(obj.optionValue, value)

	get_meta('parent').applySetting(obj.optionValue, value)
	
func prepareOptions():
	for ob in optionSliders:
		ob.value = SaveSystem.optionsData.get(ob.optionValue)
		ob.value_changed.connect(tickSound.bind(ob))
		ob.mouse_entered.connect(mouse_button.bind(ob))
	
	optionCheckbox.set_pressed(SaveSystem.optionsData.get(optionCheckbox.optionValue));
	optionCheckbox.toggled.connect(checkboxMovement.bind(optionCheckbox))
	optionCheckbox.mouse_entered.connect(mouse_button.bind(optionCheckbox))

var checkTween
func checkboxMovement(value, obj):
	MenuSounds.playMenuSound('small_select')
	obj.scale = Vector2(0.8,0.8);
	
	setting_change(value, obj)
	
	if checkTween: checkTween.kill()
	checkTween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	checkTween.tween_property(obj, "scale", Vector2(1.0,1.0), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
func tickSound(value, obj):
	MenuSounds.playMenuSound('slider_tick', true)
	setting_change(value, obj)
		
func greyButtons():
	for i in range(buttons.size()):
		buttons[i].self_modulate = Color(0.4,0.4,0.4)
		buttonScales[i] = 0.9;

func updateScale():
	if selectedButton < 3: buttonScales[selectedButton] = 1.0

func updateButtonSelection():
	greyButtons()
	if selectedButton < 3:
		buttons[selectedButton].self_modulate = Color(1.0,1.0,1.0)
		buttonScales[selectedButton] = 1.0
		boxAlpha = 0.0
	else:
		boxAlpha = 1.0
		boxerMove()
	
var holdTimer = 0.0;
	
func _process(delta: float) -> void:
	scalemyfuck()
	
	boxer.self_modulate.a = lerp(boxer.self_modulate.a, boxAlpha, 0.3)
	boxer.position.x = lerp(boxer.position.x, boxPositions.x, 0.3)
	boxer.position.y = lerp(boxer.position.y, boxPositions.y, 0.3)
	boxer.size.x = lerp(boxer.size.x, boxSizes.x, 0.3)
	boxer.size.y = lerp(boxer.size.y, boxSizes.y, 0.3)
	
	for i in range(buttons.size()):
		buttons[i].scale.x = lerp(buttons[i].scale.x, buttonScales[i], 0.3)
		buttons[i].scale.y = buttons[i].scale.x
		
	if isSliding:
		if Input.is_action_pressed("Left_UI") or Input.is_action_pressed("Right_UI"):
			holdTimer += delta
		else:
			holdTimer = 0.0
			
		var slidery = ((0 if selectedButton == 4 else 2) + selectedRow) if selectedButton < 6 else selectedButton-2
			
		if (Input.is_action_pressed("Left_UI") and holdTimer > 0.6) or Input.is_action_just_pressed("Left_UI"):
			optionSliders[slidery].value -= 0.01 * (10 if Input.is_action_pressed("Extra_UI") else 1)
		elif (Input.is_action_pressed("Right_UI") and holdTimer > 0.6) or Input.is_action_just_pressed("Right_UI"):
			optionSliders[slidery].value += 0.01 * (10 if Input.is_action_pressed("Extra_UI") else 1)
		
		if Input.is_action_just_pressed("Back_UI") or Input.is_action_just_pressed("Accept_UI"):
			isSliding = false
			canInput = true
			SaveSystem.saveSave()
			
			optionCheckbox.disabled = false
			for a in optionSliders:
				a.editable = true
			
			MenuSounds.playMenuSound('small_select')
			return
	
	if canInput:
		if Input.is_action_just_pressed("Back_UI"): leave(true)
		
		if Input.is_action_just_pressed("Up_UI"): 
			selectedButton = (selectedButton - 1) % 7
			if selectedButton < 0: selectedButton = 6
			updateButtonSelection()
			MenuSounds.playMenuSound('switch')
		elif Input.is_action_just_pressed("Down_UI"):
			selectedButton = (selectedButton + 1) % 7
			updateButtonSelection()
			MenuSounds.playMenuSound('switch')
			
		if selectedButton in [4,5] and (Input.is_action_just_pressed("Left_UI") or Input.is_action_just_pressed("Right_UI")):
			selectedRow = (selectedRow + 1) % 2
			updateButtonSelection()
			MenuSounds.playMenuSound('switch')
		
		if Input.is_action_just_pressed("Accept_UI"):
			process_button()
		
	if not canInput and $Base/Background.scale <= Vector2(0.05, 0.05):
		PlayGlobals.removeSubstate(self);

func mouse_button(button):
	if canInput:
		if selectedButton != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		selectedButton = button.get_meta("ID", 0)
		
		if selectedButton == 4: selectedButton = 4; selectedRow = 0
		if selectedButton == 5: selectedButton = 4; selectedRow = 1
		if selectedButton == 6: selectedButton = 5; selectedRow = 0
		if selectedButton == 7: selectedButton = 5; selectedRow = 1
		updateButtonSelection()
		updateScale()

func process_button():
	if canInput:
		if selectedButton < 3: 
			leave(selectedButton == 0)
			SaveSystem.saveSave()
		
			if selectedButton == 1:
				PlayGlobals.youarenolongermyfriendsoundnowgoaway()
				MenuSounds.playMenuSound('select')
				TransFuncs.switchScenes(get_meta("parent"), "reset", true, true, true)
			elif selectedButton == 2:
				PlayGlobals.youarenolongermyfriendsoundnowgoaway()
				MenuSounds.playMenuSound('select')
				TransFuncs.switchScenes(get_meta("parent"), "res://assets/scenes/main_menu/main_menu.tscn", true, true, true)
		elif selectedButton == 3:
			optionCheckbox.button_pressed = false if optionCheckbox.button_pressed else true
			checkboxMovement(optionCheckbox.button_pressed, optionCheckbox)
		else:
			MenuSounds.playMenuSound('small_select')
			
			optionCheckbox.disabled = true
			for a in optionSliders:
				a.editable = false
			optionSliders[(0 if selectedButton == 4 else 2) + selectedRow].editable = true
			
			canInput = false
			isSliding = true

func leave(doLeave):
	canInput = false;
	$ScaleRef.size = Vector2(0.0,0.0)
	get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property($Base/Background, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)
		
	if doLeave: PlayGlobals.subCallings(self, "wellithinkitstimetomoveonok")

extends Control

var substate
@onready var parenter = get_parent().get_parent().get_parent()
var optionToLookInto
var category
var selection
var definition

var scalar
var holdTimer = 0.0

var selTween
var selectorSetting = 0
@onready var selectorButtons = [$"Tech/2/Left", $"Tech/2/Right"]

func _ready() -> void:
	definition = SaveSystem.optionDefines[optionToLookInto]
	
	$Label.text = definition.name

	var toRemove = $Tech.get_children().filter(func(x): return int(x.name) != definition.type)
	for a in toRemove: a.queue_free()

	setupSetting()
	getSetting()
	
func getSetting():
	if definition.type == 1:
		var a = $"Tech/1/Setting"
		a.set_pressed_no_signal(SaveSystem.optionsData.get(optionToLookInto, false));
	elif definition.type == 0:
		var a = $"Tech/0/Setting"
		a.set_value_no_signal(SaveSystem.optionsData.get(optionToLookInto, 0));
		sliderValue()
	elif definition.type == 2:
		selectorSetting = SaveSystem.optionsData.get(optionToLookInto, 0)
		selectorValue()

func selectorValue():
	$"Tech/2/Number".text = definition.options[selectorSetting]

func sliderValue():
	if definition.label == 'percent':
		$"Tech/0/Number".text = str(int($"Tech/0/Setting".value * 100))+'%'
	elif definition.label == 'float':
		$"Tech/0/Number".text = "%0.2f" % (floor($"Tech/0/Setting".value*100)/100)

func setupSetting():
	if definition.type == 1:
		scalar = [1.0]
		var a : TextureButton = $"Tech/1/Setting"
		a.connect("toggled", func(value): 
			MenuSounds.playMenuSound("small_select")
			if !SaveSystem.optionsData.get("video_reducedmotions", false): a.scale *= 0.7
			onvaluechange(optionToLookInto, value));
		a.mouse_entered.connect(scalerue.bind(a))
		a.mouse_exited.connect(unscalerue.bind(a))
	elif definition.type == 0:
		var a : HSlider = $"Tech/0/Setting"
		a.connect("value_changed", func(value): onvaluechange(optionToLookInto, value));
		a.mouse_entered.connect(_on_size_mouse_entered.bind())
		a.value_changed.connect(tickSound.bind(a))
		a.min_value = definition.min
		a.max_value = definition.max
		a.step = definition.step
	elif definition.type == 2:
		scalar = [0.7, 0.7]
		for a in selectorButtons:
			a.mouse_entered.connect(scalerue_selector.bind(a))
			a.mouse_exited.connect(unscalerue_selector.bind(a))
			a.pressed.connect(mouse_button.bind(a))

func tickSound(value, _obj):
	MenuSounds.playMenuSound('slider_tick', true)
	sliderValue()


func scalerue_selector(b):
	if substate.canInput:
		_on_size_mouse_entered()
		scalar[0 if b == $"Tech/2/Left" else 1] = 0.9 if !SaveSystem.optionsData.get("video_reducedmotions", false) else 0.7
		
		selectorButtons[0 if b == $"Tech/2/Left" else 1].modulate = Color(1.0,1.0,1.0)
		selectorButtons[1 if b == $"Tech/2/Left" else 0].modulate = Color(0.4,0.4,0.4)

func unscalerue_selector(b):
	if substate.canInput:
		b.modulate = Color(1.0,1.0,1.0)
		
		for a in scalar.size():
			scalar[a] = 0.7
			selectorButtons[a].modulate = Color(1.0,1.0,1.0)

func scalerue(b):
	if substate.canInput:
		_on_size_mouse_entered()
		scalar[0] = 1.3 if !SaveSystem.optionsData.get("video_reducedmotions", false) else 1.0

func unscalerue(b):
	if substate.canInput:
		scalar[0] = 1.0
	
func areWeEvenSelected(): return selection == parenter.curSelected and category == parenter.curCategory

func _process(delta):
	if !substate.canInput: return;
	
	if definition.type == 1:
		$"Tech/1/Setting".scale.x = lerpf($"Tech/1/Setting".scale.x, scalar[0], 0.3)
		$"Tech/1/Setting".scale.y = $"Tech/1/Setting".scale.x
		
		if Input.is_action_just_pressed("Accept_UI") and areWeEvenSelected():
			$"Tech/1/Setting".set_pressed(!$"Tech/1/Setting".button_pressed)
	elif definition.type == 0:
		if areWeEvenSelected():
			if Input.is_action_pressed("Left_UI") or Input.is_action_pressed("Right_UI"):
				holdTimer += delta
			else:
				holdTimer = 0.0
			
			if (Input.is_action_pressed("Left_UI") and holdTimer > 0.6) or Input.is_action_just_pressed("Left_UI"):
				$"Tech/0/Setting".value -= definition.step * (definition.get("speed", 2) if Input.is_action_pressed("Extra_UI") else 1)
			elif (Input.is_action_pressed("Right_UI") and holdTimer > 0.6) or Input.is_action_just_pressed("Right_UI"):
				$"Tech/0/Setting".value += definition.step * (definition.get("speed", 2) if Input.is_action_pressed("Extra_UI") else 1)
	elif definition.type == 2:
		for a in selectorButtons.size():
			selectorButtons[a].scale.x = lerpf(selectorButtons[a].scale.x, scalar[a], 0.3)
			selectorButtons[a].scale.y = selectorButtons[a].scale.x
		
		if areWeEvenSelected():
			if Input.is_action_just_pressed("Left_UI") or Input.is_action_just_pressed("Right_UI"):
				selectorMovement(-1 if Input.is_action_just_pressed("Left_UI") else 1)

func mouse_button(button):
	if substate.canInput:
		selectorMovement(-1 if button == $"Tech/2/Left" else 1)

func selectorMovement(dir):
	selectorSetting += dir
	
	if selectorSetting < 0: selectorSetting = definition.options.size()-1
	elif selectorSetting >= definition.options.size(): selectorSetting = 0
	
	MenuSounds.playMenuSound("small_select")
	onvaluechange(optionToLookInto, selectorSetting);
	
	if !SaveSystem.optionsData.get("video_reducedmotions", false): selectorButtons[0 if dir == -1 else 1].scale *= 0.7
	
	var recordPosition = $"Tech/2/Number".position.x
	
	if selTween: selTween.kill()
	selTween = get_tree().create_tween()
		
	selTween.tween_property($"Tech/2/Number", "modulate:a", 0.0, 0.125).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	if !SaveSystem.optionsData.get("video_reducedmotions", false):
		selTween.parallel().tween_property($"Tech/2/Number", "position:x", recordPosition - 25 * dir, 0.125).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	
	await selTween.finished
	
	selectorValue()
	
	selTween = get_tree().create_tween()
	selTween.tween_property($"Tech/2/Number", "modulate:a", 1.0, 0.125).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	if !SaveSystem.optionsData.get("video_reducedmotions", false):
		$"Tech/2/Number".position.x = recordPosition + 25 * dir
		selTween.parallel().tween_property($"Tech/2/Number", "position:x", recordPosition, 0.125).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		

func onvaluechange(setting:String, value):
	var realLifeValue = SaveSystem.optionsData.set(setting, value)
	
	SaveSystem.applySetting(setting, value)
	SaveSystem.saveSave()
	
	substate.onvaluechange(setting, value)

func _on_size_mouse_entered() -> void:
	if substate.canInput:
		parenter.mouseBtn = -1
		parenter.updateCatButtonSelection()
				
		if parenter.curSelected != selection:
			parenter.curSelected = selection
			parenter.boxAlpha = 1.0
					
			MenuSounds.playMenuSound("switch")

extends Control

var substate
@onready var parenter = get_parent().get_parent().get_parent()
var category = 0
var selection = 0

var scalar = 1.0

func _ready() -> void:
	var toRemove = $Buttons.get_children().filter(func(x): return x.get_meta("ID", 0) != selection)
	for a in toRemove: a.queue_free()
	
	for a in $Buttons.get_children():
		a.mouse_entered.connect(scalerue.bind(a))
		a.mouse_exited.connect(unscalerue.bind(a))
		a.pressed.connect(mouse_button.bind(a))

func scalerue(b):
	if substate.canInput:
		_on_size_mouse_entered()
		scalar = 1.3 if !SaveSystem.optionsData.get("video_reducedmotions", false) else 1.0

func unscalerue(b):
	if substate.canInput: scalar = 1.0
	
func areWeEvenSelected(): return selection == parenter.curSelected and category == parenter.curCategory

func _process(delta):
	$Buttons.get_child(0).scale.x = lerpf($Buttons.get_child(0).scale.x, scalar, 0.3)
	$Buttons.get_child(0).scale.y = $Buttons.get_child(0).scale.x
	
	if !substate.canInput: return;
	
	if Input.is_action_just_pressed("Accept_UI") and areWeEvenSelected():
		askAway()

func askAway():
	substate.canInput = false
	
	var askAwayState = load("res://assets/scenes/[SUB-SCENES]/question_menu/question_menu.tscn").instantiate()
	PlayGlobals.addSubstate(self, askAwayState)

func mouse_button(button):
	if substate.canInput:
		askAway()

func _on_size_mouse_entered() -> void:
	if substate.canInput:
		parenter.mouseBtn = -1
		parenter.updateCatButtonSelection()
				
		if parenter.curSelected != selection:
			parenter.curSelected = selection
			parenter.boxAlpha = 1.0
					
			MenuSounds.playMenuSound("switch")

func confirmNew():
	MenuSounds.playMenuSound("select")
	
	if selection == 1:
		myBeautifulOptionsAreGone()
	elif selection == 2:
		SaveSystem.resetAchievements()
	elif selection == 3:
		SaveSystem.resetSaves()
	elif selection == 4:
		myBeautifulOptionsAreGone()
		SaveSystem.resetAchievements()
		SaveSystem.resetSaves()
		
	scalar = 1.0
	if !SaveSystem.optionsData.get("video_reducedmotions", false): $Buttons.get_child(0).scale *= 0.7;
	
	substate.canInput = true

func myBeautifulOptionsAreGone():
	SaveSystem.resetOptions()
	for opt in get_parent().get_parent().get_children():
		for op in opt.get_children():
			if op.has_method("getSetting"): op.getSetting()

func noToTheNew():
	substate.canInput = true
	scalar = 1.0

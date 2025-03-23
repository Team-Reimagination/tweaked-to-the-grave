extends Control

@onready var buttons = [$"New Tries", $Return]

var buttonScales = [0.0,0.0]
var selectedButton = 0;

var canInput = false

func _ready() -> void:
	updateButtonSelection()
	instantScale()

	for butt in buttons:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())
	
func instantScale():
	for i in range(buttons.size()):
		buttons[i].scale.x = buttonScales[i]
		buttons[i].scale.y = buttons[i].scale.x

func greyButtons():
	for i in range(buttons.size()):
		buttons[i].self_modulate = Color(0.4,0.4,0.4)
		if canInput: buttonScales[i] = 0.9;

func updateScale():
	buttonScales[selectedButton] = 1.0

func updateButtonSelection():
	greyButtons()
	buttons[selectedButton].self_modulate = Color(1.0,1.0,1.0)
	
func _process(_delta: float) -> void:
	for i in range(buttons.size()):
		buttons[i].scale.x = lerp(buttons[i].scale.x, buttonScales[i], 0.3)
		buttons[i].scale.y = buttons[i].scale.x
			
	if canInput:
		if Input.is_action_just_pressed("Left_UI"): 
			selectedButton = (selectedButton - 1) % 2
			updateButtonSelection()
			updateScale()
			$Sounds/Switch.play()
		elif Input.is_action_just_pressed("Right_UI"):
			selectedButton = (selectedButton + 1) % 2
			updateButtonSelection()
			updateScale()
			$Sounds/Switch.play()
		
		if Input.is_action_just_pressed("Accept_UI"):
			$"../SoOver".stop()
			$"../Stroked".stop()

			process_button()

func mouse_button(button):
	if canInput:
		if selectedButton != button.get_meta("ID", 0): $Sounds/Switch.play()
		
		selectedButton = button.get_meta("ID", 0)
		updateButtonSelection()
		updateScale()

func process_button():
	if canInput:
		canInput = false
		$Sounds/Select.play()
		
		PlayGlobals.transition(self.get_parent().get_parent(), "reset" if selectedButton == 0 else "res://assets/scenes/main_menu/main_menu.tscn")

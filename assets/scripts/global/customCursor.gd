extends Node

# Load the custom images for the mouse cursor.
var arrow = load("res://assets/images/cursor/arrow.png")
var hand = load("res://assets/images/cursor/hand.png")

var justPressedMouse = []
var pressedMouse = []
var alreadyJustPressed = false

func _ready():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(arrow)

	# Changes a specific shape of the cursor (here, the I-beam shape).
	Input.set_custom_mouse_cursor(hand, Input.CURSOR_POINTING_HAND)

func _process(_delta: float) -> void:
	if true in justPressedMouse: 
		justPressedMouse = [false,false,false]
		alreadyJustPressed = true
	
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and !Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		pressedMouse = [false,false,false]
		justPressedMouse = [false,false,false]
		alreadyJustPressed = false
	else:
		pressedMouse = [Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT),Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE),Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)]
		if true in pressedMouse and !alreadyJustPressed: justPressedMouse = pressedMouse

func getButton(button):
	return 2 if button == "right" else (1 if button == "middle" else 0)

func isMousePressed(button):
	return pressedMouse[getButton(button)]

func isMouseJustPressed(button):
	var press = justPressedMouse[getButton(button)]
	return false if press == null else press

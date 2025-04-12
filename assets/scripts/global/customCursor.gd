extends Node

# Load the custom images for the mouse cursor.
var arrow = load("res://assets/images/cursor/arrow.png")
var hand = load("res://assets/images/cursor/hand.png")

func _ready():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(arrow)

	# Changes a specific shape of the cursor (here, the I-beam shape).
	Input.set_custom_mouse_cursor(hand, Input.CURSOR_POINTING_HAND)

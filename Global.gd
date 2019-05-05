extends Node

func _ready():
	hide_mouse()

func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

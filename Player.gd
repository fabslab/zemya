extends Node2D

var speed = 300
var velocity_x = 0
var velocity_y = 0
var controller_aim_distance = 150
var controller_aim_deadzone = 0.3
var mouse_sensitivity = 1
var mouse_movement = Vector2()
var camera_look_offset_distance = 40 

func _physics_process(delta):
	move_player()
	aim_player()

func move_player():
	var right_pressed = Input.is_action_pressed('right')
	var left_pressed = Input.is_action_pressed('left')
	var down_pressed = Input.is_action_pressed('down')
	var up_pressed = Input.is_action_pressed('up')
	
	if not (right_pressed && left_pressed && velocity_x != 0):
		if right_pressed:
			velocity_x = 1
		elif left_pressed:
			velocity_x = -1
		else:
			velocity_x = 0
			
	if not (down_pressed && up_pressed && velocity_y != 0):
		if down_pressed:
			velocity_y = 1
		elif up_pressed:
			velocity_y = -1
		else:
			velocity_y = 0

	if velocity_x != 0 or velocity_y != 0:
		var velocity = Vector2(velocity_x, velocity_y).normalized() * speed
		var prev_pos = $PlayerCharacter.position
		$PlayerCharacter.move_and_slide(velocity)
		var current_pos = $PlayerCharacter.position
		$Crosshairs.position += (current_pos - prev_pos)

func aim_player():
	var crosshairs_pos = $Crosshairs.position

	# Controller based aiming
	var look_x = Input.get_joy_axis(0, 2)
	var look_y = Input.get_joy_axis(0, 3)
	var look_direction = Vector2(look_x, look_y)
	if look_direction.length() >= controller_aim_deadzone:
		crosshairs_pos = $PlayerCharacter.position + controller_aim_distance * look_direction.normalized()

	# Mouse based aiming
	crosshairs_pos += mouse_movement * mouse_sensitivity
	mouse_movement = Vector2()
	
	var margin = 10
	var viewport_size = get_viewport().size
	var player_pos = $PlayerCharacter.position
	crosshairs_pos.x = clamp(crosshairs_pos.x, player_pos.x - viewport_size.x / 2 + margin, player_pos.x + viewport_size.x / 2 - margin)
	crosshairs_pos.y = clamp(crosshairs_pos.y, player_pos.y - viewport_size.y / 2 + margin, player_pos.y + viewport_size.y / 2 - margin)
	$Crosshairs.position = crosshairs_pos

	# Rotate character to look where aiming and offset camera to provide extra distance in aim direction
	var aim_direction = $Crosshairs.position - $PlayerCharacter.position
	$PlayerCharacter.rotation = aim_direction.angle()
	$Camera2D.position = $PlayerCharacter.position + aim_direction.normalized() * camera_look_offset_distance

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_movement += event.relative
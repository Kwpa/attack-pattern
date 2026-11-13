extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
@export var invert_y := false

var target_velocity = Vector3.ZERO


func _physics_process(delta):
	var direction = Vector3.ZERO

	var cam_rotation := Input.get_vector("cam_rotate_x_left", "cam_rotate_x_right", "cam_rotate_y_up", "cam_rotate_y_down")
	$outer_gimbal.rotate_object_local(Vector3.UP, cam_rotation.x * 1 * delta)
	cam_rotation = Vector2(cam_rotation.x, -cam_rotation.y) if invert_y else Vector2(cam_rotation.x, cam_rotation.y)
	$outer_gimbal/inner_gimbal.rotate_object_local(Vector3.RIGHT, cam_rotation.y * 1 * delta)

	var player_movement := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = Vector3(player_movement.x, 0, player_movement.y).rotated(Vector3.UP, $outer_gimbal.rotation.y)
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$pivot.basis = Basis.looking_at(direction)
		$anim_player.speed_scale = 4
	else:
		$anim_player.speed_scale = 1

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	$pivot.rotation.x = PI / 6 * velocity.y

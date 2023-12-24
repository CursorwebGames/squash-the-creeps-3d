extends CharacterBody3D
signal hit

# how fast player moves, m/s
@export var speed = 14

# downward accel when in air, m/s^2
@export var fall_accel = 75

# vertical impulse applied on jump (kgm/s)
@export var jump_impulse = 20

# vertical impulse applied on squash
@export var bounce_impulse = 16

var player_vel = Vector3.ZERO

func _physics_process(delta):
	var dir = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_back"):
		dir.z += 1
	if Input.is_action_pressed("move_forward"):
		dir.z -= 1
	
	# normalize to make more fair
	if dir != Vector3.ZERO:
		dir = dir.normalized()
		$Pivot.look_at(position + dir, Vector3.UP)
		
		# animate faster when player moving
		$AnimationPlayer.speed_scale = 2
	else:
		$AnimationPlayer.speed_scale = 1
		
	player_vel.x = dir.x * speed
	player_vel.z = dir.z * speed
	
	# Vertical player_vel
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		player_vel.y = player_vel.y - (fall_accel * delta)
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		player_vel.y = jump_impulse

	# Moving the Character
	velocity = player_vel
	move_and_slide()
	
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		
		# if no group (aka tag in unity)
		if collision.get_collider() == null:
			continue
			
		if (collision.get_collider() as Node).is_in_group("mob"):
			var mob = collision.get_collider()
			
			# check hitting from above (dot product in this case is the "sameness")
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				player_vel.y = bounce_impulse
				break
	
	# at start of jump, we are at vely = jump_impulse (1)
	# at top, we are at vely = 0 (0)
	# at bottom, we are at vely = -jump_impulse (-1)
	$Pivot.rotation.x = PI / 12 * (velocity.y / jump_impulse)


func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(_body):
	die()

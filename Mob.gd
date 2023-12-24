extends CharacterBody3D

# emitted when player jumps on mob
signal squashed

@export var min_speed = 10

@export var max_speed = 18

func init(start_pos: Vector3, player_pos: Vector3):
	# make mob look at player
	look_at_from_position(start_pos, player_pos)
	# then offset it a little
	rotate_y(randf_range(-PI / 4, PI / 4))
	
	# don't rotate the horizontal plane (be flat)
	rotation.x = 0
	rotation.z = 0
	
	var speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * speed
	
	$AnimationPlayer.speed_scale = speed as float / min_speed
	
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	

func _physics_process(delta):
	# choose your game mode!!
	#move_and_slide()
	move_and_collide(velocity * delta)


func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()

func squash():
	squashed.emit()
	queue_free()

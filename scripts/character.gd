extends CharacterBody3D

var speed

const walk_SPEED = 5.0
const run_SPEED = 8.0
const JUMP_VELOCITY = 4.5

const SENS = 0.003

#hb
const bob_freq = 2.0
const bob_amp = 0.08
var bob = 0.0

#fov
const FOV = 70
const FOV_c = 5.0

var is_dead = false
var HP = 100.0

var can_shoot = true

@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var raycast_3d = $Head/RayCast3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENS)
		camera.rotate_x(-event.relative.y * SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if is_dead:
		#TODO: remove this shit after making deathscreen
		queue_free()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("SPACE") and is_on_floor():
		velocity.y = JUMP_VELOCITY

		#Shift
	if Input.is_action_pressed("SHIFT"):
		speed = run_SPEED
	else:
		speed = walk_SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
	#hbc
		
	bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(bob)
		
	#fov_c
	var vel_cl = clamp(velocity.length(), 0.5, run_SPEED * 2)
	var tar_fov = FOV + FOV_c * vel_cl
	camera.fov = lerp(camera.fov, tar_fov, delta * 8.0)
		
	
	#shoot
	
	if Input.is_action_just_pressed("LCM"):
		shoot()
	
	
	move_and_slide()
	debug()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
	
func take_damage(amount: int):
	HP -= amount
	if HP <= 0:
		is_dead = true

func shoot():
	if !can_shoot:
		return
	can_shoot = false
	if raycast_3d.is_colliding() and raycast_3d.get_collider().has_method("kill"):
		raycast_3d.get_collider().take_damage()

func debug():
	$Head/CanvasLayer/Label.text = str("hp - ", HP)

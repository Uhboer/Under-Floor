extends CharacterBody3D

@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var character = $"../character"

const MOVE_SPEED = 2.0
const ATTACK_RANGE = 2.0
const DAMAGE = 30.0
var hp = 100.0

var is_dead = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if character == null:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var dir = character.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	velocity = dir * MOVE_SPEED
	
	move_and_slide()
	kill_player()
	
func kill_player():
	var can_attack = false
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, character.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	var dist_to_player = global_position.distance_to(character.global_position)
	if dist_to_player > ATTACK_RANGE:
		can_attack = false
		return
	elif dist_to_player <= ATTACK_RANGE:
		can_attack = true
		if result.is_empty():
			if can_attack:
				character.take_damage(DAMAGE)
				can_attack = false

#TODO: uncomment this shit after when making sprites
#func get_killed():
	#if is_dead:
		#$DeathSound.play()
		#animated_sprite_3d.play("death")
		#$CollisionShape3D.disabled = true

func debug():
	$Label3D.text = str("hp - ", hp)

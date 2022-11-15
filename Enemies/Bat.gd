extends KinematicBody2D

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

export var ACCELERATION = 300
export var MAX_SPEED = 75
export var FRICTION = 100

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _ready():
	print(stats.max_health)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if(wanderController.get_time_left() == 0):
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
		WANDER:
			seek_player()
			if(wanderController.get_time_left() == 0):
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
				var direction = global_position.direction_to(wanderController.target_position)
				sprite.flip_h = velocity.x < 0
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				sprite.flip_h = velocity.x < 0
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	
	if(softCollision.is_colliding()):
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	print(stats.health)
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	var barf = self.duplicate()
	get_parent().add_child(barf)
	barf.global_position = global_position
	var gay = self.duplicate()
	get_parent().add_child(gay)
	gay.global_position = global_position
	
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = global_position

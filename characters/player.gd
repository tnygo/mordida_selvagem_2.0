extends CharacterBody2D

@export var max_speed = 200
@export var max_health = 5
@export var max_hunger = 100
@export var hunger_increase_rate = 10
@export var hunger_decrease_amount = 20

@onready var collisionShape = $CollisionShape2D
@onready var invincibility_timer = $InvincibilityTimer as Timer
@onready var hunger_timer = $HungerTimer as Timer

var health: int = max_health
var hunger = 0
var input = Vector2.ZERO
var sprite: Sprite2D
var initial_position: Vector2
var current_sprite = 1
var is_invincible = false

signal life_changed(player_hearts)
signal player_take_damage
signal player_died
signal hunger_updated(hunger_value)

func _ready():
	add_to_group("player")
	sprite = $Sprite2D
	Global.food_eaten = 0
	sprite.texture = Global.get_player_textures()[current_sprite]
	initial_position = global_position
	var lifeControl = get_parent().get_node("UILayer/Control")
	life_changed.connect(lifeControl.on_player_life_changed)
	life_changed.emit(max_health)
	invincibility_timer.wait_time = 1.0
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	
	hunger_timer.wait_time = 1.5
	hunger_timer.timeout.connect(_on_hunger_timer_timeout)
	hunger_timer.start()

func _physics_process(delta: float) -> void:
	player_movement()
	move_and_slide()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right') or Input.is_key_pressed(KEY_D):
		velocity.x += 1
		sprite.scale.x = 1
	elif Input.is_action_pressed('ui_left') or Input.is_key_pressed(KEY_A):
		velocity.x -= 1
		sprite.scale.x = -1
	if Input.is_action_pressed('ui_down') or Input.is_key_pressed(KEY_S):
		velocity.y += 1
	elif Input.is_action_pressed('ui_up') or Input.is_key_pressed(KEY_W):
		velocity.y -= 1

	velocity = velocity.normalized() * max_speed

func player_movement():
	get_input()

func take_damage(amount: int):
	if is_invincible:
		print("Player is invincible, no damage taken.")
		return
	
	health -= amount
	life_changed.emit(health)
	print("Player health:", health)
	
	if health <= 0:
		print("player died!")
		player_died.emit()
		queue_free()
		return
	
	player_take_damage.emit()

func reset_position():
	position = initial_position
	hunger = 0
	is_invincible = true
	invincibility_timer.start()
	print("Player reset, invincibility activated.")

func change_sprite():
	current_sprite += 1
	sprite.texture = Global.get_player_textures()[current_sprite]

func _on_invincibility_timer_timeout():
	is_invincible = false
	print("Player invincibility ended.")

func _on_hunger_timer_timeout():
	hunger += hunger_increase_rate
	hunger_updated.emit(hunger)
	
	if hunger >= max_hunger:
		print("Player died of hunger!")
		player_take_damage.emit()

func eat_food():
	hunger = max(hunger - hunger_decrease_amount, 0)
	hunger_updated.emit(hunger)

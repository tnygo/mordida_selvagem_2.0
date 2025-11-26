extends Area2D
signal food_eaten

@export var hunger_restore: int = 20
var collected: bool = false
func _ready() -> void:
	monitoring = true
	monitorable = true
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(b: Node) -> void:
	if b.is_in_group("player"):
		if b.has_method("eat_food_value"): b.eat_food_value(hunger_restore)
		elif b.has_method("eat_food"): b.eat_food()
		emit_signal("food_eaten")
		monitoring = false   # para de detectar
		visible = false 
		
func reset_for_round(player: Node = null) -> void:
	collected = false
	visible = true
	await get_tree().physics_frame

	var p := player
	if p == null:
		p = get_tree().get_first_node_in_group("player")

	if p and overlaps_body(p):
		await get_tree().create_timer(0.15).timeout

	set_deferred("monitoring", true)

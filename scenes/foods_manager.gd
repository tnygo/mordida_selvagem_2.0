extends Node

signal reset_positions
signal change_sprites
signal chain_completed

const MAX_ROUNDS: int = 3  # << só 3 sprites/estágios

var total_food_count: int = 0
var current_sprite: int = 0
var foods: Array[Node] = []

func _ready() -> void:
	foods = get_children()
	total_food_count = foods.size()

	var list: Array[Texture2D] = Global.get_food_textures()
	var i: int = clamp(current_sprite, 0, list.size() - 1)

	for food in foods:
		var spr: Sprite2D = food.get_node_or_null("Sprite2D") as Sprite2D
		if spr: spr.texture = list[i]
		if food.has_signal("food_eaten") and not food.food_eaten.is_connected(on_food_eaten):
			food.food_eaten.connect(on_food_eaten)

func on_food_eaten() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_method("eat_food"):
		player.eat_food()

	await get_tree().process_frame

	var remaining := 0
	for n in get_children():
		if is_instance_valid(n) and n.visible:
			remaining += 1
	if remaining > 0:
		return

	var list: Array[Texture2D] = Global.get_food_textures()
	# limite real: 3 rodadas => índices 0,1,2
	var max_i: int = min(list.size() - 1, MAX_ROUNDS - 1)

	if current_sprite < max_i:
		reset_positions.emit()
		await get_tree().process_frame
		change_sprites.emit()
		change_sprite()
	else:
		emit_signal("chain_completed")

func change_sprite() -> void:
	var list: Array[Texture2D] = Global.get_food_textures()
	var max_i: int = min(list.size() - 1, MAX_ROUNDS - 1)
	current_sprite = clamp(current_sprite + 1, 0, max_i)

	var player: Node = get_tree().get_first_node_in_group("player")
	for food in get_children():
		if not is_instance_valid(food): continue
		var spr: Sprite2D = food.get_node_or_null("Sprite2D") as Sprite2D
		if spr: spr.texture = list[current_sprite]
		food.visible = true
		if food.has_method("reset_for_round"):
			food.reset_for_round(player)

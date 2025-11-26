extends Node

enum Biome { AQUATIC = 0, TERRESTRIAL = 1 }
var biome: Biome = Biome.AQUATIC
var food_eaten = 0
var chain_index = 0
var is_dragging = false

var sprite_squatic_list: Array[Texture2D] = [
	preload("res://assets/sprites/algas.png"),
	preload("res://assets/sprites/camarão.png"),
	preload("res://assets/sprites/peixe.png"),
	preload("res://assets/sprites/Pinguim.png"),
	preload("res://assets/sprites/Foca.png"),
]

var sprite_terrestrial_list: Array[Texture2D] = [
	preload("res://assets/sprites/grama.png"),
	preload("res://assets/sprites/gafanhoto.png"),
	preload("res://assets/sprites/sapo.png"),
	preload("res://assets/sprites/cobra.png"),
	preload("res://assets/sprites/gaviao.png"),
]

func get_player_textures() -> Array[Texture2D]:
	return sprite_squatic_list if biome == Biome.AQUATIC else sprite_terrestrial_list

func get_food_textures() -> Array[Texture2D]:
	return sprite_squatic_list if biome == Biome.AQUATIC else sprite_terrestrial_list

func get_enemy_textures() -> Array[Texture2D]:
	return sprite_squatic_list if biome == Biome.AQUATIC else sprite_terrestrial_list

func chain_max_index() -> int:
	return get_food_textures().size() - 1

func is_chain_finished() -> bool:
	return chain_index >= chain_max_index()

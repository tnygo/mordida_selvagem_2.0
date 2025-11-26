extends Control

const PUZZLE_SCENE_PATH := "res://scenes/puzzle_mapa1.tscn"
const THEME_AQUA := "res://resources/chain_problems/new_resource.tres"
const THEME_TERR := "res://resources/chain_problems/terrestrial_chain.tres"

func _ready() -> void:
	set_as_top_level(true)
	set_anchors_preset(Control.PRESET_FULL_RECT, true)

	var puzzle := preload(PUZZLE_SCENE_PATH).instantiate()

	if "chain" in puzzle:
		var theme_path := THEME_TERR if Global.biome == Global.Biome.TERRESTRIAL else THEME_AQUA
		if ResourceLoader.exists(theme_path):
			var theme := load(theme_path)
			puzzle.chain = theme

	add_child(puzzle)

	var back := Button.new()
	back.text = "VOLTAR AO MENU"
	back.anchor_left = 0
	back.anchor_top = 0
	back.anchor_right = 0
	back.anchor_bottom = 0
	back.position = Vector2(16, 16)
	back.custom_minimum_size = Vector2(200, 44)
	add_child(back)
	move_child(back, get_child_count() - 1)

	back.pressed.connect(func ():
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	)

extends Control


var _mini_dialog: ConfirmationDialog

func _ready() -> void:
	var title_lbl := get_node("CenterContainer/VBoxContainer/Label") as Label
	title_lbl.text = "MORDIDA SELVAGEM"

	var grid := get_node("CenterContainer/VBoxContainer/GridContainer") as GridContainer

	var btn_a := grid.get_node("BtnAquatica")  as LevelButton
	var btn_t := grid.get_node("BtnTerrestre") as LevelButton
	var btn_u := grid.get_node("BtnMinigame")  as LevelButton
	var btn_s := grid.get_node("BtnSair")      as LevelButton

	_config_btn(btn_a, "FASE AQUÁTICA", "res://assets/ui/icons/icon_aquatica.png", "res://scenes/world1.tscn", "AQUATICA")
	_config_btn(btn_t, "FASE TERRESTRE","res://assets/ui/icons/icon_terrestre.png","res://scenes/world2.tscn","TERRESTRE")

	_config_btn(btn_u, "MINIGAME (BETA)", "res://assets/mascot/mord_feliz.png", "res://scenes/tutorial.tscn", "MINIGAME")

	# Sair
	btn_s.title      = "SAIR DO JOGO"
	btn_s.icon       = load("res://assets/ui/icons/icon_sair.png") as Texture2D
	btn_s.target_scene_path = ""
	btn_s.theme_key  = "SAIR"
	btn_s.pressed.connect(func(_p: String) -> void: get_tree().quit())

	_create_minigame_dialog()

	await get_tree().process_frame
	_setup_focus(grid)


func _create_minigame_dialog() -> void:
	_mini_dialog = ConfirmationDialog.new()
	_mini_dialog.title = "ESCOLHA O MINIGAME"
	add_child(_mini_dialog)

	_mini_dialog.get_ok_button().visible = false
	_mini_dialog.get_cancel_button().text = "Fechar"

	# Botões customizados (ações)
	_mini_dialog.add_button("AQUÁTICO", false, "mini_aqua")
	_mini_dialog.add_button("TERRESTRE", false, "mini_terr")

	_mini_dialog.custom_action.connect(func(action: String):
		match action:
			"mini_aqua":
				Global.biome = Global.Biome.AQUATIC
				get_tree().change_scene_to_file("res://scenes/minigame/MinigameLoader.tscn")
			"mini_terr":
				Global.biome = Global.Biome.TERRESTRIAL
				get_tree().change_scene_to_file("res://scenes/minigame/MinigameLoader.tscn")
	)


func _config_btn(b: LevelButton, title: String, icon_path: String, scene_path: String, theme_key: String) -> void:
	b.title = title
	b.icon = load(icon_path) as Texture2D
	b.target_scene_path = scene_path
	b.theme_key = theme_key
	b.pressed.connect(_on_btn_pressed)

func _on_btn_pressed(scene_path: String) -> void:
	if scene_path == "res://scenes/tutorial.tscn":
		_mini_dialog.reset_size()
		_mini_dialog.popup_centered()  # centralizado na janela
		return

	if scene_path.is_empty(): return
	get_tree().change_scene_to_file(scene_path)

func _setup_focus(grid: GridContainer) -> void:
	if grid.get_child_count() < 4: return
	var a: Button = grid.get_node("BtnAquatica/ClickArea")
	var b: Button = grid.get_node("BtnTerrestre/ClickArea")
	var c: Button = grid.get_node("BtnMinigame/ClickArea")
	var d: Button = grid.get_node("BtnSair/ClickArea")

	a.focus_neighbor_right = b.get_path()
	a.focus_neighbor_bottom = c.get_path()
	b.focus_neighbor_left  = a.get_path()
	b.focus_neighbor_bottom = d.get_path()
	c.focus_neighbor_top   = a.get_path()
	c.focus_neighbor_right = d.get_path()
	d.focus_neighbor_top   = b.get_path()
	d.focus_neighbor_left  = c.get_path()

	a.grab_focus()

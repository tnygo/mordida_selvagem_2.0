extends Node2D

@onready var game = $Game
@onready var menu = preload("res://ui/ControlsHintMenu.tscn").instantiate()
@onready var player = $Game/Player
@onready var enemies = $Game/Enemies.get_children()
@onready var foods_node = $Game/Foods
@onready var foods: Array[Node] = $Game/Foods.get_children()
@onready var hunger_bar = $Game/UILayer/HungerBar as ProgressBar

@onready var WinScreenScene := preload("res://scenes/ui/WinScreen.tscn")
@onready var LoseScreenScene := preload("res://scenes/ui/LoseScreen.tscn")

var current_sprite := 0
var target_sprites := 3
var game_started := false

func _enter_tree() -> void:
	Global.biome = Global.Biome.TERRESTRIAL
	Global.chain_index = 0
	Global.food_eaten = 0

func _ready():
	add_child(menu)
	if menu:
		menu.start_game.connect(_on_start_game)
		menu.return_to_main_menu.connect(_on_return_to_main_menu)
	
	if player:
		player.player_take_damage.connect(_on_player_take_damage)
		player.player_died.connect(_on_player_died)
		player.hunger_updated.connect(_on_hunger_updated)
	
	if foods_node:
		foods_node.change_sprites.connect(_on_change_sprites)
		foods_node.reset_positions.connect(_on_foods_reset_positions)
		if foods_node.has_signal("chain_completed"):
			foods_node.chain_completed.connect(_on_chain_completed)
			
	if hunger_bar and player:
		hunger_bar.min_value = 0
		hunger_bar.max_value = player.max_hunger
		hunger_bar.value = 0
	show_menu()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		show_menu()

func show_menu():
	if menu:
		menu.visible = true
	game_started = false
	pause_game()

func hide_menu():
	if menu:
		menu.visible = false
	game_started = true
	resume_game()

func pause_game():
	$Game.process_mode = Node.PROCESS_MODE_DISABLED  # para a lógica do jogo

func resume_game():
	$Game.process_mode = Node.PROCESS_MODE_INHERIT  # retoma a lógica

func reset_world(reset_foods := false):
	current_sprite = 0
	if hunger_bar:
		hunger_bar.value = 0
	if player:
		player.reset_position()
	for enemy in enemies:
		if enemy:
			enemy.reset_position()
	if reset_foods:
		for food in foods:
			if food:
				food.visible = true

func _on_start_game():
	hide_menu()
	reset_world()

func _on_return_to_main_menu():
	resume_game()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	
func _on_player_take_damage():
	show_menu()

func _on_player_died():
	_open_lose_screen()

func _on_foods_reset_positions():
	reset_world(true)

func _on_change_sprites():
	current_sprite += 1
	player.change_sprite()
	for enemy in enemies:
		enemy.change_sprite()
	
	if current_sprite >= target_sprites:
		_open_win_screen()

func _on_chain_completed():
	_open_win_screen()

# --- Minigame desativado nesta fase ---
func render_puzzle():
	pass

func _on_hunger_updated(hunger_value):
	if hunger_bar:
		var fill = hunger_bar.get_theme_stylebox("fill") as StyleBoxFlat
		if hunger_value == 100:
			fill.corner_radius_top_right = 20
			fill.corner_radius_bottom_right = 20
		else:
			fill.corner_radius_top_right = 0
			fill.corner_radius_bottom_right = 0
		hunger_bar.add_theme_stylebox_override("fill", fill)
		hunger_bar.value = hunger_value


func _open_win_screen():
	pause_game()
	if menu:
		menu.visible = false
	var win := WinScreenScene.instantiate()
	add_child(win)
	call_deferred("move_child", win, get_child_count() - 1)
	_make_end_screen_visible(win)

	if win.has_signal("play_again"):
		win.play_again.connect(func ():
			_close_end_screen(win)
			reset_world(true)
			resume_game()
		)
	if win.has_signal("go_to_menu"):
		win.go_to_menu.connect(func ():
			_close_end_screen(win)
			_on_return_to_main_menu()
		)

func _open_lose_screen():
	pause_game()
	if menu:
		menu.visible = false
	var lose := LoseScreenScene.instantiate()
	add_child(lose)
	call_deferred("move_child", lose, get_child_count() - 1)
	_make_end_screen_visible(lose)

	if lose.has_signal("try_again"):
		lose.try_again.connect(func ():
			_close_end_screen(lose)
			reset_world(true)
			resume_game()
		)
	if lose.has_signal("go_to_menu"):
		lose.go_to_menu.connect(func ():
			_close_end_screen(lose)
			_on_return_to_main_menu()
		)

func _make_end_screen_visible(screen: Node):
	if screen is Control:
		var c := screen as Control
		c.visible = true
		c.set_as_top_level(true)
		c.set_anchors_preset(Control.PRESET_FULL_RECT, true)
		c.z_index = 1024
		c.modulate.a = 1.0
		c.mouse_filter = Control.MOUSE_FILTER_STOP
		c.grab_focus()
	elif screen is CanvasItem:
		screen.visible = true
		screen.z_index = 1024

func _close_end_screen(screen: Node):
	if is_instance_valid(screen):
		screen.queue_free()

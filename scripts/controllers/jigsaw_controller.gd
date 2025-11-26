extends Control

signal request_exit  # quem abriu o minigame pode ouvir isso para fechar

@export var chain: ChainTheme
@export var success_color: Color = Color(0.15, 0.75, 0.2, 1.0)
@export var failed_color: Color  = Color(0.8, 0.15, 0.15, 1.0)
@export var back_to_menu_scene: String = "res://scenes/menus/main_menu.tscn" # fallback

@onready var answer_button: Button = $Button

var draggables: Array[Draggable]
var dropables: Array[Dropable]
var index: int
var correct: int
var points: int

var _ui_layer: Control
var _topbar: Panel
var _feedback_panel: Panel
var _feedback_label: Label

@onready var content_to_shake: Node = self

var current_chain: ChainProblem:
	get:
		return chain.theme[index]

func _ready():
	if chain == null:
		push_error("Puzzle sem 'chain' definido. Defina p.chain antes de add_child().")
		queue_free()
		return

	points = 0

	for dropable in $Dropable.get_children():
		dropables.append(dropable)

	for dragable in $Draggable.get_children():
		draggables.append(dragable)

	_build_ui_overlay()
	load_problem()

	if is_instance_valid(answer_button):
		answer_button.pressed.connect(_on_answer.bind(answer_button))


func load_problem() -> void:
	if chain == null:
		return
	if index >= chain.theme.size():
		return

	var shuffled_drags = draggables.duplicate()
	shuffled_drags.shuffle()

	for i in range(draggables.size()):
		shuffled_drags[i].name = current_chain.correct_chain[i]
		var texture_path = current_chain.texture_paths[i]
		var texture = load(texture_path) as Texture2D

		if texture:
			shuffled_drags[i].texture = texture
		else:
			printerr("Falha ao carregar a textura: ", texture_path)

	draggables = shuffled_drags

func _on_answer(button: Button) -> void:
	var ok := checkOrder()
	if ok:
		button.modulate = success_color
		_show_feedback(true)
	else:
		button.modulate = failed_color
		_show_feedback(false)

func checkOrder() -> bool:
	for i in range(dropables.size()):
		if dropables[i].occupied_by != current_chain.correct_chain[i]:
			return false
	return true


func _build_ui_overlay() -> void:

	_ui_layer = Control.new()
	_ui_layer.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	_ui_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ui_layer)
	move_child(_ui_layer, get_child_count() - 1)

	_topbar = Panel.new()
	_topbar.mouse_filter = Control.MOUSE_FILTER_PASS
	_topbar.anchor_left = 0; _topbar.anchor_right = 1
	_topbar.anchor_top = 0;  _topbar.anchor_bottom = 0
	_topbar.offset_left = 0; _topbar.offset_right = 0
	_topbar.offset_top = 0;  _topbar.offset_bottom = 56
	_topbar.add_theme_stylebox_override("panel", _style_panel(Color(0,0,0,0.18), 0, 8))
	_ui_layer.add_child(_topbar)

	# Botão Voltar
	var back := Button.new()
	back.text = "VOLTAR"
	back.custom_minimum_size = Vector2(140, 40)
	back.position = Vector2(12, 8)
	back.focus_mode = Control.FOCUS_NONE
	back.pressed.connect(_on_back_pressed)
	_topbar.add_child(back)

	# Botão Fechar (X)
	var close := Button.new()
	close.text = "✕"
	close.custom_minimum_size = Vector2(40, 40)
	close.focus_mode = Control.FOCUS_NONE
	close.anchor_right = 1; close.anchor_top = 0
	close.position = Vector2(-52, 8)
	close.pressed.connect(_on_back_pressed)
	_topbar.add_child(close)

	# Painel de feedback (flutuante no rodapé)
	_feedback_panel = Panel.new()
	_feedback_panel.visible = false
	_feedback_panel.anchor_left = 0.5
	_feedback_panel.anchor_right = 0.5
	_feedback_panel.anchor_top = 1
	_feedback_panel.anchor_bottom = 1
	_feedback_panel.offset_left = -220
	_feedback_panel.offset_right = 220
	_feedback_panel.offset_top = -96
	_feedback_panel.offset_bottom = -44
	_ui_layer.add_child(_feedback_panel)

	_feedback_label = Label.new()
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_feedback_label.add_theme_font_size_override("font_size", 28)
	_feedback_label.add_theme_color_override("font_color", Color(1,1,1,1))
	_feedback_panel.add_child(_feedback_label)
	_feedback_label.set_anchors_preset(Control.PRESET_FULL_RECT, true)

func _style_panel(color: Color, radius := 12, shadow := 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.shadow_color = Color(0,0,0,0.22)
	sb.shadow_size = shadow
	return sb

# helper porque Color.with_alpha não existe em todos os builds
func _with_alpha(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, a)

func _show_feedback(ok: bool) -> void:
	_feedback_panel.visible = true
	_feedback_panel.modulate = Color(1,1,1,0)
	_feedback_label.text = "CORRETO! 🎉" if ok else "OPS! ORDEM INCORRETA"
	var base_col := success_color if ok else failed_color
	_feedback_panel.add_theme_stylebox_override(
		"panel",
		_style_panel(_with_alpha(base_col, 0.9), 10, 16)
	)

	var tw := create_tween()
	tw.tween_property(_feedback_panel, "modulate:a", 1.0, 0.18)
	if ok:
		_flash_success()
		tw.tween_interval(1.0)
		tw.tween_property(_feedback_panel, "modulate:a", 0.25, 0.25)
	else:
		_shake(content_to_shake)
		tw.tween_interval(1.2)
		tw.tween_property(_feedback_panel, "modulate:a", 0.0, 0.25)
	tw.finished.connect(func():
		if not ok:
			_feedback_panel.visible = false
	)

func _flash_success() -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate", Color(0.75,1,0.75,1), 0.06)
	tw.tween_property(self, "modulate", Color(1,1,1,1), 0.22)

func _shake(target: Node) -> void:
	if not (target is CanvasItem):
		return
	var item := target as CanvasItem
	var base_pos: Vector2 = item.position
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(item, "position:x", base_pos.x + 10, 0.05)
	tw.tween_property(item, "position:x", base_pos.x - 10, 0.08)
	tw.tween_property(item, "position:x", base_pos.x + 6, 0.06)
	tw.tween_property(item, "position:x", base_pos.x, 0.05)

func _on_back_pressed() -> void:
	if get_signal_connection_list("request_exit").size() > 0:
		emit_signal("request_exit")
		return
	if back_to_menu_scene != "":
		get_tree().change_scene_to_file(back_to_menu_scene)

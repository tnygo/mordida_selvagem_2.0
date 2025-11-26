extends Control

signal start_game
signal return_to_main_menu

@onready var panel            : Panel          = $Panel
@onready var vbox             : VBoxContainer  = $Panel/VBoxContainer
@onready var arrows_row       : HBoxContainer  = $Panel/VBoxContainer/Arrows
@onready var buttons_row      : HBoxContainer  = $Panel/VBoxContainer/Buttons

@onready var title_lbl        : Label = $Panel/VBoxContainer/Title
@onready var arrow_left       : Label = $Panel/VBoxContainer/Arrows/ArrowLeft
@onready var arrow_up         : Label = $Panel/VBoxContainer/Arrows/ArrowUp
@onready var arrow_down       : Label = $Panel/VBoxContainer/Arrows/ArrowDown
@onready var arrow_right      : Label = $Panel/VBoxContainer/Arrows/ArrowRight

@onready var btn_back         : Button = $Panel/VBoxContainer/Buttons/BackButton
@onready var btn_start        : Button = $Panel/VBoxContainer/Buttons/StartButton


func _ready() -> void:
	# GARANTE full-screen absoluto, sem herdar nada do pai
	set_as_top_level(true)
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.98)
	sb.corner_radius_top_left = 14
	sb.corner_radius_top_right = 14
	sb.corner_radius_bottom_left = 14
	sb.corner_radius_bottom_right = 14
	sb.shadow_color = Color(0, 0, 0, 0.18)
	sb.shadow_size = 12
	panel.add_theme_stylebox_override("panel", sb)

	# centralização e layout
	_center_panel()
	connect("resized", Callable(self, "_center_panel"))

	# espaçamentos (Godot 4 usa theme override)
	vbox.add_theme_constant_override("separation", 20)
	arrows_row.add_theme_constant_override("separation", 36)
	buttons_row.add_theme_constant_override("separation", 48)

	# título
	title_lbl.text = "USE AS SETAS PARA SE MOVER"
	title_lbl.add_theme_font_size_override("font_size", 52)
	title_lbl.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# setas (MENOR que antes)
	for l in [arrow_left, arrow_up, arrow_down, arrow_right]:
		l.add_theme_font_size_override("font_size", 92) # <-- era 120
		l.modulate = Color(0, 0, 0, 0.45)
		l.scale = Vector2.ONE

	# botões
	btn_back.text  = "VOLTAR AO MENU"
	btn_start.text = "INICIAR FASE"
	btn_back.pressed.connect(func(): emit_signal("return_to_main_menu"))
	btn_start.pressed.connect(func(): emit_signal("start_game"))

	# janela 1024x640 (se não estiver fullscreen)
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		var target := Vector2i(1024, 640)
		if DisplayServer.window_get_size() != target:
			DisplayServer.window_set_size(target)

	# animação (pares ↑↓ e ←→)
	_start_arrows_blink_pairs()


func _center_panel() -> void:

	var panel_size := Vector2(860, 500) # <-- antes 420
	var PAD_H := 32.0
	var PAD_V := 28.0

	# panel no centro exato (anchors 0.5 + offsets simétricos)
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -panel_size.x * 0.5
	panel.offset_right =  panel_size.x * 0.5
	panel.offset_top =   -panel_size.y * 0.5
	panel.offset_bottom = panel_size.y * 0.5
	panel.custom_minimum_size = panel_size

	# vbox ocupa o painel com padding
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = PAD_H
	vbox.offset_right = -PAD_H
	vbox.offset_top = PAD_V
	vbox.offset_bottom = -PAD_V

	# centralização dos conteúdos e evita expansão lateral
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrows_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	for child in arrows_row.get_children():
		if child is Control:
			(child as Control).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	for child in buttons_row.get_children():
		if child is Control:
			(child as Control).size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _start_arrows_blink_pairs() -> void:
	var pairs := [
		[arrow_up, arrow_down],
		[arrow_left, arrow_right]
	]

	var tw := create_tween()
	tw.set_loops()
	var step := 0.6

	for pair in pairs:
		for a in pair:
			a.modulate.a = 0.45
		tw.tween_property(pair[0], "modulate:a", 1.0, step * 0.4).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(pair[1], "modulate:a", 1.0, step * 0.4).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(pair[0], "scale", Vector2(1.12, 1.12), step * 0.3).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(pair[1], "scale", Vector2(1.12, 1.12), step * 0.3).set_trans(Tween.TRANS_SINE)
		tw.tween_property(pair[0], "modulate:a", 0.45, step * 0.4).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(pair[1], "modulate:a", 0.45, step * 0.4).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(pair[0], "scale", Vector2.ONE, step * 0.3).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(pair[1], "scale", Vector2.ONE, step * 0.3).set_trans(Tween.TRANS_SINE)
		tw.tween_interval(0.12)

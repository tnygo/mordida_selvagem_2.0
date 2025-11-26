extends Control
class_name LevelButton

@onready var title_label: Label     = $"VBoxContainer/Title"
@onready var icon_rect: TextureRect = $"VBoxContainer/Icon"
@onready var click_area: Button     = $"ClickArea"

@export var title: String = "Título": set = set_title
@export var icon: Texture2D: set = set_icon
@export_file("*.tscn") var target_scene_path: String = ""
@export_enum("AQUATICA", "TERRESTRE", "TUTORIAL", "SAIR") var theme_key: String = "AQUATICA"

signal pressed(target_path: String)

var _orig_bg: Color = Color.WHITE

func _ready() -> void:
	clip_contents = true
	custom_minimum_size = Vector2(200, 200)

	set_title(title)
	set_icon(icon)
	_apply_theme(theme_key)

	if click_area:
		click_area.pressed.connect(_on_pressed)
		click_area.mouse_entered.connect(func(): _hover(true))
		click_area.mouse_exited.connect(func(): _hover(false))

	if title_label:
		title_label.text = title
		title_label.custom_minimum_size = Vector2(0, 36)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	if icon_rect:
		icon_rect.custom_minimum_size = Vector2(140, 120) 
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_rect.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		
func set_title(v: String) -> void:
	title = v
	if title_label:
		title_label.text = v

func set_icon(v: Texture2D) -> void:
	icon = v
	if icon_rect:
		icon_rect.texture = v

func _on_pressed() -> void:
	emit_signal("pressed", target_scene_path)

func _hover(is_on: bool) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale",
		(Vector2(1.05, 1.05) if is_on else Vector2.ONE), 0.08)

	var sb: StyleBoxFlat = _get_panel_sb()
	if sb:
		var new_sb: StyleBoxFlat = sb.duplicate()
		if is_on:
			_orig_bg = sb.bg_color
			new_sb.bg_color = sb.bg_color.lightened(0.08)
		else:
			new_sb.bg_color = _orig_bg
		$Panel.add_theme_stylebox_override("panel", new_sb)

func _apply_theme(key: String) -> void:
	var themes := get_tree().root.get_node_or_null("Themes")
	if themes == null:
		themes = get_tree().root.get_node_or_null("GameThemes")

	if themes != null:
		var palettes: Dictionary = themes.PALETTES
		if palettes.has(key):
			var entry: Dictionary = palettes[key]
			var sb_auto: StyleBoxFlat = themes.make_stylebox(
				entry.get("bg", Color.WHITE),
				entry.get("border", Color.BLACK)
			)
			$Panel.add_theme_stylebox_override("panel", sb_auto)
			return

	var palettes2: Dictionary = {
		"AQUATICA": {"bg": Color8(130,216,241), "border": Color8(27,59,74,85)},
		"TERRESTRE": {"bg": Color8(141,209,122), "border": Color8(24,59,30,85)},
		"TUTORIAL": {"bg": Color8(255,234,134), "border": Color8(90,74,0,85)},
		"SAIR": {"bg": Color8(209,207,207), "border": Color(0,0,0,0.2)}
	}
	var entry2: Dictionary = palettes2.get(key, palettes2["AQUATICA"])

	var sb2: StyleBoxFlat = StyleBoxFlat.new()
	sb2.bg_color = entry2["bg"]
	sb2.corner_radius_top_left = 16
	sb2.corner_radius_top_right = 16
	sb2.corner_radius_bottom_left = 16
	sb2.corner_radius_bottom_right = 16
	sb2.border_width_left = 2
	sb2.border_width_top = 2
	sb2.border_width_right = 2
	sb2.border_width_bottom = 2
	sb2.border_color = entry2["border"]
	sb2.shadow_size = 8
	sb2.shadow_color = Color(0,0,0,0.2)
	sb2.shadow_offset = Vector2(0, 2)
	$Panel.add_theme_stylebox_override("panel", sb2)

func _get_panel_sb() -> StyleBoxFlat:
	return $Panel.get_theme_stylebox("panel") as StyleBoxFlat

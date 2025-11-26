extends Control
class_name WinLoseScreen

@export_file("*.tscn") var menu_scene_path: String
@export_file("*.tscn") var retry_scene_path: String
@export var is_win_screen := true

@export_node_path("TextureRect") var mascot_path: NodePath = ^"Center/Body/Mascot"
@onready var mascot_rect: TextureRect = get_node_or_null(mascot_path)

var mascot_happy: Texture2D  

@onready var _retry_btn: Button = %RetryButton
@onready var _menu_btn: Button = %MenuButton
@onready var _sfx: AudioStreamPlayer = $Sfx

func _ready() -> void:
	# Botões
	if is_instance_valid(_retry_btn):
		_retry_btn.pressed.connect(_on_retry_pressed)
	if is_instance_valid(_menu_btn):
		_menu_btn.pressed.connect(_on_menu_pressed)

	if is_instance_valid(_sfx) and _sfx.stream and not _sfx.playing:
		_sfx.play()

	if mascot_happy == null and mascot_rect and mascot_rect.texture:
		mascot_happy = mascot_rect.texture

func _on_retry_pressed() -> void:
	if retry_scene_path != "":
		get_tree().change_scene_to_file(retry_scene_path)
		return
	var current := get_tree().current_scene
	if current and current.scene_file_path != "":
		get_tree().change_scene_to_file(current.scene_file_path)
	else:
		_on_menu_pressed()

func _on_menu_pressed() -> void:
	if menu_scene_path != "":
		get_tree().change_scene_to_file(menu_scene_path)

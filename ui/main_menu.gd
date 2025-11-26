class_name MainMenu
extends Control

@onready var start_button = $"MarginContainer/ColorMenu/VBoxContainer/StartButton"
@onready var options_button = $"MarginContainer/ColorMenu/VBoxContainer/OptionButton"
@onready var exit_button = $"MarginContainer/ColorMenu/VBoxContainer/ExitButton"

@onready var start_level = preload("res://scenes/world1.tscn") as PackedScene
#@onready var options_page = preload()

func _ready():
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_options_pressed)
	exit_button.button_down.connect(on_exit_pressed)

func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_options_pressed() -> void:
	printerr("options ainda nao implementado")

func on_exit_pressed() -> void:
	get_tree().quit()

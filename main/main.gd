class_name Main
extends Node2D

@onready var main_menu = preload("res://ui/main_menu.tscn") as PackedScene

func _ready():
	get_tree().change_scene_to_packed(main_menu)

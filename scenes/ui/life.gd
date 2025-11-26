extends Control

@onready var hearts = $LifesHearts as TextureRect
var heart_size: int = 32

func on_player_life_changed(player_hearts: int) -> void:
	hearts.size.x = player_hearts * heart_size

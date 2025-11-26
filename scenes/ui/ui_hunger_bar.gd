extends CanvasLayer

@onready var hunger_bar = $HungerBar

func _ready():
	var player = get_tree().get_root().get_node("World1/Game/Player")
	if player:
		player.hunger_updated.connect(update_hunger_bar)

func update_hunger_bar(hunger_value):
	print("updated: ", hunger_value)
	hunger_bar.value = hunger_value

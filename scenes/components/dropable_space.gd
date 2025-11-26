extends StaticBody2D
class_name Dropable

#func _ready():
	#modulate = Color(Color.MEDIUM_PURPLE, 0.7)

#func _process(delta):
	#if Global.is_dragging:
		#visible = true
	#else:
		#visible = false

var occupied_by: String

func _ready():
	occupied_by = ""

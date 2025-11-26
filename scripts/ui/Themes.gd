extends Node
class_name Themes

# Paletas reutilizáveis (mude à vontade)
const PALETTES := {
	"AQUATICA": {
		"bg": Color8(130, 216, 241),   # #82D8F1
		"border": Color8(27, 59, 74, 85),
	},
	"TERRESTRE": {
		"bg": Color8(141, 209, 122),   # #8DD17A
		"border": Color8(24, 59, 30, 85),
	},
	"TUTORIAL": {
		"bg": Color8(255, 234, 134),   # #FFEA86
		"border": Color8(90, 74, 0, 85),
	},
	"SAIR": {
		"bg": Color8(209, 207, 207),   # #D1CFCF
		"border": Color(0,0,0,0.2),
	}
}

# Cria um StyleBoxFlat com padrão visual único
static func make_stylebox(bg: Color, border: Color, radius := 16, border_w := 2, shadow_size := 8, shadow_alpha := 0.2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.border_width_left = border_w
	sb.border_width_top = border_w
	sb.border_width_right = border_w
	sb.border_width_bottom = border_w
	sb.border_color = border
	sb.shadow_size = shadow_size
	sb.shadow_color = Color(0,0,0,shadow_alpha)
	sb.shadow_offset = Vector2(0, 2) # leve relevo
	return sb

extends Node2D
## True, pixel-verifiable gallery of every fauna illustration.
## Uses the same Ecology.paint routine as the game, including textures and animation.
const Ecology = preload("res://scripts/marine_ecology.gd")
var time_s := 2.45

func _draw() -> void:
	draw_rect(Rect2(0,0,1280,720),Color("#081725"))
	draw_string(ThemeDB.fallback_font,Vector2(33,48),
		"ABYSSAL   /   FAUNA ANIMADA   /   INSPECAO REAL DO GODOT",
		HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("#d4e4dd"))
	for i in range(Ecology.SPECIES.size()):
		var entry: Dictionary = Ecology.SPECIES[i]
		var col := i%4
		var row := int(i/4)
		var left := 26.0+float(col)*312.0
		var top := 72.0+float(row)*207.0
		draw_rect(Rect2(left,top,300.0,194.0),Color("#102333"))
		draw_rect(Rect2(left,top,300.0,194.0),Color("#4b7180"),false,1.2)
		var size: float = minf(172.0,float(entry["length_px"])*0.72)
		Ecology.paint(self,str(entry["id"]),Vector2(left+150.0,top+99.0),
			1.0,time_s+float(i)*0.2,size,0.93)
		draw_string(ThemeDB.fallback_font,Vector2(left+13.0,top+179.0),
			str(entry["name"]),HORIZONTAL_ALIGNMENT_LEFT,275,14,Color("#c8dbd3"))

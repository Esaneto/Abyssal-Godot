extends RefCounted
## Original frame-by-frame procedural anime diver.
## Every part is repainted from animated curves. No pre-rendered static silhouette.
const Doll = preload("res://scripts/diver_paper_doll.gd")
const Look = preload("res://scripts/diver_appearance.gd")

static func _poly(c: CanvasItem, coords: Array, tint: Color) -> void:
	c.draw_colored_polygon(PackedVector2Array(coords),tint)

static func _line(c: CanvasItem, a: Vector2, b: Vector2, col: Color, width: float = 1.8) -> void:
	c.draw_line(a,b,col,width,true)

static func _oval(c: CanvasItem, center: Vector2, radii: Vector2, tint: Color, segments: int = 26) -> void:
	var p := PackedVector2Array()
	for j in range(segments):
		var angle := TAU*float(j)/float(segments)
		p.append(center+Vector2(cos(angle)*radii.x,sin(angle)*radii.y))
	c.draw_colored_polygon(p,tint)

static func paint(c: CanvasItem, appearance: Dictionary, t: float, moving: bool,
	propelling: bool, tool: String, extracting: bool, speed: float) -> void:
	# Drawn in local right-facing coordinates. The physics owner rotates all art 360.
	var tones := Look.palette(appearance)
	var suit: Color = Color("#273b50").lerp(tones["cloth"],0.18)
	var accent: Color = tones["accent"].lerp(Color("#90b2b1"),0.59)
	var edge := Color("#607b89")
	var ink := Color("#071522")
	var deep := Color("#152739")
	var brass := Color("#bd9468")
	var phase := t*(6.1 if moving else 1.8)
	var kick := sin(phase)* (9.5 if moving else 2.8)
	var drag := sin(t*1.26)*3.3
	var breathe := sin(t*1.48)*1.25
	# Furthest leg and fin are dark, always connected to hip.
	_line(c,Vector2(-22,11),Vector2(-43,22-kick),ink,16)
	_line(c,Vector2(-21,12),Vector2(-43,21-kick),Color("#2e4758"),10)
	_line(c,Vector2(-43,21-kick),Vector2(-55,23-kick),ink,12)
	_poly(c,[Vector2(-53,14-kick),Vector2(-77,9-kick*1.2),
		Vector2(-81,16-kick*1.2),Vector2(-76,36-kick),
		Vector2(-55,30-kick)],ink)
	_poly(c,[Vector2(-55,17-kick),Vector2(-74,13-kick*1.2),
		Vector2(-73,31-kick),Vector2(-55,27-kick)],Color("#325569"))
	_line(c,Vector2(-69,15-kick),Vector2(-67,30-kick),Color("#718e95"),1.2)
	# Hair sweeps out from under the hood, animated independently from suit.
	if str(appearance.get("hair","long"))!="short":
		var hair_color: Color = Doll.SWIM_HAIR.get(str(appearance.get("hair_color","black")),Color("#45343a"))
		for i in range(4):
			var off := float(i)
			var hair_path := PackedVector2Array([
				Vector2(21,-32+off*2.7),Vector2(-2,-42+off*4),
				Vector2(-29,-48+drag+off*5),Vector2(-53,-44+drag*1.4+off*5),
				Vector2(-71,-40+drag*1.6+off*5)
			])
			c.draw_polyline(hair_path,ink,7.0-off*0.9,true)
			c.draw_polyline(hair_path,hair_color.darkened(0.24+off*0.06),4.0-off*0.5,true)
	# Oxygen tank and backpack, steel highlights and mechanical couplings.
	_poly(c,[Vector2(-31,-27),Vector2(-23,-35),Vector2(3,-36),
		Vector2(11,-27),Vector2(9,-7),Vector2(-30,-8)],ink)
	_poly(c,[Vector2(-25,-29),Vector2(-19,-32),Vector2(3,-32),
		Vector2(6,-26),Vector2(5,-11),Vector2(-25,-11)],Color("#7d8889"))
	_poly(c,[Vector2(-21,-30),Vector2(-15,-30),Vector2(-15,-13),Vector2(-21,-13)],Color("#c1b3a0"))
	_line(c,Vector2(-27,-24),Vector2(9,-24),deep,4.3)
	_line(c,Vector2(-27,-15),Vector2(9,-15),deep,4.1)
	_oval(c,Vector2(-7,-34),Vector2(6,4),brass)
	_line(c,Vector2(-13,-35),Vector2(-13,-40),Color("#d5c2a7"),2.5)
	# Anatomically tapered upper body with a three-plane inked wetsuit.
	_poly(c,[Vector2(-34,-18),Vector2(-14,-25),Vector2(12,-23),
		Vector2(27,-9),Vector2(22,9),Vector2(8,23),
		Vector2(-23,24),Vector2(-36,7)],ink)
	_poly(c,[Vector2(-29,-16),Vector2(-12,-22),Vector2(10,-20),
		Vector2(21,-9),Vector2(17,7),Vector2(5,18),
		Vector2(-22,19),Vector2(-31,6)],suit)
	_poly(c,[Vector2(-23,-13),Vector2(1,-19),Vector2(16,-9),
		Vector2(10,1),Vector2(-11,6)],Color("#496277"))
	_poly(c,[Vector2(-14,7),Vector2(10,3),Vector2(4,17),Vector2(-16,18)],Color("#1a3043"))
	_line(c,Vector2(-27,-13),Vector2(-16,15),edge.darkened(0.33),2.0)
	_line(c,Vector2(-3,-19),Vector2(7,16),Color("#142839"),2.3)
	_line(c,Vector2(-22,14),Vector2(13,13),Color("#527580"),1.2)
	# Utility harness belts and brass metal buckles.
	_line(c,Vector2(-29,-15),Vector2(14,16),deep,5.0)
	_line(c,Vector2(-29,-15),Vector2(14,16),Color("#5d6b70"),1.3)
	_poly(c,[Vector2(-5,0),Vector2(6,0),Vector2(8,9),Vector2(-4,10)],deep)
	c.draw_rect(Rect2(-3,2,8,5),brass)
	# Rear arm behind torso.
	_line(c,Vector2(6,10),Vector2(24,16+breathe),ink,13)
	_line(c,Vector2(6,10),Vector2(24,16+breathe),Color("#2a4658"),8.6)
	_line(c,Vector2(24,16+breathe),Vector2(34,10+breathe),deep,8)
	# Foreground shin and near-fin: alternating swimming stroke.
	_line(c,Vector2(-20,13),Vector2(-43,26+kick),ink,17)
	_line(c,Vector2(-20,13),Vector2(-43,26+kick),Color("#374f60"),12)
	_line(c,Vector2(-43,26+kick),Vector2(-56,28+kick),ink,13)
	_poly(c,[Vector2(-52,21+kick),Vector2(-76,16+kick*1.12),
		Vector2(-81,23+kick*1.12),Vector2(-76,39+kick),
		Vector2(-55,37+kick)],ink)
	_poly(c,[Vector2(-54,23+kick),Vector2(-72,20+kick*1.12),
		Vector2(-73,34+kick),Vector2(-54,32+kick)],Color("#426379"))
	_line(c,Vector2(-70,22+kick),Vector2(-67,34+kick),Color("#7695a4"),1.2)
	# Neck seal and face profile, not a round helmet glued to the torso.
	_poly(c,[Vector2(18,-27),Vector2(31,-35),Vector2(42,-32),
		Vector2(51,-24),Vector2(51,-13),Vector2(43,-5),
		Vector2(29,-7),Vector2(20,-14)],ink)
	_poly(c,[Vector2(27,-29),Vector2(34,-33),Vector2(43,-30),
		Vector2(49,-22),Vector2(48,-15),Vector2(41,-8),
		Vector2(30,-11),Vector2(24,-19)],Color("#c18b75"))
	_poly(c,[Vector2(28,-26),Vector2(39,-32),Vector2(44,-30),
		Vector2(32,-23)],Color("#e1ab8b"))
	_poly(c,[Vector2(41,-12),Vector2(46,-14),Vector2(45,-10),
		Vector2(39,-8)],Color("#8c5d57"))
	# Expressive anime eye and eyebrow remain readable under transparent goggles.
	_line(c,Vector2(35,-25),Vector2(44,-26),Color("#422e33"),2.5)
	_line(c,Vector2(37,-22),Vector2(43,-23),Color("#192834"),1.8)
	c.draw_circle(Vector2(41,-21),1.2,Color("#101822"))
	c.draw_circle(Vector2(41.3,-21.4),0.48,Color("#f5eee5"))
	# Hairline: fringe sticks to mask frame while ends float behind.
	_poly(c,[Vector2(23,-27),Vector2(31,-36),Vector2(44,-36),
		Vector2(48,-30),Vector2(38,-30),Vector2(33,-24),
		Vector2(30,-27),Vector2(24,-24)],ink)
	_poly(c,[Vector2(26,-29),Vector2(34,-35),Vector2(43,-33),
		Vector2(39,-30),Vector2(34,-30),Vector2(30,-26)],
		Color("#554044") if str(appearance.get("hair_color","black"))!="black" else Color("#25303b"))
	# Goggle rim with glass sheen showing the eye.
	_line(c,Vector2(31,-28),Vector2(48,-26),accent.darkened(0.26),3.2)
	_line(c,Vector2(31,-17),Vector2(48,-17),accent.darkened(0.26),2.4)
	_line(c,Vector2(31,-28),Vector2(31,-17),deep,3.2)
	_line(c,Vector2(48,-26),Vector2(48,-17),deep,2.3)
	_poly(c,[Vector2(34,-27),Vector2(46,-26),
		Vector2(45,-23),Vector2(35,-24)],Color(0.68,0.92,0.95,0.29))
	# Regulator and tubular air hose.
	_oval(c,Vector2(50,-11),Vector2(5.7,5.2),ink)
	_oval(c,Vector2(51,-11),Vector2(3.1,3),Color("#6b9396"))
	c.draw_arc(Vector2(19,-18),22.0,PI*0.04,PI*0.7,18,ink,4.0,true)
	# Nearest arm, gauntlet and wrist telemetry.
	_line(c,Vector2(16,-4),Vector2(34,4+breathe),ink,14.0)
	_line(c,Vector2(16,-4),Vector2(34,4+breathe),suit.lightened(0.19),10.0)
	_line(c,Vector2(34,4+breathe),Vector2(49,7+breathe),ink,11.0)
	_line(c,Vector2(34,4+breathe),Vector2(49,7+breathe),Color("#4c6776"),7.0)
	_poly(c,[Vector2(26,0+breathe),Vector2(33,1+breathe),
		Vector2(35,6+breathe),Vector2(28,6+breathe)],brass.darkened(0.16))
	_line(c,Vector2(30,1+breathe),Vector2(33,2+breathe),Color("#82dad0"),1.3)
	_oval(c,Vector2(49,7+breathe),Vector2(5,4.3),deep)
	# Focused localized anime highlights and clothing seams.
	_line(c,Vector2(-28,-17),Vector2(-15,-21),accent,1.1)
	_line(c,Vector2(7,-18),Vector2(20,-8),Color(0.66,0.83,0.85,0.56),1.0)
	_oval(c,Vector2(-25,4),Vector2(2.5,2.5),accent)
	# Animated tool geometry respects the same model and orientation as the swimmer.
	match tool:
		"abyssPickaxe":
			var move := sin(t*10.0)*0.16 if extracting else 0.0
			var h := Vector2(52,10+breathe)
			_line(c,h,h+Vector2(24,23).rotated(move),Color("#382d30"),7.2)
			_line(c,h,h+Vector2(24,23).rotated(move),brass,3.8)
			_poly(c,[h+Vector2(19,15).rotated(move),h+Vector2(17,-5).rotated(move),
				h+Vector2(34,-14).rotated(move),h+Vector2(36,-5).rotated(move),
				h+Vector2(27,19).rotated(move)],Color("#b8c3c1"))
			_line(c,h+Vector2(19,-3).rotated(move),h+Vector2(33,-9).rotated(move),Color("#6b999e"),1.5)
		"emptyCylinder":
			c.draw_rect(Rect2(51,-4,14,29),ink)
			c.draw_rect(Rect2(54,-1,8,23),Color("#3a6876"))
			c.draw_rect(Rect2(54,8,8,13),Color("#69a79d"))
			_line(c,Vector2(54,-4),Vector2(61,-4),brass,2.4)
		"propulsionUnit":
			_poly(c,[Vector2(-31,13),Vector2(-53,8),Vector2(-68,10),
				Vector2(-76,22),Vector2(-68,33),Vector2(-41,27)],ink)
			_poly(c,[Vector2(-41,14),Vector2(-57,12),Vector2(-69,18),
				Vector2(-70,27),Vector2(-45,25)],Color("#425d68"))
			c.draw_arc(Vector2(-69,21),9.0,0,TAU,19,Color("#c1c4b6"),2.0,true)
			c.draw_circle(Vector2(-69,21),4.0,Color("#2b6972"))
			_line(c,Vector2(-57,13),Vector2(-46,16),brass,2.2)
			if propelling:
				for j in range(4):
					var a := float(j)
					_line(c,Vector2(-78-a*2,17+a*2),Vector2(-97-a*9+sin(t*15+a)*4.0,17+a*4),
						Color(0.60,0.88,0.94,0.18),2.4)
	# Small regular breathing bubbles stay tied to the mouth/regulator.
	for j in range(3):
		var rise := fposmod(t*(11.0+float(j)*2.3)+float(j)*23.0,65.0)
		var p := Vector2(54.0+sin(t*0.7+float(j))*3.8,-12.0-rise)
		c.draw_arc(p,1.7+float(j)*0.48,0,TAU,12,Color(0.67,0.91,0.94,0.36),0.9,true)

extends RefCounted
## Shared biological field guide + procedural creature artwork for the expedition.
## Distinct silhouettes, no shooter mechanics. Depths in approximate GAME meters.
## A creature's illustrated longest dimension is never < 40% of the diver length.

const MANTA_SKIN = preload("res://assets/art/fauna/manta_biological_skin.webp")
const EAGLE_SKIN = preload("res://assets/art/fauna/eagle_biological_skin.webp")
const TURTLE_SKIN = preload("res://assets/art/fauna/turtle_carpax_skin.webp")
const DIVER_LENGTH_PX := 104.0
const MIN_LENGTH_PX := DIVER_LENGTH_PX * 0.4

const SPECIES := [
	{
		"id": "manta", "name": "Raia-manta-oceanica",
		"scientific": "Mobula birostris",
		"zone": "Zona iluminada", "min_m": 0.0, "max_m": 250.0,
		"length_px": 260.0, "temperament": "Curiosa e pacifica",
		"habitat": "Coluna de agua aberta, proxima de areas produtivas.",
		"how_to_find": "Explore as correntes iluminadas, longe de rochas.",
		"story": "Filtra plancton; suas asas desenham sombras enormes."
	},
	{
		"id": "eagle_ray", "name": "Raia-pintada",
		"scientific": "Aetobatus narinari",
		"zone": "Talude tropical", "min_m": 0.0, "max_m": 185.0,
		"length_px": 160.0, "temperament": "Pacifica e cautelosa",
		"habitat": "Recifes costeiros e aguas abertas sobre o talude.",
		"how_to_find": "Explore os recifes iluminados e bordas rochosas entre 0 e 185 m.",
		"story": "Nadadeiras largas e manchas claras distinguem a raia-pintada."
	},
	{
		"id": "turtle", "name": "Tartaruga-verde",
		"scientific": "Chelonia mydas",
		"zone": "Zona iluminada", "min_m": 0.0, "max_m": 180.0,
		"length_px": 111.0, "temperament": "Reservada",
		"habitat": "Costas rasas, bancos de algas e areas oceanicas.",
		"how_to_find": "Procure perto do talude raso e dos campos de algas.",
		"story": "Cruza grandes distancias e retorna para respirar."
	},
	{
		"id": "jelly", "name": "Medusa-luminosa",
		"scientific": "Pelagia noctiluca",
		"zone": "Coluna de agua", "min_m": 0.0, "max_m": 900.0,
		"length_px": 85.0, "temperament": "Deriva com as correntes",
		"habitat": "Agua aberta, em varias profundidades.",
		"how_to_find": "Observe correntes e brilhos entre a superficie e a penumbra.",
		"story": "Uma pulsacao delicada esconde tentaculos urticantes."
	},
	{
		"id": "oarfish", "name": "Peixe-remo",
		"scientific": "Regalecus glesne",
		"zone": "Penumbra", "min_m": 200.0, "max_m": 1000.0,
		"length_px": 440.0, "temperament": "Esquivo",
		"habitat": "Agua oceanica profunda, longe de recifes rasos.",
		"how_to_find": "Desca alem de 200 m; observe silhuetas longas no vazio.",
		"story": "Seu corpo prateado se move como uma fita sem fim."
	},
	{
		"id": "viper", "name": "Peixe-vibora",
		"scientific": "Chauliodus sloani",
		"zone": "Penumbra", "min_m": 300.0, "max_m": 1250.0,
		"length_px": 87.0, "temperament": "Predador de emboscada",
		"habitat": "Agua escura da zona mesopelagica e abaixo.",
		"how_to_find": "Desca alem de 300 m e procure fotoforos na escuridao.",
		"story": "Dentes exagerados e pontos luminosos no ventre."
	},
	{
		"id": "vampire", "name": "Lula-vampira",
		"scientific": "Vampyroteuthis infernalis",
		"zone": "Penumbra profunda", "min_m": 600.0, "max_m": 1100.0,
		"length_px": 124.0, "temperament": "Defensiva e lenta",
		"habitat": "Coluna de agua pobre em oxigenio, longe da luz.",
		"how_to_find": "Entre 600 e 1000 m, observe movimentos lentos no escuro.",
		"story": "Sua capa vermelha forma um guarda-chuva escuro."
	},
	{
		"id": "angler", "name": "Tamboril-abissal",
		"scientific": "Melanocetus johnsonii",
		"zone": "Escuridao", "min_m": 750.0, "max_m": 2000.0,
		"length_px": 97.0, "temperament": "Predador solitario",
		"habitat": "Aguas profundas, onde a luz solar ja desapareceu.",
		"how_to_find": "Alem de 750 m; pequenas iscas luminosas denunciam sua presenca.",
		"story": "Uma isca luminosa chama criaturas para a mandibula."
	},
	{
		"id": "isopod", "name": "Isopode-gigante",
		"scientific": "Bathynomus giganteus",
		"zone": "Fundo profundo", "min_m": 220.0, "max_m": 2200.0,
		"length_px": 95.0, "temperament": "Necrófago de fundo",
		"habitat": "Sedimentos escuros e encostas profundas.",
		"how_to_find": "Siga o solo nas profundezas e procure placas segmentadas.",
		"story": "Uma armadura segmentada percorre o solo silencioso."
	},
	{
		"id": "gulper", "name": "Enguia-pelicano",
		"scientific": "Eurypharynx pelecanoides",
		"zone": "Abismo", "min_m": 600.0, "max_m": 2200.0,
		"length_px": 185.0, "temperament": "Cacadora discreta",
		"habitat": "Coluna de agua profunda, longe das superficies iluminadas.",
		"how_to_find": "Siga os lampejos solitarios e observe mandibulas desproporcionais.",
		"story": "Uma boca enorme e uma cauda finissima definem seu perfil."
	},
	{
		"id": "seapig", "name": "Porco-do-mar",
		"scientific": "Scotoplanes globosa",
		"zone": "Planicie abissal", "min_m": 1000.0, "max_m": 2200.0,
		"length_px": 89.0, "temperament": "Detritivoro pacifico",
		"habitat": "Sedimentos ricos em materia organica no fundo abissal.",
		"how_to_find": "Inspecione o solo frio, alem de mil metros simulados.",
		"story": "Apêndices quase transparentes vasculham o sedimento lentamente."
	}
]

static func get_species(species_id: String) -> Dictionary:
	for entry in SPECIES:
		if entry["id"] == species_id:
			return entry
	return {}

static func candidates_at(depth_m: float, seabed_distance_px: float) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for entry in SPECIES:
		if depth_m >= float(entry["min_m"]) and depth_m <= float(entry["max_m"]):
			if not (entry["id"] in ["isopod", "seapig"]) or seabed_distance_px < 220.0:
				pool.append(entry)
	return pool

static func _oval(canvas: Node2D, c: Vector2, radii: Vector2, tint: Color) -> void:
	var vertices := PackedVector2Array()
	for k in range(33):
		var a := TAU * float(k) / 32.0
		vertices.append(c + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	canvas.draw_colored_polygon(vertices, tint)

static func _poly(canvas: Node2D, vertices: Array, tint: Color) -> void:
	canvas.draw_colored_polygon(PackedVector2Array(vertices), tint)

static func _line(canvas: Node2D, a: Vector2, b: Vector2, tint: Color, weight: float = 2.0) -> void:
	canvas.draw_line(a, b, tint, weight, true)

static func paint(canvas: Node2D, species_id: String, pos: Vector2, direction: float, time_s: float, size_px: float, light: float) -> void:
	# All local silhouettes are about 100px long, uniformly scaled into world units.
	# Over-sized species retain their spectacular scale, even beyond the viewport.
	var scale_factor := maxf(size_px, MIN_LENGTH_PX) / 100.0
	var sign_x := 1.0 if direction >= 0.0 else -1.0
	canvas.draw_set_transform(pos, 0.0, Vector2(sign_x * scale_factor, scale_factor))
	var breathe := sin(time_s * 1.7 + pos.x * 0.005)
	var dark := Color("#0b2232")
	var silver := Color("#8fb8bc").lerp(Color("#223b48"), 1.0 - light)
	var glow := Color("#57dce8")
	match species_id:

		"manta":
			# Fluid hydrofoil outline instead of the angular placeholder polygon.
			var flap := 7.5*sin(time_s*1.22+pos.x*0.005)
			var body := _smooth_outline(PackedVector2Array([
				Vector2(-47,0),Vector2(-34,-8),Vector2(-30,-17),
				Vector2(-16,-32-flap),Vector2(3,-40-flap*0.7),
				Vector2(20,-24),Vector2(42,-9),Vector2(52,-3),
				Vector2(54,3),Vector2(42,9),Vector2(19,23),
				Vector2(3,39+flap*0.7),Vector2(-18,30+flap),
				Vector2(-31,12),Vector2(-35,5)
			]),6)
			canvas.draw_colored_polygon(body,Color("#172c3a"))
			_skin_on_living_mesh(canvas,body,MANTA_SKIN,Rect2(-70,-58,133,115))
			var mantle := _smooth_outline(PackedVector2Array([
				Vector2(-39,-1),Vector2(-18,-10),Vector2(1,-22-flap*0.35),
				Vector2(24,-16),Vector2(44,-5),Vector2(45,5),
				Vector2(24,14),Vector2(1,23+flap*0.35),
				Vector2(-19,11)
			]),5)
			canvas.draw_colored_polygon(mantle,Color(0.15,0.26,0.32,0.14+light*0.07))
			var tipshade := _smooth_outline(PackedVector2Array([
				Vector2(-26,-9),Vector2(-16,-31-flap),Vector2(2,-38-flap*0.7),
				Vector2(12,-25),Vector2(6,-17),Vector2(-7,-13)
			]),4)
			canvas.draw_colored_polygon(tipshade,Color(0.19,0.36,0.44,0.56))
			var lower_shade := _smooth_outline(PackedVector2Array([
				Vector2(-25,10),Vector2(-17,30+flap),Vector2(3,38+flap*0.7),
				Vector2(13,24),Vector2(6,17),Vector2(-7,13)
			]),4)
			canvas.draw_colored_polygon(lower_shade,Color(0.09,0.21,0.28,0.63))
			canvas.draw_polyline(body,Color(0.54,0.70,0.74,0.65),1.4,true)
			_oval(canvas,Vector2(29,0),Vector2(20,7),Color("#728f92").lerp(Color("#425e68"),1.0-light*0.50))
			_line(canvas,Vector2(-35,0),Vector2(-78,sin(time_s*1.1)*7.0),Color("#496877"),1.8)
			# Cartilage ribs track the fin; the animal visibly flexes as it swims.
			for k in range(4):
				var a := float(k)/4.0
				_line(canvas,Vector2(-11.0+k*6.0,-4.0),Vector2(0.0+k*3.0,-(19.0+a*14.0)-flap*a*0.65),
					Color(0.68,0.82,0.82,0.21),0.8)
				_line(canvas,Vector2(-11.0+k*6.0,4.0),Vector2(0.0+k*3.0,(19.0+a*14.0)+flap*a*0.65),
					Color(0.55,0.72,0.74,0.18),0.8)
			canvas.draw_circle(Vector2(39,-3),2.4,Color("#0c2028"))
			canvas.draw_circle(Vector2(39.6,-3.5),0.85,Color("#d0e3dc"))
			for side in [-1.0,1.0]:
				for k in range(4):
					_line(canvas,Vector2(15.0-float(k)*4.0,side*(5.0+float(k)*0.4)),
						Vector2(13.0-float(k)*4.0,side*(8.0+float(k)*0.65)),Color("#223c48"),1.05)
			_line(canvas,Vector2(48,2),Vector2(53,4),Color("#95b0a7"),1.0)

		"eagle_ray":
			var flap := 8.5*sin(time_s*1.48+pos.x*0.004)
			var outline := _smooth_outline(PackedVector2Array([
				Vector2(-41,0),Vector2(-27,-9),Vector2(-17,-22-flap),
				Vector2(4,-35-flap),Vector2(20,-26),Vector2(38,-10),
				Vector2(51,-2),Vector2(54,3),Vector2(40,10),
				Vector2(21,25),Vector2(3,34+flap),
				Vector2(-17,22+flap),Vector2(-27,9)
			]),6)
			canvas.draw_colored_polygon(outline,Color("#172d3a"))
			_skin_on_living_mesh(canvas,outline,EAGLE_SKIN,Rect2(-65,-53,129,106))
			var upper := _smooth_outline(PackedVector2Array([
				Vector2(-35,-1),Vector2(-15,-11),Vector2(3,-28-flap*0.7),
				Vector2(25,-16),Vector2(45,0),Vector2(25,13),
				Vector2(3,28+flap*0.7),Vector2(-15,12)
			]),6)
			canvas.draw_colored_polygon(upper,Color(0.16,0.33,0.36,0.12+light*0.06))
			canvas.draw_polyline(outline,Color(0.50,0.75,0.76,0.65),1.3,true)
			_line(canvas,Vector2(-38,0),Vector2(-117,sin(time_s*0.97)*10.0),Color("#405e6c"),1.7)
			for k in range(29):
				var angle := float(k)*2.399963
				var radius := sqrt(float(k)/29.0)
				var x := -12.0+cos(angle)*radius*25.0
				var y := sin(angle)*radius*(11.0+flap*0.18)
				canvas.draw_circle(Vector2(x,y),0.90+float(k%3)*0.23,
					Color(0.76,0.88,0.82,0.50+light*0.20))
			_oval(canvas,Vector2(33,0),Vector2(15,5),Color("#6b9696"))
			canvas.draw_circle(Vector2(40,-2),2.0,Color("#112a32"))
			for k in range(5):
				_line(canvas,Vector2(19-float(k)*4.0,3),Vector2(18-float(k)*4.0,7),
					Color("#274554"),1.0)
		"turtle":
			# Anatomical swimming silhouette: separate flippers, scute polygons, head.
			var flap := sin(time_s * 1.52 + pos.x * 0.004) * 9.0
			# Far flippers under the shell.
			_poly(canvas,[Vector2(-18,2),Vector2(-43,17+flap),
				Vector2(-44,26+flap),Vector2(-7,17)],Color("#4e8c79"))
			_poly(canvas,[Vector2(9,7),Vector2(27,22-flap),
				Vector2(20,38-flap),Vector2(-4,17)],Color("#528b7d"))
			# Pointed little tail behind an asymmetrical but solid oval shell.
			_poly(canvas,[Vector2(-28,-2),Vector2(-47,-12),Vector2(-42,3)],Color("#6fa88f"))
			_oval(canvas,Vector2(-4,0),Vector2(29,23),Color("#1c5458"))
			_oval(canvas,Vector2(-4,-2),Vector2(26,20),Color("#70aa85"))
			_oval(canvas,Vector2(-4,-2),Vector2(23,17),Color("#437879"))
			# Natural scute pigment follows shell as flippers animate.
			canvas.draw_texture_rect(TURTLE_SKIN,Rect2(-31,-24,54,43),false,Color(1,1,1,0.84))
			# Five animated shell seams remain independent of the skin.
			for k in range(5):
				var theta := TAU*float(k)/5.0
				var x := -4.0+cos(theta)*13.0
				var y := -2.0+sin(theta)*9.0
				_poly(canvas,[Vector2(x-6,y),Vector2(x-3,y-5),Vector2(x+4,y-5),
					Vector2(x+7,y),Vector2(x+4,y+5),Vector2(x-3,y+5)],
					Color("#346d72") if k%2==0 else Color("#508d80"))
				canvas.draw_arc(Vector2(x,y),5.7,0,TAU,6,Color(0.78,0.94,0.63,0.62),1.2,true)
			canvas.draw_arc(Vector2(-4,0),28,0,TAU,34,Color(0.16,0.93,0.86,0.10),6.5,true)
			canvas.draw_arc(Vector2(-4,0),28,0,TAU,34,Color(0.73,0.99,0.78,0.70),1.9,true)
			# Near forelimbs rhythmically lift through the water.
			_poly(canvas,[Vector2(8,-9),Vector2(20,-25-flap),
				Vector2(34,-32-flap),Vector2(31,-18-flap),
				Vector2(18,2)],Color("#7db99a"))
			_line(canvas,Vector2(12,-8),Vector2(31,-25-flap),
				Color("#b8e7ad"),1.7)
			_poly(canvas,[Vector2(-20,-9),Vector2(-39,-28+flap),
				Vector2(-34,-34+flap),Vector2(-8,-19)],Color("#5b9f88"))
			# Tapered neck, observable eye and living head profile.
			_oval(canvas,Vector2(24,0),Vector2(18,11),Color("#6dac98"))
			_oval(canvas,Vector2(34,0),Vector2(12,9),Color("#9dc8a6"))
			canvas.draw_arc(Vector2(34,0),11,PI*0.20,PI*1.72,17,
				Color(0.78,0.99,0.85,0.45),1.5,true)
			canvas.draw_circle(Vector2(38,-3),2.5,Color("#122b39"))
			canvas.draw_circle(Vector2(38.6,-3.5),0.9,Color("#d5fff0"))
			_line(canvas,Vector2(43,4),Vector2(48,3),Color("#386c70"),1.3)
		"jelly":
			for j in range(8):
				var ox := -25.0 + float(j) * 7.0
				_line(canvas, Vector2(ox, 4), Vector2(ox + sin(time_s * 2.0 + j) * 9.0, 44.0 + float(j % 3) * 7), Color(0.35, 0.87, 0.95, 0.6), 1.5)
			_oval(canvas, Vector2(0, -5 - breathe * 3.0), Vector2(37, 22), Color(0.18, 0.53, 0.68, 0.67))
			_oval(canvas, Vector2(0, -15 - breathe * 3.0), Vector2(28, 8), Color(0.58, 0.86, 0.95, 0.48))
			_line(canvas, Vector2(-32, 2), Vector2(32, 2), glow, 1.5)
		"oarfish":
			var ribbon: Array[Vector2] = []
			for j in range(15):
				var px := -50.0 + float(j) * 7.2
				var curve := sin(time_s * 1.45 + float(j) * 0.65) * 6.0
				ribbon.append(Vector2(px, curve - 6.0))
			for j in range(14, -1, -1):
				var px := -50.0 + float(j) * 7.2
				var curve := sin(time_s * 1.45 + float(j) * 0.65) * 6.0
				ribbon.append(Vector2(px, curve + 6.0))
			_poly(canvas, ribbon, silver)
			for j in range(2, 14):
				var px := -50.0 + float(j) * 7.2
				var curve := sin(time_s * 1.45 + float(j) * 0.65) * 6.0
				_line(canvas, Vector2(px, curve - 5.0), Vector2(px - 3.0, curve - 16.0 - (j % 3) * 3.0), Color("#ba4d62"), 1.5)
			canvas.draw_circle(Vector2(43, -1), 2.6, dark)
		"viper":
			_poly(canvas, [Vector2(-48, 0), Vector2(-35, -17), Vector2(-28, -7),
				Vector2(20, -14), Vector2(47, -2), Vector2(28, 18), Vector2(-29, 9)], Color("#243441"))
			_oval(canvas, Vector2(6, 0), Vector2(34, 15), Color("#516275").lerp(Color("#213443"), 0.5))
			_poly(canvas, [Vector2(26, 4), Vector2(49, 0), Vector2(36, 21)], Color("#0a1926"))
			for k in range(4):
				_line(canvas, Vector2(32 + k * 3, 4), Vector2(34 + k * 3, 16 - k), Color("#dbd0b0"), 1.6)
			for k in range(6):
				canvas.draw_circle(Vector2(-21 + k * 8, 8), 2.2, glow)
			canvas.draw_circle(Vector2(27, -7), 3.5, Color("#ffac7b"))
		"vampire":
			var skirt := -8.0 * sin(time_s * 1.2)
			_poly(canvas, [Vector2(34, -11), Vector2(13, -30), Vector2(-25, -23),
				Vector2(-45, -4), Vector2(-38, 29 + skirt),
				Vector2(-11, 21), Vector2(18, 29 + skirt)], Color("#411b37"))
			_poly(canvas, [Vector2(20, -14), Vector2(-23, -12), Vector2(-35, 16),
				Vector2(-8, 10), Vector2(14, 18)], Color("#81374b"))
			for j in range(6):
				_line(canvas, Vector2(-25 + j * 9, 8), Vector2(-39 + j * 12 + sin(time_s + j) * 5, 41), Color("#9e506e"), 2)
			_oval(canvas, Vector2(30, -10), Vector2(10, 13), Color("#a44f58"))
			canvas.draw_circle(Vector2(34, -12), 3.0, Color("#9de8f7"))
		"angler":
			_poly(canvas, [Vector2(-34, 2), Vector2(-53, -16), Vector2(-45, 23), Vector2(-18, 12)], Color("#39434c"))
			_oval(canvas, Vector2(9, 4), Vector2(40, 31), Color("#2f3d4a"))
			_oval(canvas, Vector2(24, 15), Vector2(22, 17), Color("#0c1925"))
			for j in range(6):
				var tx := 9 + j * 7
				_poly(canvas, [Vector2(tx, 8), Vector2(tx + 4, 23), Vector2(tx + 7, 8)], Color("#d7d6c6"))
			_line(canvas, Vector2(8, -24), Vector2(5, -51), Color("#566b79"), 2.8)
			_line(canvas, Vector2(5, -51), Vector2(34, -58 + breathe * 3.0), Color("#566b79"), 2.0)
			canvas.draw_circle(Vector2(34, -58 + breathe * 3.0), 6.0, Color(0.25, 0.92, 0.94, 0.14))
			canvas.draw_circle(Vector2(34, -58 + breathe * 3.0), 2.8, Color("#c8ffef"))
			canvas.draw_circle(Vector2(25, -10), 5.2, Color("#bd956a"))
			canvas.draw_circle(Vector2(27, -10), 1.8, dark) 
		"gulper":
			# Extremely elongated silhouette, disproportionately large hinged jaw.
			var wave := sin(time_s * 1.25 + pos.x * 0.002) * 8.0
			_line(canvas, Vector2(-25, -2), Vector2(-66, wave), Color("#27374c"), 4.0)
			_line(canvas, Vector2(-66, wave), Vector2(-84, wave + sin(time_s * 2.4) * 8.0), Color("#36536b"), 2.2)
			canvas.draw_circle(Vector2(-84, wave + sin(time_s * 2.4) * 8.0), 3.0, Color("#f29f83"))
			_oval(canvas, Vector2(1, -6), Vector2(31, 16), Color("#293548"))
			_poly(canvas, [Vector2(1, -11), Vector2(40, -24), Vector2(49, -7),
				Vector2(27, 19), Vector2(7, 32), Vector2(-12, 16)], Color("#1a2535"))
			_poly(canvas, [Vector2(6, 2), Vector2(44, -1), Vector2(15, 30)],
				Color("#060f1d"))
			_line(canvas, Vector2(13, 27), Vector2(42, 0), Color("#5b6680"), 2.5)
			canvas.draw_circle(Vector2(27, -17), 3.8, Color("#d0bbab"))
			canvas.draw_circle(Vector2(28, -17), 1.8, dark)
		"seapig":
			var feet := sin(time_s * 0.8 + pos.x * 0.003) * 4.0
			for j in range(5):
				var fx := -25.0 + float(j) * 13.0
				_line(canvas, Vector2(fx, 4), Vector2(fx + feet, 29.0 + float(j % 2) * 6.0),
					Color("#928c9b"), 6.0)
			_oval(canvas, Vector2(0, -6), Vector2(41, 19), Color("#91828f"))
			_oval(canvas, Vector2(-10, -11), Vector2(24, 12), Color("#bbacb2"))
			for j in range(4):
				_line(canvas, Vector2(-29.0 + float(j) * 18.0, -13),
					Vector2(-30.0 + float(j) * 20.0 + sin(time_s * 0.9 + j) * 3.0, -34),
					Color("#bcb4b5"), 4.0)
			canvas.draw_circle(Vector2(34, -6), 2.2, Color("#566474"))

		"isopod":
			for j in range(7):
				var sx := -31.0 + float(j) * 10.0
				_oval(canvas, Vector2(sx, 0), Vector2(12, 20 - absf(3.0 - float(j)) * 1.7), Color("#546b70"))
				_line(canvas, Vector2(sx, 11), Vector2(sx - 4, 23), dark, 2.0)
				_line(canvas, Vector2(sx, -10), Vector2(sx - 4, -23), dark, 2.0)
			_oval(canvas, Vector2(36, -2), Vector2(14, 17), Color("#829498"))
			canvas.draw_circle(Vector2(43, -7), 2.1, dark)
			_line(canvas, Vector2(47, -2), Vector2(57, -12), Color("#b6b9ad"), 1.5)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## Closed Catmull-Rom curves give biological bodies rounded fins without static textures.
static func _smooth_outline(points: PackedVector2Array, subdivisions: int = 5) -> PackedVector2Array:
	var n := points.size()
	var result := PackedVector2Array()
	if n < 3:
		return points
	for idx in range(n):
		var p0: Vector2 = points[(idx-1+n)%n]
		var p1: Vector2 = points[idx]
		var p2: Vector2 = points[(idx+1)%n]
		var p3: Vector2 = points[(idx+2)%n]
		for sample in range(subdivisions):
			var t := float(sample)/float(subdivisions)
			var t2 := t*t
			var t3 := t2*t
			result.append(0.5*((p1*2.0)+(-p0+p2)*t+
				(p0*2.0-p1*5.0+p2*4.0-p3)*t2+
				(-p0+p1*3.0-p2*3.0+p3)*t3))
	return result

## Biological pigment is sampled onto a deformed mesh, never just a static sticker.
static func _skin_on_living_mesh(c: CanvasItem, contour: PackedVector2Array,
		tissue: Texture2D, atlas: Rect2) -> void:
	var coords := PackedVector2Array()
	var tint := PackedColorArray()
	for point in contour:
		coords.append(Vector2(
			clampf((point.x-atlas.position.x)/atlas.size.x,0.0,1.0),
			clampf((point.y-atlas.position.y)/atlas.size.y,0.0,1.0)
		))
		tint.append(Color.WHITE)
	c.draw_polygon(contour,tint,coords,tissue)

extends Node3D
## Species-specific articulated 3D biological meshes.
const Shapes = preload("res://scripts/visuals3d/shapes.gd")
var kind := "turtle"
var tail: Node3D
var appendages: Array[Node3D] = []
var light_node: OmniLight3D
var phase := 0.0

func configure(species_id: String, seed_value: float = 0.0) -> void:
	kind = species_id
	phase = seed_value
	match kind:
		"manta", "eagle_ray": _ray()
		"turtle": _turtle()
		"jelly": _jelly()
		"vampire": _vampire()
		"isopod", "seapig": _bottom_crawler()
		"angler": _angler()
		"oarfish", "gulper": _eel()
		_: _fish()

func _eye(p: Vector3, r: float = 0.043) -> void:
	Shapes.ellipsoid(self, "Dark glass eye", p, Vector3(r, r, r * 0.68), Color("#061c2b"), 0.25)
	Shapes.ellipsoid(self, "Eye glint", p + Vector3(-r * 0.35, r * 0.35, r * 0.64), Vector3(r * 0.24, r * 0.24, r * 0.2), Color("#e0fcff"), 0.0, 0.4)

func _fish() -> void:
	var deep := kind == "viper"
	var body := Color("#254e60") if deep else Color("#4298aa")
	Shapes.ellipsoid(self,"Spindle body",Vector3.ZERO,Vector3(0.67,0.29,0.23),body,0.24)
	Shapes.ellipsoid(self,"Silver belly",Vector3(0,-0.13,0.08),Vector3(0.50,0.13,0.18),body.lightened(0.32),0.15)
	Shapes.fin(self,"Dorsal",Vector3(-0.27,0.16,0),Vector3(-0.08,0.63,0),Vector3(0.30,0.20,0),body.darkened(0.38))
	tail = Node3D.new()
	tail.position = Vector3(-0.63,0,0)
	add_child(tail)
	Shapes.fin(tail,"Caudal upper",Vector3.ZERO,Vector3(-0.45,0.42,0),Vector3(-0.27,0.0,0),body.lightened(0.16))
	Shapes.fin(tail,"Caudal lower",Vector3.ZERO,Vector3(-0.44,-0.42,0),Vector3(-0.27,0.0,0),body.darkened(0.12))
	Shapes.fin(self,"Pectoral",Vector3(0.13,0.0,0.17),Vector3(-0.16,-0.23,0.42),Vector3(-0.24,-0.04,0.20),body.lightened(0.15))
	_eye(Vector3(0.42,0.07,0.20))
	for i in range(3):
		Shapes.tube(self,"Gill",Vector3(0.25-float(i)*0.055,0.09,0.215),Vector3(0.24-float(i)*0.055,-0.13,0.23),0.012,body.darkened(0.37))
	if deep:
		for i in range(6):
			Shapes.ellipsoid(self,"Photophore",Vector3(-0.42+float(i)*0.14,-0.20,0.14),Vector3(0.025,0.025,0.022),Color("#72e9f1"),0.0,1.8)
		for i in range(4):
			Shapes.cone(self,"Fang",Vector3(0.49-float(i)*0.13,-0.27,0.07),0.18,0.025,Color("#dcece7"))

func _ray() -> void:
	var dark := Color("#2b5668") if kind == "manta" else Color("#577e78")
	Shapes.ellipsoid(self,"Mantle",Vector3.ZERO,Vector3(0.71,0.14,0.47),dark)
	Shapes.ellipsoid(self,"Pale underside",Vector3(0,-0.08,0),Vector3(0.48,0.08,0.33),Color("#9cb7af"))
	for side in [-1.0,1.0]:
		var wing := Node3D.new()
		wing.position = Vector3(0,0,side*0.37)
		wing.name = "Swimming wing"
		add_child(wing)
		appendages.append(wing)
		Shapes.fin(wing,"Wing",Vector3(0.48,0,0),Vector3(-0.25,0,side*1.57),Vector3(-0.54,0,-side*0.08),dark)
		Shapes.ellipsoid(wing,"Wing thickness",Vector3(-0.16,0,side*0.33),Vector3(0.5,0.035,0.5),dark)
	Shapes.tube(self,"Whip tail",Vector3(-0.59,0,0),Vector3(-2.05,0,0),0.025,dark.darkened(0.2))
	_eye(Vector3(0.43,0.07,0.30),0.035)
	_eye(Vector3(0.43,0.07,-0.30),0.035)
	if kind == "eagle_ray":
		for i in range(10):
			var q := float(i)
			Shapes.ellipsoid(self,"Spots",Vector3(-0.38 + float(i%5)*0.16,0.15,(float(i/5)-0.5)*0.3),Vector3(0.04,0.014,0.035),Color("#d3d9c0"))

func _turtle() -> void:
	Shapes.ellipsoid(self,"Carapace",Vector3(-0.15,0.02,0),Vector3(0.61,0.30,0.46),Color("#60795a"),0.12)
	Shapes.ellipsoid(self,"Shell crown",Vector3(-0.15,0.10,0),Vector3(0.54,0.27,0.39),Color("#3d685b"))
	for i in range(7):
		var a := TAU * float(i) / 7.0
		Shapes.ellipsoid(self,"Scute",Vector3(-0.15+cos(a)*0.26,0.29,sin(a)*0.22),Vector3(0.16,0.025,0.11),Color("#749c76"))
	Shapes.ellipsoid(self,"Head",Vector3(0.63,-0.02,0),Vector3(0.27,0.20,0.21),Color("#91b78c"))
	Shapes.ellipsoid(self,"Beak",Vector3(0.86,-0.10,0),Vector3(0.10,0.08,0.12),Color("#a8c59b"))
	_eye(Vector3(0.72,0.03,0.17),0.045)
	for side in [-1.0,1.0]:
		var paddle := Node3D.new()
		paddle.position = Vector3(0.22,-0.06,side*0.36)
		add_child(paddle)
		appendages.append(paddle)
		Shapes.ellipsoid(paddle,"Front flipper",Vector3(-0.12,-0.06,side*0.46),Vector3(0.30,0.06,0.66),Color("#699b85"))
		Shapes.ellipsoid(self,"Rear flipper",Vector3(-0.55,-0.12,side*0.39),Vector3(0.35,0.065,0.20),Color("#799b7a"))

func _jelly() -> void:
	Shapes.ellipsoid(self,"Translucent bell",Vector3(0,0.18,0),Vector3(0.56,0.27,0.50),Color(0.35,0.68,0.87,0.68),0.0,1.2)
	Shapes.ellipsoid(self,"Umbrella inner",Vector3(0,0.05,0),Vector3(0.39,0.055,0.36),Color(0.76,0.42,0.82,0.78),0.0,0.5)
	for i in range(12):
		var a := TAU * float(i) / 12.0
		var arm := Node3D.new()
		arm.position = Vector3(cos(a)*0.35,0,sin(a)*0.32)
		add_child(arm)
		appendages.append(arm)
		Shapes.tube(arm,"Tentacle",Vector3.ZERO,Vector3(0,-0.6-float(i%4)*0.19,0),0.012,Color("#6dcde2"),0.0,0.6)
	_add_light(Color("#8de0e8"),0.35)

func _vampire() -> void:
	Shapes.ellipsoid(self,"Mantle",Vector3(0.07,0.18,0),Vector3(0.38,0.55,0.36),Color("#682b48"))
	Shapes.ellipsoid(self,"Face",Vector3(0.25,-0.1,0),Vector3(0.28,0.24,0.22),Color("#8d4c69"))
	_eye(Vector3(0.41,-0.05,0.19),0.072)
	for i in range(8):
		var a := TAU*float(i)/8.0
		var tentacle := Node3D.new()
		tentacle.position = Vector3(0,-0.30,0)
		add_child(tentacle)
		appendages.append(tentacle)
		Shapes.tube(tentacle,"Umbrella arm",Vector3.ZERO,Vector3(cos(a)*0.46,-0.64,sin(a)*0.47),0.055,Color("#7f334e"))

func _bottom_crawler() -> void:
	var tissue := Color("#d4b8a5") if kind == "seapig" else Color("#687d8b")
	Shapes.ellipsoid(self,"Segmented mantle",Vector3.ZERO,Vector3(0.65,0.28,0.38),tissue)
	for i in range(7):
		var x := -0.45+float(i)*0.15
		Shapes.ellipsoid(self,"Plate",Vector3(x,0.21,0),Vector3(0.09,0.06,0.32),tissue.darkened(0.12))
		for side in [-1.0,1.0]:
			Shapes.tube(self,"Walking leg",Vector3(x,-0.09,side*0.28),Vector3(x+0.05,-0.42,side*0.44),0.045,tissue)
	_eye(Vector3(0.48,0.11,0.23),0.045)

func _angler() -> void:
	Shapes.ellipsoid(self,"Broad head",Vector3(0.12,0,0),Vector3(0.72,0.46,0.43),Color("#3e4052"))
	Shapes.ellipsoid(self,"Lower jaw",Vector3(0.38,-0.29,0.08),Vector3(0.51,0.17,0.29),Color("#695463"))
	_eye(Vector3(0.44,0.22,0.38),0.053)
	for i in range(7):
		Shapes.cone(self,"Needle teeth",Vector3(0.30+float(i)*0.07,-0.30,0.25),0.18,0.021,Color("#e0ded5"))
	Shapes.tube(self,"Illicium stalk",Vector3(0.25,0.41,0),Vector3(0.70,0.90,0),0.035,Color("#687382"))
	Shapes.ellipsoid(self,"Bioluminescent lure",Vector3(0.76,0.95,0),Vector3(0.12,0.12,0.12),Color("#a9fff0"),0.0,3.0)
	_add_light(Color("#7ff4d5"),0.7)
	tail = Node3D.new()
	tail.position = Vector3(-0.58,0,0)
	add_child(tail)
	Shapes.fin(tail,"Tail",Vector3.ZERO,Vector3(-0.4,0.33,0),Vector3(-0.35,-0.30,0),Color("#494356"))

func _eel() -> void:
	var silver := Color("#a8b7bd") if kind == "oarfish" else Color("#354956")
	for i in range(11):
		var x := -0.14-float(i)*0.20
		var segment := Node3D.new()
		segment.position = Vector3(x,0,0)
		add_child(segment)
		appendages.append(segment)
		Shapes.ellipsoid(segment,"Ribbed body",Vector3.ZERO,Vector3(0.29,maxf(0.07,0.20-float(i)*0.013),0.15),silver)
		if kind == "oarfish":
			Shapes.fin(segment,"Red dorsal streamer",Vector3(-0.10,0.15,0),Vector3(0.09,0.48,0),Vector3(0.17,0.17,0),Color("#d64e62"))
	Shapes.ellipsoid(self,"Deep sea face",Vector3(0.24,0,0),Vector3(0.33,0.24,0.18),silver)
	_eye(Vector3(0.40,0.08,0.15),0.034)

func _add_light(color: Color, energy: float) -> void:
	light_node = OmniLight3D.new()
	light_node.light_color = color
	light_node.light_energy = energy
	light_node.omni_range = 3.2
	add_child(light_node)

func animate(t: float) -> void:
	var beat := t*1.45+phase
	if tail != null:
		tail.rotation.y = sin(beat*2.4)*0.36
	for i in range(appendages.size()):
		var part := appendages[i]
		match kind:
			"turtle", "manta", "eagle_ray": part.rotation.x = sin(beat+float(i)*PI)*0.35
			"jelly": part.rotation.z = sin(beat*0.8+float(i))*0.13
			"vampire": part.rotation.x = sin(beat+float(i)*0.55)*0.20
			_: part.position.y = sin(beat-float(i)*0.58)*0.09
	if kind == "jelly":
		scale.y = 0.96+0.07*sin(beat)

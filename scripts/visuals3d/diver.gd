extends Node3D
## Articulated human diver: live PBR meshes, pose-dependent bones and breathing.
## 3D art is editable and shared between cabin and ocean modes.
const Shapes = preload("res://scripts/visuals3d/shapes.gd")
var pivot: Node3D
var skull: Node3D
var front_hair: Node3D
var rear_hair: Node3D
var arm_l: Node3D
var arm_r: Node3D
var leg_l: Node3D
var leg_r: Node3D
var fin_l: Node3D
var fin_r: Node3D
var tank: MeshInstance3D
var suit_meshes: Array[MeshInstance3D] = []
var mask_glass: MeshInstance3D
var body_id := ""
var look_cache := ""
var last_pose := ""
var tool_visuals: Dictionary = {}

func _ready() -> void:
	pivot = Node3D.new()
	pivot.name = "Animated anatomical rig"
	add_child(pivot)
	_construct()

func _construct() -> void:
	# Torso is deliberately tapered and uses separate waist, shoulder and armor volumes.
	suit_meshes.append(Shapes.ellipsoid(pivot,"Thorax",Vector3(0,1.19,0),Vector3(0.36,0.47,0.24),Color("#163b58"),0.29))
	suit_meshes.append(Shapes.ellipsoid(pivot,"Waist",Vector3(0,0.86,0),Vector3(0.29,0.24,0.22),Color("#1a3851"),0.29))
	Shapes.ellipsoid(pivot,"Shoulder harness",Vector3(0,1.49,-0.03),Vector3(0.44,0.12,0.28),Color("#14273c"),0.28)
	Shapes.box(pivot,"Chest plate",Vector3(0,1.26,0.253),Vector3(0.47,0.31,0.055),Color("#37677a"),0.53)
	Shapes.box(pivot,"Chest equipment",Vector3(0.12,1.27,0.30),Vector3(0.115,0.125,0.07),Color("#d0a25e"),0.45)
	Shapes.ellipsoid(pivot,"Life monitor",Vector3(-0.135,1.30,0.29),Vector3(0.055,0.036,0.017),Color("#54e5df"),0.2,2.0)
	for side in [-1.0,1.0]:
		Shapes.tube(pivot,"Harness strap",Vector3(side*0.23,1.56,0.21),Vector3(side*0.18,0.90,0.24),0.035,Color("#0e2030"),0.20)
		Shapes.ellipsoid(pivot,"Shoulder shell",Vector3(side*0.38,1.47,0),Vector3(0.155,0.15,0.20),Color("#203f5a"),0.20)
		Shapes.ellipsoid(pivot,"Neon shoulder",Vector3(side*0.39,1.51,0.18),Vector3(0.055,0.025,0.03),Color("#61c8cf"),0.05,1.7)
	Shapes.tube(pivot,"Neck seal",Vector3(0,1.52,0),Vector3(0,1.73,0),0.17,Color("#192837"),0.12)
	skull = Node3D.new()
	skull.name = "Head"
	skull.position = Vector3(0,1.75,0)
	pivot.add_child(skull)
	var skin := Color("#b78c75")
	Shapes.ellipsoid(skull,"Face skull",Vector3(0,0.13,0.03),Vector3(0.215,0.265,0.195),skin)
	Shapes.ellipsoid(skull,"Jaw",Vector3(0,-0.045,0.072),Vector3(0.153,0.113,0.165),skin.darkened(0.09))
	Shapes.ellipsoid(skull,"Nose",Vector3(0,0.065,0.228),Vector3(0.038,0.073,0.060),skin.lightened(0.06))
	Shapes.ellipsoid(skull,"Lips",Vector3(0,-0.033,0.208),Vector3(0.064,0.012,0.015),Color("#9b625d"))
	for side in [-1.0,1.0]:
		Shapes.ellipsoid(skull,"Ear",Vector3(side*0.212,0.06,0.01),Vector3(0.038,0.062,0.042),skin)
		Shapes.ellipsoid(skull,"Eye socket",Vector3(side*0.085,0.12,0.213),Vector3(0.061,0.038,0.016),Color("#ebdbca"))
		Shapes.ellipsoid(skull,"Iris",Vector3(side*0.085,0.12,0.229),Vector3(0.028,0.027,0.012),Color("#28404b"),0.15)
		Shapes.ellipsoid(skull,"Pupil",Vector3(side*0.085,0.12,0.239),Vector3(0.012,0.015,0.008),Color("#081722"))
		Shapes.ellipsoid(skull,"Eyebrow",Vector3(side*0.084,0.185,0.218),Vector3(0.074,0.019,0.020),Color("#392d2d"))
	rear_hair = Node3D.new()
	rear_hair.name = "Individual animated hair sections"
	skull.add_child(rear_hair)
	front_hair = Node3D.new()
	skull.add_child(front_hair)
	Shapes.ellipsoid(front_hair,"Natural scalp",Vector3(0,0.33,-0.01),Vector3(0.229,0.136,0.207),Color("#25222b"))
	for i in range(7):
		var xi := (float(i)-3.0)*0.066
		Shapes.ellipsoid(front_hair,"Hair fringe",Vector3(xi,0.264,0.19),Vector3(0.052,0.12+0.03*float(i%2),0.055),Color("#25222b"))
	for side in [-1.0,1.0]:
		for i in range(3):
			var strand := Node3D.new()
			strand.position = Vector3(side*(0.188+float(i)*0.008),0.18,-0.05-float(i)*0.065)
			rear_hair.add_child(strand)
			Shapes.ellipsoid(strand,"Hair lock",Vector3.ZERO,Vector3(0.045,0.23,0.068),Color("#25222b"))
	# Regulator, glass visor, straps and tank are physical separate meshes.
	mask_glass = Shapes.ellipsoid(skull,"Goggle visor",Vector3(0,0.11,0.245),Vector3(0.179,0.098,0.03),Color(0.48,0.86,0.91,0.25),0.20)
	Shapes.ellipsoid(skull,"Regulator",Vector3(0,-0.09,0.255),Vector3(0.105,0.075,0.072),Color("#122438"),0.45)
	for side in [-1.0,1.0]:
		Shapes.tube(skull,"Mask frame",Vector3(side*0.178,0.18,0.25),Vector3(side*0.18,0.01,0.24),0.019,Color("#243b4c"),0.4)
	tank = Shapes.ellipsoid(pivot,"Compressed air tank",Vector3(0,1.13,-0.35),Vector3(0.23,0.48,0.19),Color("#c4d4dd"),0.72)
	Shapes.tube(pivot,"Air valve",Vector3(0,1.56,-0.35),Vector3(0,1.73,-0.35),0.065,Color("#d1a46f"),0.5)
	Shapes.tube(pivot,"Regulator hose",Vector3(0,1.62,-0.36),Vector3(-0.36,1.37,-0.28),0.029,Color("#172b37"))
	Shapes.tube(pivot,"Hose loop",Vector3(-0.36,1.37,-0.28),Vector3(-0.23,1.58,0.16),0.029,Color("#172b37"))
	Shapes.ellipsoid(pivot,"Belt buckle",Vector3(0,0.76,0.22),Vector3(0.105,0.075,0.034),Color("#d0a76b"),0.62)
	arm_l = _arm(-1.0)
	arm_r = _arm(1.0)
	leg_l = _leg(-1.0)
	leg_r = _leg(1.0)
	_build_tools()

func _arm(side: float) -> Node3D:
	var node := Node3D.new()
	node.name = "LeftArm" if side < 0 else "RightArm"
	node.position = Vector3(side*0.41,1.46,0.0)
	pivot.add_child(node)
	suit_meshes.append(Shapes.ellipsoid(node,"Upper arm",Vector3(side*0.055,-0.23,0.02),Vector3(0.145,0.29,0.15),Color("#25435d"),0.10))
	Shapes.ellipsoid(node,"Elbow joint",Vector3(side*0.07,-0.45,0.09),Vector3(0.125,0.12,0.14),Color("#13273b"),0.25)
	suit_meshes.append(Shapes.ellipsoid(node,"Forearm",Vector3(side*0.085,-0.57,0.22),Vector3(0.115,0.22,0.12),Color("#25435d"),0.10))
	Shapes.ellipsoid(node,"Glove",Vector3(side*0.10,-0.74,0.29),Vector3(0.105,0.11,0.095),Color("#111e33"),0.22)
	Shapes.box(node,"Wrist dive computer",Vector3(side*0.12,-0.64,0.35),Vector3(0.12,0.08,0.06),Color("#172c39"),0.42)
	Shapes.box(node,"Animated computer screen",Vector3(side*0.12,-0.64,0.39),Vector3(0.078,0.046,0.014),Color("#6edcdb"),0.12,1.65)
	return node

func _leg(side: float) -> Node3D:
	var node := Node3D.new()
	node.name = "LeftLeg" if side < 0 else "RightLeg"
	node.position = Vector3(side*0.19,0.76,0.0)
	pivot.add_child(node)
	suit_meshes.append(Shapes.ellipsoid(node,"Thigh",Vector3(0,-0.27,0.02),Vector3(0.19,0.35,0.20),Color("#25435d"),0.21))
	Shapes.ellipsoid(node,"Knee guard",Vector3(0,-0.55,0.17),Vector3(0.16,0.15,0.06),Color("#344c64"),0.38)
	suit_meshes.append(Shapes.ellipsoid(node,"Shin",Vector3(0,-0.75,0.06),Vector3(0.145,0.27,0.15),Color("#25435d"),0.21))
	Shapes.ellipsoid(node,"Boot",Vector3(0,-0.99,0.14),Vector3(0.16,0.17,0.25),Color("#152638"),0.28)
	var flipper := Shapes.fin(node,"Swimming fin",Vector3(-0.17,-1.08,0.18),Vector3(0.0,-1.47,0.31),Vector3(0.17,-1.08,0.18),Color("#42788b"))
	flipper.rotation.x = 0.12
	return node

func set_appearance(look: Dictionary) -> void:
	var serialized := JSON.stringify(look)
	if look_cache == serialized:
		return
	look_cache = serialized
	body_id = str(look.get("body","female"))
	pivot.scale.x = 0.95 if body_id == "female" else 1.07
	var tint := Color("#193348")
	match str(look.get("suit","abyss")):
		"tide": tint = Color("#167b80")
		"ember": tint = Color("#ac6a42")
	for mesh in suit_meshes:
		mesh.material_override = Shapes.material(tint,0.08)
	var hair_tint := Color("#49302b")
	match str(look.get("hair_color","copper")):
		"black": hair_tint=Color("#121c27")
		"brown": hair_tint=Color("#544039")
		"silver": hair_tint=Color("#afc1c5")
	var long_hair := str(look.get("hair","long")) != "short" and body_id != "male"
	for lock in rear_hair.get_children():
		lock.visible = long_hair
		lock.scale.y = 1.2 if str(look.get("hair","long")) == "long" else 0.55
		for part in lock.get_children():
			if part is MeshInstance3D:
				part.material_override = Shapes.material(hair_tint)
	for part in front_hair.get_children():
		if part is MeshInstance3D:
			part.material_override = Shapes.material(hair_tint)

func animate(t: float, swimming: bool, moving: bool, facing_right: bool = true, heading: float = 0.0) -> void:
	var beat := t * (5.3 if moving else 1.6)
	var sway := sin(beat)
	if swimming:
		pivot.rotation.z = -PI*0.5 - heading
		pivot.rotation.x = 0.10*sin(t*1.2)
		pivot.position.y = 0.04*sin(t*2.0)
		arm_l.rotation.z = PI-0.07+0.035*sin(beat)
		arm_r.rotation.z = -PI+0.07-0.035*sin(beat+0.8)
		arm_l.rotation.x = -0.22
		arm_r.rotation.x = 0.22
		leg_l.rotation.z = sway*0.24
		leg_r.rotation.z = -sway*0.24
		leg_l.rotation.x = sway*0.13
		leg_r.rotation.x = -sway*0.13
	else:
		pivot.rotation.z = 0.0
		pivot.rotation.x = 0.0
		pivot.position.y = 0.012*sin(t*1.2)
		arm_l.rotation.z = -0.12
		arm_r.rotation.z = 0.12
		arm_l.rotation.x = -0.45+0.04*sin(t*1.3)
		arm_r.rotation.x = -0.45+0.04*sin(t*1.3+0.9)
		leg_l.rotation.z = 0.0
		leg_r.rotation.z = 0.0
		leg_l.rotation.x = -0.75
		leg_r.rotation.x = -0.75
	skull.rotation.z = sin(t*0.72)*0.023
	skull.rotation.x = sin(t*0.81)*0.018
	for i in range(rear_hair.get_child_count()):
		rear_hair.get_child(i).rotation.x = sin(t*1.9+float(i)*0.6)*0.085

func _build_tools() -> void:
	var pick := Node3D.new()
	pick.name = "Articulated mineral cutter"
	pick.position = Vector3(0.37,1.03,0.31)
	pivot.add_child(pick)
	Shapes.tube(pick,"Composite handle",Vector3(0,-0.18,0),Vector3(0,0.31,0),0.045,Color("#926e55"),0.23)
	Shapes.cone(pick,"Steel pickaxe tip",Vector3(0.03,0.28,0),0.32,0.12,Color("#9fc7cb"))
	tool_visuals["abyssPickaxe"] = pick
	var sample := Node3D.new()
	sample.name = "Reusable science cylinder"
	sample.position = Vector3(0.42,0.95,0.31)
	pivot.add_child(sample)
	Shapes.ellipsoid(sample,"Glass cylinder",Vector3.ZERO,Vector3(0.10,0.24,0.10),Color("#2e617c"),0.65)
	Shapes.ellipsoid(sample,"Liquid sample",Vector3(0,-0.075,0.0),Vector3(0.08,0.13,0.08),Color("#63d2bd"),0.0,0.4)
	Shapes.tube(sample,"Golden closure",Vector3(0,0.25,0),Vector3(0,0.30,0),0.11,Color("#d3aa6e"),0.48)
	tool_visuals["emptyCylinder"] = sample
	var jet := Node3D.new()
	jet.name = "Water propulsion machine"
	jet.position = Vector3(-0.05,1.12,-0.44)
	pivot.add_child(jet)
	Shapes.ellipsoid(jet,"Titanium shell",Vector3.ZERO,Vector3(0.22,0.41,0.21),Color("#2f5a68"),0.59)
	Shapes.box(jet,"Protected fins",Vector3(0,0.12,0.15),Vector3(0.32,0.14,0.11),Color("#193b50"),0.25)
	Shapes.ellipsoid(jet,"Battery indicator",Vector3(0,0.29,0.22),Vector3(0.07,0.035,0.04),Color("#68f0e7"),0.1,1.7)
	for side in [-1.0,1.0]:
		Shapes.tube(jet,"Turbine exhaust",Vector3(side*0.13,-0.28,0),Vector3(side*0.13,-0.47,0),0.11,Color("#1b3047"),0.68)
		Shapes.ellipsoid(jet,"Impeller core",Vector3(side*0.13,-0.47,0),Vector3(0.055,0.024,0.055),Color("#6fe3e5"),0.25,0.7)
	tool_visuals["propulsionUnit"] = jet
	_set_tool_visibility("abyssPickaxe")

func _set_tool_visibility(id: String) -> void:
	for key in tool_visuals.keys():
		var node: Node3D = tool_visuals[key]
		node.visible = str(key)==id

func set_tool_state(id: String, propelling: bool, extracting: bool, t: float) -> void:
	_set_tool_visibility(id)
	if tool_visuals.has("abyssPickaxe"):
		(tool_visuals["abyssPickaxe"] as Node3D).rotation.z = sin(t*11.0)*0.27 if extracting and id=="abyssPickaxe" else 0.0
	if tool_visuals.has("propulsionUnit"):
		var node: Node3D = tool_visuals["propulsionUnit"]
		node.scale = Vector3.ONE*(1.0+sin(t*24.0)*0.035 if propelling else 1.0)

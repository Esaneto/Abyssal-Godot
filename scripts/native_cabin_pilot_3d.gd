extends Node2D
## Procedural animated 3D pilot rendered into the 2D cabin through a live SubViewport.
## No flattened diver PNG is used in the cockpit.
const Look = preload("res://scripts/diver_appearance.gd")
var viewport: SubViewport
var avatar: Node3D
var head: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var hair: Node3D
var suit_parts: Array[MeshInstance3D] = []
var clock := 0.0
var current_look := ""
var progress: RefCounted

func _ready() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(520, 600)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.own_world_3d = true
	add_child(viewport)
	var root := Node3D.new()
	viewport.add_child(root)
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 1.50, 5.3)
	camera.look_at_from_position(camera.position, Vector3(0.0, 1.12, 0.0))
	camera.fov = 40.0
	camera.current = true
	root.add_child(camera)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-40, -35, 0)
	key.light_color = Color("#c3f5ff")
	key.light_energy = 2.1
	root.add_child(key)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-1.7, 2.2, 2.0)
	fill.light_color = Color("#5ce8f8")
	fill.light_energy = 1.3
	root.add_child(fill)
	var rim := OmniLight3D.new()
	rim.position = Vector3(1.0, 2.2, -1.0)
	rim.light_color = Color("#f8b96e")
	rim.light_energy = 2.0
	root.add_child(rim)
	avatar = Node3D.new()
	root.add_child(avatar)
	_build_seat(root)
	_build_pilot()
	var sprite := Sprite2D.new()
	sprite.texture = viewport.get_texture()
	sprite.centered = true
	sprite.position = Vector2(193, 438)
	sprite.scale = Vector2(0.72, 0.72)
	add_child(sprite)
	set_process(true)

func _mat(color: Color, metallic := 0.0, emission := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metallic
	m.roughness = 0.34
	if emission:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.9
	return m

func _shape(parent: Node3D, name: String, at: Vector3, scale3: Vector3, color: Color, capsule := false, glow := false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = name
	mesh.mesh = CapsuleMesh.new() if capsule else SphereMesh.new()
	mesh.position = at
	mesh.scale = scale3
	mesh.material_override = _mat(color, 0.12, glow)
	parent.add_child(mesh)
	return mesh

func _build_seat(root: Node3D) -> void:
	_shape(root, "SeatBack", Vector3(0, 1.07, -0.30), Vector3(0.67, 1.0, 0.20), Color("#15233c"), true)
	_shape(root, "SeatHeadrest", Vector3(0, 1.85, -0.30), Vector3(0.45, 0.24, 0.22), Color("#243e5b"))
	_shape(root, "SeatCushion", Vector3(0, 0.56, 0.00), Vector3(0.65, 0.16, 0.48), Color("#233b55"))
	for side in [-1.0, 1.0]:
		_shape(root, "Armrest", Vector3(side * 0.64, 0.76, 0.24), Vector3(0.12, 0.12, 0.47), Color("#405d78"))

func _build_pilot() -> void:
	suit_parts.append(_shape(avatar, "Torso", Vector3(0, 1.12, 0.07), Vector3(0.40, 0.53, 0.27), Color("#1d4566"), true))
	_shape(avatar, "ChestArmor", Vector3(0, 1.28, 0.31), Vector3(0.33, 0.27, 0.09), Color("#294a67"))
	_shape(avatar, "Neck", Vector3(0, 1.65, 0.06), Vector3(0.12, 0.14, 0.12), Color("#bd8e72"))
	head = Node3D.new()
	head.position = Vector3(0, 1.79, 0.08)
	avatar.add_child(head)
	_shape(head, "Face", Vector3(0, 0.08, 0.08), Vector3(0.245, 0.31, 0.225), Color("#c89b7f"))
	_shape(head, "HairCap", Vector3(0, 0.28, 0.01), Vector3(0.27, 0.17, 0.245), Color("#3c282b"))
	hair = Node3D.new()
	head.add_child(hair)
	for side in [-1.0, 1.0]:
		_shape(head, "Eye", Vector3(side * 0.10, 0.10, 0.274), Vector3(0.045, 0.034, 0.014), Color("#172b40"))
		_shape(head, "Brow", Vector3(side * 0.10, 0.16, 0.270), Vector3(0.075, 0.016, 0.015), Color("#35262a"))
		_shape(hair, "HairStrand", Vector3(side * 0.24, -0.14, 0.0), Vector3(0.075, 0.32, 0.09), Color("#3c282b"), true)
	_shape(head, "Nose", Vector3(0, 0.025, 0.303), Vector3(0.039, 0.064, 0.043), Color("#b9816b"))
	_shape(head, "Mouth", Vector3(0, -0.085, 0.285), Vector3(0.075, 0.013, 0.009), Color("#834c4d"))
	left_arm = _limb("LeftArm", -1.0)
	right_arm = _limb("RightArm", 1.0)
	left_leg = _leg("LeftLeg", -1.0)
	right_leg = _leg("RightLeg", 1.0)
	_shape(avatar, "Belt", Vector3(0, 0.72, 0.14), Vector3(0.40, 0.09, 0.28), Color("#0b1a30"))
	for side in [-1.0, 1.0]:
		_shape(avatar, "ShoulderLight", Vector3(side * 0.37, 1.43, 0.26), Vector3(0.07, 0.06, 0.06), Color("#5af0ef"), false, true)

func _limb(label: String, side: float) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = label
	pivot.position = Vector3(side * 0.42, 1.48, 0.06)
	avatar.add_child(pivot)
	suit_parts.append(_shape(pivot, "UpperArm", Vector3(side * 0.09, -0.25, 0.11), Vector3(0.16, 0.34, 0.17), Color("#1d4566"), true))
	_shape(pivot, "Glove", Vector3(side * 0.17, -0.46, 0.39), Vector3(0.13, 0.14, 0.14), Color("#14263c"))
	return pivot

func _leg(label: String, side: float) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = label
	pivot.position = Vector3(side * 0.21, 0.77, 0.05)
	avatar.add_child(pivot)
	suit_parts.append(_shape(pivot, "Thigh", Vector3(0, -0.12, 0.34), Vector3(0.19, 0.22, 0.42), Color("#1d4566"), true))
	_shape(pivot, "Boot", Vector3(0, -0.43, 0.48), Vector3(0.20, 0.25, 0.25), Color("#14263c"), true)
	return pivot

func _process(delta: float) -> void:
	clock += delta
	if progress == null:
		return
	var look: Dictionary = progress.appearance_snapshot()
	var key := JSON.stringify(look)
	if key != current_look:
		current_look = key
		_apply_look(look)
	avatar.position.y = sin(clock * 1.4) * 0.009
	avatar.rotation.y = sin(clock * 0.43) * 0.035
	head.rotation.z = sin(clock * 0.73) * 0.022
	head.rotation.x = sin(clock * 0.82) * 0.028
	left_arm.rotation.x = -0.29 + sin(clock * 1.25) * 0.045
	right_arm.rotation.x = -0.29 + sin(clock * 1.25 + 0.6) * 0.045
	left_leg.rotation.x = sin(clock * 0.65) * 0.012
	right_leg.rotation.x = sin(clock * 0.65 + 1.0) * 0.012

func _apply_look(look: Dictionary) -> void:
	var female := str(look.get("body", "female")) == "female"
	var color := Color("#244e77")
	match str(look.get("suit", "abyss")):
		"tide": color = Color("#238b8b")
		"ember": color = Color("#a96735")
	for part in suit_parts:
		part.material_override = _mat(color, 0.25)
	avatar.scale.x = 0.94 if female else 1.05
	var hair_color := Color("#3c282b")
	match str(look.get("hair_color", "copper")):
		"black": hair_color = Color("#1c2535")
		"silver": hair_color = Color("#b6c6cf")
		"brown": hair_color = Color("#584037")
		_: hair_color = Color("#9a5739")
	for strand in hair.get_children():
		if strand is MeshInstance3D:
			strand.material_override = _mat(hair_color)
			strand.visible = str(look.get("hair", "long")) != "short"
			strand.scale.y = 0.32 if str(look.get("hair", "long")) == "long" else 0.16
	var cap := head.get_node_or_null("HairCap") as MeshInstance3D
	if cap != null:
		cap.material_override = _mat(hair_color)

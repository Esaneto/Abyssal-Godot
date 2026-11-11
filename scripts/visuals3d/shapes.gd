extends RefCounted
## Lightweight mesh toolkit. All visible artwork is live 3D geometry.
static func material(tint: Color, metallic: float = 0.0, glow: float = 0.0, transparent: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = tint
	m.metallic = metallic
	m.roughness = 0.34 if metallic > 0.05 else 0.69
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if transparent:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = tint
		m.emission_energy_multiplier = glow
	return m

static func ellipsoid(parent: Node3D, label: String, pos: Vector3, half_size: Vector3, tint: Color, metallic: float = 0.0, glow: float = 0.0) -> MeshInstance3D:
	var obj := MeshInstance3D.new()
	obj.name = label
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 18
	mesh.rings = 9
	obj.mesh = mesh
	obj.material_override = material(tint, metallic, glow, tint.a < 0.99)
	obj.position = pos
	obj.scale = half_size
	parent.add_child(obj)
	return obj

static func box(parent: Node3D, label: String, pos: Vector3, size3: Vector3, tint: Color, metallic: float = 0.0, glow: float = 0.0) -> MeshInstance3D:
	var obj := MeshInstance3D.new()
	obj.name = label
	var mesh := BoxMesh.new()
	mesh.size = size3
	obj.mesh = mesh
	obj.material_override = material(tint, metallic, glow)
	obj.position = pos
	parent.add_child(obj)
	return obj

static func tube(parent: Node3D, label: String, a: Vector3, b: Vector3, radius: float, tint: Color, metallic: float = 0.0, glow: float = 0.0) -> MeshInstance3D:
	var obj := MeshInstance3D.new()
	obj.name = label
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = maxf(a.distance_to(b), 0.001)
	mesh.radial_segments = 10
	obj.mesh = mesh
	obj.material_override = material(tint, metallic, glow)
	obj.position = (a + b) * 0.5
	obj.quaternion = Quaternion(Vector3.UP, (b - a).normalized())
	parent.add_child(obj)
	return obj

static func cone(parent: Node3D, label: String, pos: Vector3, height: float, width: float, tint: Color) -> MeshInstance3D:
	var obj := MeshInstance3D.new()
	obj.name = label
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = width
	mesh.height = height
	mesh.radial_segments = 12
	obj.mesh = mesh
	obj.material_override = material(tint)
	obj.position = pos
	parent.add_child(obj)
	return obj

static func fin(parent: Node3D, label: String, a: Vector3, b: Vector3, c: Vector3, tint: Color) -> MeshInstance3D:
	var surf := SurfaceTool.new()
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	surf.set_normal(Vector3.FORWARD)
	surf.add_vertex(a)
	surf.set_normal(Vector3.FORWARD)
	surf.add_vertex(b)
	surf.set_normal(Vector3.FORWARD)
	surf.add_vertex(c)
	var obj := MeshInstance3D.new()
	obj.name = label
	obj.mesh = surf.commit()
	obj.material_override = material(tint, 0.0, 0.0, false)
	parent.add_child(obj)
	return obj

static func environment(ambient: Color, fog_color: Color, fog_density: float) -> WorldEnvironment:
	var node := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = ambient
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("#8fbbd0")
	e.ambient_light_energy = 0.55
	e.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = fog_color
	e.fog_density = fog_density
	node.environment = e
	return node

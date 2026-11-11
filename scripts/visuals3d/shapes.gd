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
	obj.material_override = material(tint, 0.0, 0.0, tint.a < 0.99)
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


static func rock(parent: Node3D, label: String, pos: Vector3, radii: Vector3, tint: Color, seed_value: float = 0.0) -> MeshInstance3D:
	# Uneven triangulated geology: never a spherical placeholder rock.
	var surf := SurfaceTool.new()
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings := 10
	var slices := 15
	for j in range(rings):
		var phi0 := -PI*0.5 + PI*float(j)/float(rings)
		var phi1 := -PI*0.5 + PI*float(j+1)/float(rings)
		for i in range(slices):
			var a0 := TAU*float(i)/float(slices)
			var a1 := TAU*float(i+1)/float(slices)
			var v0 := _rock_point(a0,phi0,radii,seed_value)
			var v1 := _rock_point(a1,phi0,radii,seed_value)
			var v2 := _rock_point(a0,phi1,radii,seed_value)
			var v3 := _rock_point(a1,phi1,radii,seed_value)
			surf.add_vertex(v0)
			surf.add_vertex(v1)
			surf.add_vertex(v2)
			surf.add_vertex(v2)
			surf.add_vertex(v1)
			surf.add_vertex(v3)
	surf.generate_normals()
	var obj := MeshInstance3D.new()
	obj.name = label
	obj.mesh = surf.commit()
	obj.material_override = material(tint,0.05)
	obj.position = pos
	parent.add_child(obj)
	return obj

static func _rock_point(theta: float, elevation: float, radii: Vector3, seed_value: float) -> Vector3:
	var w := 0.85+0.11*sin(theta*5.0+seed_value)+0.12*cos(theta*9.0+elevation*7.0+seed_value*0.71)
	w += 0.095*sin(elevation*11.0+theta*3.0+seed_value*2.0)
	return Vector3(cos(elevation)*cos(theta)*radii.x*w,
		sin(elevation)*radii.y*w,cos(elevation)*sin(theta)*radii.z*w)

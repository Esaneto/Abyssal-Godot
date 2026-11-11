extends Node
## Real-time 3D cinematic ocean rendered into the legacy 2D exploration camera.
## Keeps the existing 2D physics, collisions, save data, field guide and HUD.
const Shapes = preload("res://scripts/visuals3d/shapes.gd")
const Marine = preload("res://scripts/visuals3d/fauna.gd")
const Diver3D = preload("res://scripts/visuals3d/diver.gd")
const UNITS_PER_PIXEL := 0.01375
const MAX_CREATURES := 22
var viewport: SubViewport
var root3d: Node3D
var geometry: Node3D
var animals: Node3D
var swimmer: Node3D
var fauna_pool: Array[Node3D] = []
var last_species: Array[String] = []
var sunlight: DirectionalLight3D
var spot: SpotLight3D
var environment_node: WorldEnvironment
var last_sector := Vector2i(9999,9999)
var t := 0.0
var world
var points: Array[Node3D] = []
var dust: Array[Node3D] = []
var build_counter := 0
var water_glass: MeshInstance3D

func _ready() -> void:
	viewport = SubViewport.new()
	viewport.name = "Live 3D ocean frame"
	viewport.size = Vector2i(1280,720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.own_world_3d = true
	add_child(viewport)
	root3d = Node3D.new()
	viewport.add_child(root3d)
	environment_node = Shapes.environment(Color("#06354b"),Color("#0a4261"),0.018)
	root3d.add_child(environment_node)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.85
	camera.position = Vector3(0,0,27)
	camera.far = 96.0
	camera.current = true
	root3d.add_child(camera)
	sunlight = DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-31,-27,-14)
	sunlight.light_color = Color("#87e7ef")
	sunlight.light_energy = 1.35
	root3d.add_child(sunlight)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-6.0,4.0,5.0)
	fill.light_color = Color("#44a7ce")
	fill.light_energy = 1.1
	fill.omni_range = 30.0
	root3d.add_child(fill)
	spot = SpotLight3D.new()
	spot.spot_range = 17.0
	spot.spot_angle = 42.0
	spot.light_energy = 2.1
	spot.light_color = Color("#96faf4")
	root3d.add_child(spot)
	geometry = Node3D.new()
	root3d.add_child(geometry)
	animals = Node3D.new()
	root3d.add_child(animals)
	swimmer = Diver3D.new()
	swimmer.name = "Fully articulated explorer"
	swimmer.scale = Vector3.ONE * 0.77
	root3d.add_child(swimmer)
	for i in range(MAX_CREATURES):
		fauna_pool.append(null)
		last_species.append("")
	_build_particles()
	_build_water_glass()

func texture() -> Texture2D:
	return viewport.get_texture()

func _from_game(point: Vector2, camera_center: Vector2, z: float = 0.0) -> Vector3:
	return Vector3((point.x-camera_center.x)*UNITS_PER_PIXEL,
		-(point.y-camera_center.y)*UNITS_PER_PIXEL,z)

func synchronize(game_world: Node2D, delta: float) -> void:
	if viewport == null:
		return
	world = game_world
	t += delta
	var center: Vector2 = world.camera.get_screen_center_position()
	var diver_pos: Vector2 = world.diver.position
	var meters: float = world.depth_at_y(diver_pos.y)
	var solar: float = world._sunlight()
	var attenuation := exp(-meters/245.0)
	sunlight.light_energy = 0.18 + 2.0*solar*attenuation
	spot.light_energy = 0.35 + 2.3*(1.0-attenuation)
	var water_color := Color("#041227").lerp(Color("#145167"),attenuation*solar*0.83)
	environment_node.environment.background_color = water_color
	environment_node.environment.fog_light_color = water_color
	environment_node.environment.fog_density = lerpf(0.034,0.012,attenuation)
	swimmer.position = _from_game(diver_pos,center,0.9)
	swimmer.call("set_appearance",world.diver.appearance)
	swimmer.call("animate",t,true,world.diver.velocity.length()>8.0,world.diver.is_facing_right)
	spot.position = swimmer.position + Vector3(0,0,2.2)
	spot.rotation_degrees = Vector3(0,0,0)
	var sector := Vector2i(int(floor(center.x/420.0)),int(floor(center.y/420.0)))
	if sector != last_sector:
		last_sector = sector
		_rebuild_terrain(center,meters)
	else:
		# Terrain positioning follows the 2D camera without recreating its meshes.
		_shift_terrain(center)
	_update_fauna(center)
	_animate_particles()

func _rebuild_terrain(center: Vector2, meters: float) -> void:
	build_counter += 1
	for old in geometry.get_children():
		geometry.remove_child(old)
		old.queue_free()
	points.clear()
	var shallow := meters < 220.0
	var grid_x := int(floor(center.x / 260.0))
	var grid_y := int(floor(center.y / 260.0))
	# Shaded geological ridges, algae, corals and deep vents are repeatable by sector.
	for gx in range(grid_x-5,grid_x+6):
		for gy in range(grid_y-3,grid_y+4):
			var seed_value := gx*19391+gy*7589+421
			var rng := RandomNumberGenerator.new()
			rng.seed = absi(seed_value)
			if rng.randf() > 0.48:
				continue
			var p2 := Vector2((float(gx)+0.5)*260.0,(float(gy)+0.5)*260.0)
			p2 += Vector2(rng.randf_range(-100,100),rng.randf_range(-80,80))
			var seabed_y: float = float(world.call("_seafloor_y",p2.x))
			var dist := seabed_y-p2.y
			# Deep background geology gives parallax while keeping 2D collision authoritative.
			var z := -9.0-rng.randf_range(0,6)
			var parent := Node3D.new()
			parent.set_meta("game_point",p2)
			parent.position = _from_game(p2,center,z)
			geometry.add_child(parent)
			points.append(parent)
			if dist < 400.0:
				var radius := rng.randf_range(0.65,2.6)
				var rock := Shapes.rock(parent,"Layered volcanic rock",Vector3.ZERO,
					Vector3(radius,radius*rng.randf_range(0.65,1.6),radius*0.60),
					Color("#16384c").lerp(Color("#466370"),rng.randf_range(0.0,0.5)),float(seed_value)*0.002)
				rock.rotation.z = rng.randf_range(-0.5,0.5)
				for i in range(3):
					var x := rng.randf_range(-radius,radius)
					Shapes.ellipsoid(parent,"Mineral inclusion",
						Vector3(x,rng.randf_range(-0.5,0.5),0.39*radius),
						Vector3(0.12,0.10,0.08),
						Color("#57b2bb") if shallow else Color("#365d78"),0.05,0.2 if not shallow else 0.0)
				if shallow:
					_coral_cluster(parent,rng)
				elif meters>600.0 and rng.randf()<0.30:
					_vent_cluster(parent,rng)
			elif rng.randf()<0.28:
				# Suspended terrain silhouettes fill the open-ocean view at multiple Z planes.
				var rock_back := Shapes.rock(parent,"Distant canyon outcrop",Vector3.ZERO,
					Vector3(rng.randf_range(0.8,2.0),rng.randf_range(1.7,3.9),1.1),
					Color("#0b3045"),float(seed_value)*0.003)
				rock_back.rotation.z = rng.randf_range(-0.5,0.5)
	# Landmark rocks share their real 2D positions; players don't see imaginary walls.
	for entry in world.ROCKS:
		var pos2: Vector2 = entry["pos"]
		if pos2.distance_to(center)>1700.0:
			continue
		var landmark := Node3D.new()
		landmark.set_meta("game_point",pos2)
		landmark.position = _from_game(pos2,center,0.15)
		geometry.add_child(landmark)
		points.append(landmark)
		var rad := float(entry["radius"])*UNITS_PER_PIXEL
		Shapes.rock(landmark,"Real collision landmark",Vector3.ZERO,
			Vector3(rad,rad*0.94,rad*0.6),Color("#273e51"),pos2.x*0.003)
		for i in range(5):
			var phi := float(i)*TAU/5.0
			var crystal_color := Color("#63e2e3") if shallow else Color("#5594bc")
			Shapes.cone(landmark,"Mineral vein",Vector3(cos(phi)*rad*0.65,sin(phi)*rad*0.55,rad*0.44),
				0.4,0.11,crystal_color)

func _shift_terrain(center: Vector2) -> void:
	for item in points:
		if not is_instance_valid(item):
			continue
		var point: Vector2 = item.get_meta("game_point")
		item.position.x = (point.x-center.x)*UNITS_PER_PIXEL
		item.position.y = -(point.y-center.y)*UNITS_PER_PIXEL

func _coral_cluster(parent: Node3D, rng: RandomNumberGenerator) -> void:
	for i in range(6):
		var col := Color("#e7897c") if i%3==0 else Color("#df78b6") if i%3==1 else Color("#68d3ae")
		var base := Vector3(rng.randf_range(-1.0,1.0),-0.75,rng.randf_range(-0.3,0.5))
		var tip := base+Vector3(rng.randf_range(-0.30,0.30),rng.randf_range(0.7,1.6),0)
		Shapes.tube(parent,"Branching coral",base,tip,0.058,col)
		Shapes.tube(parent,"Side coral",base.lerp(tip,0.55),tip+Vector3(0.36,0.07,0),0.034,col.lightened(0.16))
	for i in range(3):
		var kelp := Node3D.new()
		kelp.position = Vector3(rng.randf_range(-1.2,1.2),-1.15,-0.1)
		parent.add_child(kelp)
		Shapes.ellipsoid(kelp,"Seaweed leaf",Vector3(0,0.9,0),Vector3(0.12,1.1,0.08),Color("#3b9c81"))
		kelp.set_meta("sway",true)

func _vent_cluster(parent: Node3D, rng: RandomNumberGenerator) -> void:
	for i in range(3):
		var offset := Vector3(float(i)*0.42-0.4,-0.4,rng.randf_range(-0.5,0.4))
		Shapes.cone(parent,"Hydrothermal chimney",offset,1.6+float(i)*0.42,0.30,Color("#354655"))
		Shapes.ellipsoid(parent,"Sulfur glow",offset+Vector3(0,0.7+float(i)*0.2,0),
			Vector3(0.13,0.12,0.15),Color("#68d8c3"),0.1,2.1)

func _update_fauna(center: Vector2) -> void:
	var area := Rect2(center-Vector2(800,470),Vector2(1600,940))
	var found: Array[Dictionary] = world._creatures_in_view(area)
	var total := mini(MAX_CREATURES,found.size())
	for i in range(MAX_CREATURES):
		if i>=total:
			if fauna_pool[i]!=null:
				fauna_pool[i].visible = false
			continue
		var specimen: Dictionary = found[i]
		var kind: String = str(specimen["id"])
		if fauna_pool[i]==null or last_species[i]!=kind:
			if fauna_pool[i]!=null:
				animals.remove_child(fauna_pool[i])
				fauna_pool[i].queue_free()
			var animal := Marine.new()
			animals.add_child(animal)
			animal.configure(kind,float(specimen["seed"])*0.01)
			fauna_pool[i] = animal
			last_species[i] = kind
		var active_animal := fauna_pool[i]
		active_animal.visible = true
		var sample_pos: Vector2 = specimen["pos"]
		active_animal.position = _from_game(sample_pos,center,-0.7-float(i%4)*0.75)
		var length_px: float = float(specimen["info"]["length_px"])
		var size_factor := maxf(length_px/104.0,0.42)
		active_animal.scale = Vector3.ONE*(size_factor*0.72)
		active_animal.scale.x *= float(specimen["dir"])
		active_animal.call("animate",t)

func _build_particles() -> void:
	for i in range(95):
		var dot := Node3D.new()
		root3d.add_child(dot)
		dust.append(dot)
		var radius := 0.012+float(i%5)*0.007
		Shapes.ellipsoid(dot,"Live marine snow",Vector3.ZERO,Vector3.ONE*radius,
			Color(0.65,0.93,0.94,0.52),0.0,0.18)
	for i in range(14):
		var ray := Node3D.new()
		ray.position = Vector3(-12.0+float(i)*1.9,1.6,-10)
		root3d.add_child(ray)
		Shapes.fin(ray,"Scattered sunlight",Vector3(-0.3,7,0),Vector3(1.2,-7,0),
			Vector3(-2.0,-7,0),Color(0.31,0.73,0.87,0.065))

func _animate_particles() -> void:
	for i in range(dust.size()):
		var p := dust[i]
		var ix := float(i)
		p.position = Vector3(
			fposmod(ix*1.71+sin(t*0.22+ix)*0.19+12.0,24.0)-12.0,
			fposmod(ix*0.63-t*(0.045+float(i%4)*0.018)+6.4,12.8)-6.4,
			-4.0-float(i%8)*1.7)

func _build_water_glass() -> void:
	var mesh := QuadMesh.new()
	mesh.size = Vector2(33.0,22.0)
	water_glass = MeshInstance3D.new()
	water_glass.name = "Animated volume refraction and caustics"
	water_glass.mesh = mesh
	water_glass.material_override = ShaderMaterial.new()
	(water_glass.material_override as ShaderMaterial).shader = preload("res://shaders/underwater_volume.gdshader")
	water_glass.position.z = 5.0
	root3d.add_child(water_glass)

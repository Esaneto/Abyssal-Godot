extends Node
## A living 3D command bridge with an articulated seated pilot and ocean fauna.
## The existing keyboard, mouse, laboratory, inventory and wardrobe UI remain 2D controls.
const Shapes = preload("res://scripts/visuals3d/shapes.gd")
const Marine = preload("res://scripts/visuals3d/fauna.gd")
const Diver3D = preload("res://scripts/visuals3d/diver.gd")
var viewport: SubViewport
var stage: Node3D
var pilot: Node3D
var fauna: Array[Node3D] = []
var foliage: Array[Node3D] = []
var sun: DirectionalLight3D
var env_node: WorldEnvironment
var clock := 0.0
var previous_look := ""
var glass: MeshInstance3D
var ocean_shadow: Node3D
var shadow_tail: Node3D

func _ready() -> void:
	viewport = SubViewport.new()
	viewport.name = "Cinematic submarine interior"
	viewport.size = Vector2i(1280,720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.own_world_3d = true
	add_child(viewport)
	stage = Node3D.new()
	viewport.add_child(stage)
	env_node = Shapes.environment(Color("#071a2b"),Color("#0b2f40"),0.024)
	stage.add_child(env_node)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 7.4
	camera.position = Vector3(0,1.3,10)
	camera.look_at_from_position(camera.position,Vector3(0,0.56,0))
	camera.current = true
	stage.add_child(camera)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-39,-30,0)
	sun.light_color = Color("#8aa7b8")
	sun.light_energy = 0.62
	stage.add_child(sun)
	_light(Vector3(-4.4,2.7,2.8),Color("#dea269"),1.5,7.0)
	_light(Vector3(2.9,2.7,3.3),Color("#5c9eb2"),1.0,8.0)
	_light(Vector3(-0.2,0.15,-7),Color("#3b8997"),1.2,14.0)
	_build_outside()
	_build_leviathan_shadow()
	_build_glass()
	_build_hull()
	_build_instruments()
	# 3D pilot replaced by the more expressive animated layered anime character.
	# Keep the old 3D rig function for comparison without constructing it every frame.

func _light(pos: Vector3, tint: Color, energy: float, radius: float) -> void:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_color = tint
	light.light_energy = energy
	light.omni_range = radius
	stage.add_child(light)

func texture() -> Texture2D:
	return viewport.get_texture()

func set_enabled(value: bool) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
	if viewport != null:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if value else SubViewport.UPDATE_DISABLED
	if stage != null:
		stage.visible = value

func _build_outside() -> void:
	# Geology and marine biology exist as actual 3D objects behind the windows.
	for i in range(20):
		var fx := float(i)
		var x := -14.0+fx*1.5
		var y := -2.75+0.50*sin(fx*0.76)
		var z := -11.0-float(i%3)*1.7
		var cliff := Shapes.rock(stage,"Submerged oceanic ridge",Vector3(x,y,z),
			Vector3(1.2+float(i%4)*0.45,1.5+float(i%3)*0.75,1.3),Color("#143d51").lerp(Color("#285c67"),float(i%4)*0.11),fx*0.41)
		cliff.rotation.z = sin(fx*1.7)*0.4
		if i%2==0:
			_coral_group(Vector3(x,y+0.8,z+1.6),i)
	for i in range(9):
		var marine := Marine.new()
		stage.add_child(marine)
		marine.configure(["manta","eagle_ray","turtle","jelly","oarfish","jelly","turtle","manta","viper"][i],float(i)*13.4)
		marine.position = Vector3(-8.0+float(i)*2.05,1.3+sin(float(i)*2.2)*1.25,-8.3-float(i%3))
		marine.scale = Vector3.ONE*(0.40+float(i%3)*0.15)
		fauna.append(marine)
	# Rays made of moving transparent geometry instead of a static background bitmap.
	for i in range(13):
		var group := Node3D.new()
		group.position = Vector3(-9.0+float(i)*1.5,0,-7.1)
		group.rotation.z = 0.11
		stage.add_child(group)
		Shapes.fin(group,"Sunbeam in ocean",Vector3(-0.18,4.2,0),Vector3(0.60,-2.5,0),
			Vector3(-1.0,-2.5,0),Color(0.43,0.94,0.99,0.055))
		foliage.append(group)

func _build_leviathan_shadow() -> void:
	# A rare passing deep-sea silhouette beyond the actual window glass.
	# All contours, photophores and fins are separate moving 3D parts.
	ocean_shadow = Node3D.new()
	ocean_shadow.name = "DeepWindowVisitor"
	ocean_shadow.position = Vector3(3.5,1.25,-9.0)
	stage.add_child(ocean_shadow)
	var shadow := Color("#142d3c")
	var ridge := Color("#244657")
	Shapes.ellipsoid(ocean_shadow,"Muscular flank",Vector3(-0.18,0,0),
		Vector3(1.67,0.33,0.42),shadow,0.0)
	Shapes.ellipsoid(ocean_shadow,"Tapered head",Vector3(1.08,0.0,0),
		Vector3(0.54,0.26,0.34),shadow.darkened(0.03),0.0)
	Shapes.fin(ocean_shadow,"Abyssal crest",Vector3(-0.52,0.23,0),
		Vector3(-0.14,1.03,0),Vector3(0.32,0.24,0),ridge)
	Shapes.fin(ocean_shadow,"Abdominal keel",Vector3(-0.61,-0.27,0),
		Vector3(-0.19,-0.78,0),Vector3(0.53,-0.22,0),shadow.darkened(0.25))
	Shapes.fin(ocean_shadow,"Pectoral blade",Vector3(0.23,-0.06,0.38),
		Vector3(-0.48,-0.43,0.54),Vector3(-0.24,-0.18,0.43),ridge)
	shadow_tail = Node3D.new()
	shadow_tail.name = "ArticulatedTail"
	shadow_tail.position = Vector3(-1.48,0,0)
	ocean_shadow.add_child(shadow_tail)
	Shapes.ellipsoid(shadow_tail,"Tail peduncle",Vector3(-0.32,0,0),
		Vector3(0.46,0.14,0.18),shadow)
	Shapes.fin(shadow_tail,"Upper tail lobe",Vector3(-0.49,0,0),
		Vector3(-0.98,0.79,0),Vector3(-0.80,0.04,0),ridge)
	Shapes.fin(shadow_tail,"Lower tail lobe",Vector3(-0.49,0,0),
		Vector3(-0.90,-0.76,0),Vector3(-0.81,-0.04,0),shadow)
	for i in range(7):
		var x := -0.92+float(i)*0.31
		var y := -0.30+0.10*sin(float(i)*1.9)
		Shapes.ellipsoid(ocean_shadow,"Faint lateral photophore",
			Vector3(x,y,0.45),Vector3(0.025,0.023,0.015),
			Color("#3f8990"),0.08,0.30)
	Shapes.ellipsoid(ocean_shadow,"Reflective eye",Vector3(1.32,0.08,0.34),
		Vector3(0.035,0.031,0.025),Color("#65999b"),0.03,0.14)
	# Angled jaws, gill grooves and scar ridges make this a creature, not a glossy oval.
	Shapes.ellipsoid(ocean_shadow,"Lower jaw shadow",Vector3(1.37,-0.18,0.11),
		Vector3(0.37,0.07,0.26),Color("#071c27"),0.0)
	for g in range(4):
		var gx := 0.80-float(g)*0.16
		Shapes.tube(ocean_shadow,"Gill crease",Vector3(gx,0.11,0.37),
			Vector3(gx-0.03,-0.13,0.39),0.012,Color("#0e2432"))
	for ridge_id in range(3):
		var rx := -0.84+float(ridge_id)*0.23
		Shapes.fin(ocean_shadow,"Uneven dorsal finlet",Vector3(rx,0.29,-0.06),
			Vector3(rx+0.12,0.45+float(ridge_id%2)*0.09,-0.06),
			Vector3(rx+0.27,0.27,-0.06),ridge.darkened(0.22))

func _coral_group(pos: Vector3, seed_value: int) -> void:
	var cluster := Node3D.new()
	cluster.position = pos
	stage.add_child(cluster)
	# Muted mineral coral with branched growth and visible living polyps.
	for k in range(8):
		var a := float(k)*TAU/8.0
		var tint := Color("#917468") if k%3==0 else Color("#577b73") if k%3==1 else Color("#756983")
		var start := Vector3(cos(a)*0.30,0,sin(a)*0.28)
		var branch_height := 0.45+float((k+seed_value)%4)*0.20
		var bend := Vector3(cos(a)*0.24,branch_height,sin(a)*0.16)
		var top := start+bend
		Shapes.tube(cluster,"Irregular coral trunk",start,top,0.040,tint)
		for tip_index in range(2):
			var intermediate := start.lerp(top,0.45+float(tip_index)*0.20)
			var direction := -1.0 if tip_index==0 else 1.0
			var twig := intermediate+Vector3(direction*0.14,0.22,direction*0.075)
			Shapes.tube(cluster,"Coral offshoot",intermediate,twig,0.020,tint.lightened(0.12))
			Shapes.ellipsoid(cluster,"Polyp crown",twig,Vector3(0.045,0.045,0.040),
				tint.lightened(0.15),0.0)
	# Swaying leaf clusters have stems plus separately curved blades, not cylinders.
	for k in range(4):
		var sway := Node3D.new()
		sway.name = "CurrentsAnimatedKelp"
		sway.position = Vector3(float(k-1)*0.38,0,-0.10-float(k%2)*0.15)
		cluster.add_child(sway)
		Shapes.tube(sway,"Kelp stalk",Vector3(0,0,0),Vector3(0.06,1.40,0),
			0.026,Color("#3c6a62"))
		for blade_id in range(5):
			var y := 0.22+float(blade_id)*0.245
			var sign := -1.0 if blade_id%2==0 else 1.0
			var leaf := Shapes.ellipsoid(sway,"Serrated kelp blade",
				Vector3(sign*0.11,y,0),Vector3(0.10,0.22,0.034),
				Color("#507e73") if blade_id%3==0 else Color("#3d675f"),0.0)
			leaf.rotation.z = sign*0.48
		sway.set_meta("seed",float(seed_value+k))
		foliage.append(sway)

func _build_hull() -> void:
	var ink := Color("#152d42")
	var steel := Color("#40566a")
	var lighter := Color("#647a84")
	# Outer ribs and beveled arches frame three immense viewports.
	for ix in range(5):
		var x := -6.65+float(ix)*3.33
		Shapes.box(stage,"Pressure hull pillar",Vector3(x,0.85,-2.1),
			Vector3(0.35,6.1,0.78),ink,0.64)
		Shapes.box(stage,"Structural highlight",Vector3(x+0.09,0.85,-1.60),
			Vector3(0.04,5.7,0.05),steel,0.58)
		for k in range(7):
			Shapes.ellipsoid(stage,"Riveted joint",Vector3(x,3.4-float(k)*0.85,-1.55),
				Vector3(0.045,0.045,0.025),Color("#bd9874"),0.8)
	Shapes.box(stage,"Upper hull",Vector3(0,3.45,-1.1),Vector3(14.8,0.74,2.2),ink,0.53)
	Shapes.box(stage,"Upper warm trim",Vector3(0,3.02,-0.05),Vector3(14.5,0.035,0.14),Color("#c18d58"),0.69)
	Shapes.box(stage,"Lower window sill",Vector3(0,-1.42,-1.2),Vector3(14.8,0.56,1.6),ink,0.5)
	Shapes.box(stage,"Window brass edge",Vector3(0,-1.1,-0.29),Vector3(14.7,0.04,0.07),Color("#c18d58"),0.66)
	Shapes.box(stage,"Cast metal deck",Vector3(0,-2.36,1.0),Vector3(15.5,0.24,6.5),Color("#202b3d"),0.49)
	# Ceiling light fixtures, ventilation, copper conduit.
	for i in range(10):
		var x := -6.1+float(i)*1.36
		Shapes.box(stage,"Ceiling fixture",Vector3(x,2.86,0.45),Vector3(0.80,0.11,0.38),steel,0.45)
		Shapes.box(stage,"Amber strip light",Vector3(x,2.79,0.68),Vector3(0.66,0.055,0.045),Color("#e6a768"),0.07,0.55)
	Shapes.tube(stage,"Overhead pressure conduit",Vector3(-6.7,2.65,0.36),Vector3(6.7,2.65,0.36),0.055,Color("#76808b"),0.65)
	for i in range(8):
		var x := -6.4+float(i)*1.82
		Shapes.box(stage,"Deck plating seam",Vector3(x,-2.19,2.5),Vector3(0.045,0.02,3.35),lighter,0.48)
	# Fluid light shafts reflected onto the metallic deck.
	for i in range(7):
		Shapes.box(stage,"Deck recessed lights",Vector3(-5.7+float(i)*1.9,-2.12,3.5),
			Vector3(0.72,0.03,0.07),Color("#64858a"),0.2,0.65)

func _build_instruments() -> void:
	# Actual 3D consoles sit behind the existing interactive Godot menu.
	Shapes.box(stage,"Main command pedestal",Vector3(1.35,-1.72,2.55),
		Vector3(8.5,1.28,1.6),Color("#202b42"),0.58)
	# Remove the old wall-sized black screen. It obscured the living ocean.
	# Compact physical instrumentation stays on the dashboard below the glass.
	Shapes.box(stage,"Compact sonar bezel",Vector3(2.38,-1.29,2.10),
		Vector3(1.98,0.70,0.22),Color("#1b2c41"),0.46)
	Shapes.box(stage,"Live sonar glass",Vector3(2.38,-1.29,2.24),
		Vector3(1.79,0.55,0.04),Color("#153d49"),0.28,0.10)
	for i in range(13):
		var x := -2.0+float(i)*0.54
		Shapes.box(stage,"Copper capacitive strip",Vector3(x,-1.83,3.39),
			Vector3(0.34,0.06,0.03),Color("#d8a66b"),0.62,0.72)
	for i in range(5):
		var x := 4.75+float(i%2)*0.48
		var y := -1.1+float(i/2)*0.41
		Shapes.ellipsoid(stage,"Sonar illuminated indicator",Vector3(x,y,2.95),
			Vector3(0.07,0.07,0.055),Color("#5cf1e2") if i%2==0 else Color("#e6ab65"),0.10,1.6)
	Shapes.box(stage,"Captain side panel",Vector3(-4.85,-1.6,3.05),
		Vector3(2.15,0.55,1.15),Color("#263b55"),0.59)
	for i in range(6):
		var x := -5.62+float(i)*0.30
		Shapes.box(stage,"Pilot input switch",Vector3(x,-1.29,3.38),
			Vector3(0.15,0.07,0.09),Color("#64d4da") if i%2==0 else Color("#deac7a"),0.20,1.2)

func _build_pilot() -> void:
	# Actual seating geometry and shared anatomical 3D diver, not PNG cutouts.
	var x := -4.35
	Shapes.box(stage,"Pilot seat base",Vector3(x,-1.88,0.72),
		Vector3(1.5,0.24,1.30),Color("#22364b"),0.31)
	Shapes.ellipsoid(stage,"Padded seat back",Vector3(x,-0.72,0.03),
		Vector3(0.72,1.30,0.28),Color("#283f55"),0.15)
	Shapes.ellipsoid(stage,"Head rest",Vector3(x,0.50,0.06),
		Vector3(0.52,0.29,0.27),Color("#324c66"),0.24)
	for side in [-1.0,1.0]:
		Shapes.box(stage,"Seat armrest",Vector3(x+side*0.78,-1.33,1.05),
			Vector3(0.16,0.17,0.91),Color("#4b5c70"),0.49)
		Shapes.tube(stage,"Seat telescopic piston",
			Vector3(x+side*0.43,-2.18,0.4),Vector3(x+side*0.43,-1.80,0.50),
			0.075,Color("#8995a3"),0.67)
	pilot = Diver3D.new()
	pilot.name = "Expressive human pilot"
	pilot.position = Vector3(x,-1.88,1.35)
	pilot.scale = Vector3.ONE*0.98
	stage.add_child(pilot)
	pilot.call("set_tool_state","none",false,false,0.0)

func update_live(time_value: float, appearance: Dictionary) -> void:
	clock = time_value
	if viewport == null:
		return
	# The pilot is illustrated in layered SVG; only animate 3D pilot when enabled.
	if pilot != null:
		var serialized := JSON.stringify(appearance)
		if serialized != previous_look:
			previous_look = serialized
			pilot.call("set_appearance",appearance)
		pilot.call("animate",clock,false,false,true)
	var solar := 0.55+0.45*cos(clock*TAU/420.0)
	sun.light_energy = 0.18+0.75*solar
	var color := Color("#020c1a").lerp(Color("#0c4156"),solar)
	env_node.environment.background_color = color
	env_node.environment.fog_light_color = color
	for i in range(fauna.size()):
		var actor := fauna[i]
		var base := -8.0+float(i)*2.05
		actor.position.x = base+sin(clock*0.20+float(i)*1.73)*1.4
		actor.position.y = 1.3+sin(float(i)*2.2+clock*0.42)*0.67
		actor.call("animate",clock)
	if ocean_shadow != null:
		# The animal crosses the outer pane slowly, turning out of view naturally.
		ocean_shadow.position.x = 3.4+2.7*sin(clock*0.038)
		ocean_shadow.position.y = 1.27+0.22*sin(clock*0.073)
		ocean_shadow.rotation.y = 0.06*sin(clock*0.041)
		shadow_tail.rotation.y = 0.21*sin(clock*0.92)
	for i in range(foliage.size()):
		var stem := foliage[i]
		stem.rotation.z = sin(clock*0.42+float(i))*0.07

func _build_glass() -> void:
	var mesh := QuadMesh.new()
	mesh.size = Vector2(18.0,10.0)
	glass = MeshInstance3D.new()
	glass.name = "Moving underwater window refraction"
	glass.mesh = mesh
	glass.material_override = ShaderMaterial.new()
	(glass.material_override as ShaderMaterial).shader = preload("res://shaders/underwater_volume.gdshader")
	glass.position = Vector3(0,0,-4.2)
	stage.add_child(glass)

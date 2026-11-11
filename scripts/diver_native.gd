extends CharacterBody2D
## Explorador nativo: movimento submarino continuo, sem combate.
## Colisoes Godot, nado com aceleracao/arrasto, flutuabilidade e correntes.
signal diver_died
const Look = preload("res://scripts/diver_appearance.gd")
const Doll = preload("res://scripts/diver_paper_doll.gd")
const NativeRig = preload("res://scripts/native_diver_rig.gd")

const MAX_OXYGEN := 300.0
const MAX_HEALTH := 100.0
const MAX_SPEED := 245.0
const SWIM_ACCELERATION := 620.0
const WATER_DRAG := 2.5
const BUOYANCY := 28.0
const SURFACE_Y := 75.0
const TURN_RATE := 6.5
const BOOST_ACCELERATION := 1550.0
const BOOST_MAX_SPEED := 505.0
const BATTERY_DRAIN := 35.0
const BATTERY_RECHARGE := 16.0

var oxygen_capacity := MAX_OXYGEN
var safe_depth := 300.0
var oxygen := MAX_OXYGEN
var time_without_air := 0.0
var health := MAX_HEALTH
var swim_force := Vector2.ZERO
var current_force := Vector2.ZERO
var time_s := 0.0
var depth_m := 0.0
var is_moving := false
var is_facing_right := true
var appearance: Dictionary = Look.defaults()
var anime_rig: Node2D = null
var propulsion_bubbles: CPUParticles2D
var collision_node: CollisionShape2D
var swim_heading := 0.0
var visual_heading := 0.0
var equipped_tool := "abyssPickaxe"
var propulsion_level := 0
var propulsion_capacity := 100.0
var propulsion_energy := 100.0
var is_propelling := false
var is_extracting := false

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 17.0
	shape.height = 91.0
	collision.shape = shape
	collision.rotation = PI / 2.0
	collision_node = collision
	add_child(collision)
	anime_rig = NativeRig.new()
	add_child(anime_rig)
	# The new illustrated rig is drawn from articulated geometry each frame.
	anime_rig.visible = false
	_create_propulsion_bubbles()
	queue_redraw()

func _physics_process(delta: float) -> void:
	time_s += delta
	var steering := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	is_moving = steering.length_squared() > 0.02
	if is_moving:
		swim_heading = steering.angle()
	elif velocity.length() > 26.0:
		swim_heading = velocity.angle()
	if absf(steering.x) > 0.1:
		is_facing_right = steering.x > 0.0
	visual_heading = lerp_angle(visual_heading, swim_heading if is_moving or velocity.length()>26.0 else 0.0, minf(1.0, TURN_RATE*delta))
	if collision_node != null:
		collision_node.rotation = visual_heading + PI*0.5
	depth_m = clampf((global_position.y - SURFACE_Y) / (21000.0 - SURFACE_Y), 0.0, 1.0) * 2200.0
	# Slow depth-dependent currents. The character does not move by teleport.
	current_force = Vector2(
		21.0 * sin(global_position.y * 0.0025 + time_s * 0.18),
		7.0 * cos(global_position.x * 0.0009 + time_s * 0.15)
	)
	# The miniature propulsion unit pushes through water, rather than teleporting.
	var wants_boost := equipped_tool == "propulsionUnit" and Input.is_action_pressed("boost")
	is_propelling = wants_boost and propulsion_energy > 0.7
	var thrust_direction := steering if is_moving else Vector2.RIGHT.rotated(swim_heading)
	swim_force = steering * SWIM_ACCELERATION + Vector2.UP * BUOYANCY + current_force
	if is_propelling:
		swim_force += thrust_direction * (BOOST_ACCELERATION * (1.0+float(propulsion_level)*0.13))
		propulsion_energy = maxf(0.0, propulsion_energy-(BATTERY_DRAIN-float(propulsion_level)*2.0)*delta)
	else:
		propulsion_energy = minf(propulsion_capacity, propulsion_energy+(BATTERY_RECHARGE+float(propulsion_level)*2.5)*delta)
	velocity += swim_force * delta
	velocity *= exp(-WATER_DRAG * (0.67 if is_propelling else 1.0) * delta)
	var cap := BOOST_MAX_SPEED*(1.0+float(propulsion_level)*0.06) if is_propelling else MAX_SPEED*1.62
	velocity = velocity.limit_length(cap)
	move_and_slide()
	global_position.x = clampf(global_position.x, 60.0, 23940.0)
	if global_position.y <= SURFACE_Y:
		global_position.y = SURFACE_Y
		velocity.y = maxf(velocity.y, 0.0)
	if global_position.y >= 20940.0:
		global_position.y = 20940.0
		velocity.y = minf(velocity.y, 0.0)
	if global_position.y <= SURFACE_Y + 7.0:
		oxygen = minf(oxygen_capacity, oxygen + oxygen_capacity * 0.65 * delta)
	else:
		oxygen = maxf(0.0, oxygen - delta)
	if oxygen <= 0.0:
		time_without_air += delta
		health = maxf(0.0, health - minf(160.0, 9.0 + time_without_air * 3.0) * delta)
	else:
		time_without_air = 0.0
	# Mirrors JS pressureSafety formula; these are game rules, not dive medicine.
	if depth_m > safe_depth:
		var excess := depth_m - safe_depth
		var pressure_hazard := minf(160.0, 3.0 * pow(excess / 10.0, 1.55))
		health = maxf(0.0, health - pressure_hazard * delta)
	if health <= 0.0:
		diver_died.emit()
	if propulsion_bubbles != null:
		propulsion_bubbles.emitting = is_propelling
		propulsion_bubbles.position = Vector2(-58.0, 10.0).rotated(visual_heading)
		propulsion_bubbles.rotation = visual_heading
	queue_redraw()

func set_appearance(candidate: Dictionary) -> void:
	appearance = Look.normalize(candidate)
	# Preserve the selected colors while the illustrated mesh is redrawn.
	queue_redraw()

func configure_equipment(oxygen_level: int, suit_level: int, motor_level: int = 0) -> void:
	oxygen_capacity = MAX_OXYGEN * (1.0 + float(clampi(oxygen_level, 0, 5)))
	safe_depth = 300.0 + float(clampi(suit_level, 0, 5)) * 180.0
	oxygen = minf(oxygen, oxygen_capacity)
	propulsion_level = clampi(motor_level, 0, 3)
	propulsion_capacity = 100.0 + float(propulsion_level)*22.0
	propulsion_energy = minf(propulsion_energy, propulsion_capacity)

func recover() -> void:
	oxygen = oxygen_capacity
	health = MAX_HEALTH
	time_without_air = 0.0
	velocity = Vector2.ZERO
	propulsion_energy = propulsion_capacity
	is_propelling = false

func set_equipped_tool(tool: String) -> void:
	equipped_tool = tool
	queue_redraw()

func set_extracting(active: bool) -> void:
	is_extracting = active

func _create_propulsion_bubbles() -> void:
	propulsion_bubbles = CPUParticles2D.new()
	propulsion_bubbles.name = "HydrojetBubbles"
	propulsion_bubbles.texture = NativeRig._bubble_texture()
	propulsion_bubbles.amount = 60
	propulsion_bubbles.lifetime = 0.78
	propulsion_bubbles.explosiveness = 0.0
	propulsion_bubbles.direction = Vector2.LEFT
	propulsion_bubbles.spread = 20.0
	propulsion_bubbles.gravity = Vector2(-5.0,-34.0)
	propulsion_bubbles.initial_velocity_min = 72.0
	propulsion_bubbles.initial_velocity_max = 170.0
	propulsion_bubbles.scale_amount_min = 0.16
	propulsion_bubbles.scale_amount_max = 0.43
	propulsion_bubbles.color = Color(0.70,0.95,1.0,0.80)
	propulsion_bubbles.local_coords = false
	propulsion_bubbles.emitting = false
	add_child(propulsion_bubbles)

func _draw() -> void:
	# PNGs installed: the MeshInstance2D child animates natively with
	# AnimationPlayer and particles. Keep this renderer only as a fallback.
	# Animated line-art and colors remain available without external static PNGs.
	# Side-view expedition diver: anatomy, layered neoprene, steel tanks and flexible fins.
	# Every part is anchored to this CharacterBody2D; physics and hitbox remain unchanged.
	draw_set_transform(Vector2.ZERO, visual_heading, Vector2.ONE)
	var phase := time_s * (8.4 if is_moving else 2.0)
	var kick := sin(phase) * (9.5 if is_moving else 2.2)
	var breathe := sin(time_s * 1.55) * 1.2
	var deep := clampf(depth_m / 900.0, 0.0, 1.0)
	var tones := Look.palette(appearance)
	var cloth: Color = tones["cloth"]
	var accent: Color = tones["accent"]
	var visor: Color = tones["visor"]
	var suit := cloth.lerp(Color("#102432"), deep * 0.55)
	var seam := accent.lerp(Color("#315565"), deep * 0.40)
	# Rear leg and articulated boot, then its flexible blade.
	draw_line(Vector2(-18, 9), Vector2(-40, 21 - kick), Color("#0e2938"), 15.0, true)
	draw_line(Vector2(-40, 21 - kick), Vector2(-55, 21 - kick * 1.2), Color("#284b5e"), 12.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-53, 14 - kick * 1.2), Vector2(-71, 7 - kick * 1.4),
		Vector2(-75, 12 - kick * 1.4), Vector2(-70, 31 - kick * 1.2),
		Vector2(-53, 28 - kick * 1.2)
	]), cloth.darkened(0.23))
	draw_line(Vector2(-68, 12 - kick), Vector2(-62, 26 - kick), Color("#42687c"), 1.3, true)
	# Diving tank: rounded metal vessel with edge reflection and regulator mount.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-31, -29), Vector2(-17, -35), Vector2(7, -34),
		Vector2(12, -21), Vector2(6, -7), Vector2(-29, -6)
	]), Color("#0b1c2c"))
	draw_rect(Rect2(-28, -29, 34, 22), cloth.lightened(0.47))
	draw_rect(Rect2(-22, -28, 5, 20), accent.lightened(0.35))
	draw_line(Vector2(-30, -23), Vector2(9, -23), Color("#152b38"), 4.0, true)
	draw_line(Vector2(-29, -12), Vector2(9, -12), Color("#172a38"), 4.0, true)
	draw_circle(Vector2(-13, -34), 5.0, Color("#142c3a"))
	draw_circle(Vector2(-13, -34), 2.0, Color("#b8986a"))
	# Main wetsuit uses three geometric light planes instead of flat uniform fill.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-29, -17), Vector2(-11, -21), Vector2(16, -17),
		Vector2(23, -3), Vector2(11, 18), Vector2(-23, 19),
		Vector2(-33, 7)
	]), Color("#0e2837"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-22, -15), Vector2(-1, -18), Vector2(15, -14),
		Vector2(15, 5), Vector2(-3, 14), Vector2(-22, 10)
	]), suit)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, -13), Vector2(6, -13), Vector2(14, 2),
		Vector2(-7, 7)
	]), cloth.lightened(0.22))
	# Three shaped armor plates are tinted by the equipped suit, not baked in.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-21,-13),Vector2(-13,-16),Vector2(-5,3),Vector2(-13,11)
	]),Color(accent.r,accent.g,accent.b,0.47))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7,-16),Vector2(5,-13),Vector2(16,-2),Vector2(9,7)
	]),Color(0.56,0.81,0.91,0.22))
	draw_line(Vector2(-23,-17),Vector2(15,-16),accent,1.5,true)
	draw_line(Vector2(-25, -16), Vector2(-14, 13), seam, 1.8, true)
	draw_line(Vector2(-8, -19), Vector2(5, 16), Color("#102735"), 4.0, true)
	draw_line(Vector2(-12, 15), Vector2(13, 14), Color("#63838b"), 2.0, true)
	# Strap buckle and subtle life-support diode.
	draw_rect(Rect2(-5, -4, 9, 7), Color("#132c38"))
	draw_rect(Rect2(-3, -2, 5, 3), Color("#e5ae71"))
	draw_circle(Vector2(-21, -2), 2.1, Color("#75d9d0"))
	# Near leg kicks in opposition; the dark hip joint stays connected.
	draw_line(Vector2(-21, 9), Vector2(-39, 24 + kick), Color("#163848"), 14.0, true)
	draw_line(Vector2(-39, 24 + kick), Vector2(-54, 27 + kick * 1.1), Color("#41667b"), 12.0, true)
	draw_line(Vector2(-34, 20 + kick), Vector2(-47, 27 + kick), Color("#789ba4"), 2.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-53, 21 + kick * 1.1), Vector2(-68, 15 + kick * 1.2),
		Vector2(-76, 17 + kick * 1.2), Vector2(-72, 38 + kick * 1.1),
		Vector2(-55, 36 + kick * 1.1)
	]), cloth.darkened(0.11))
	draw_line(Vector2(-70, 20 + kick), Vector2(-65, 33 + kick), Color("#5b8495"), 1.5, true)
	# One far forearm underneath the torso and one near forearm ahead.
	draw_line(Vector2(7, 11), Vector2(20, 17 + breathe), Color("#0c2533"), 10.0, true)
	draw_line(Vector2(20, 17 + breathe), Vector2(28, 12 + breathe), cloth.lightened(0.24), 8.0, true)
	draw_line(Vector2(11, -8), Vector2(27, 4 + breathe), cloth, 12.0, true)
	draw_line(Vector2(27, 4 + breathe), Vector2(40, 7 + breathe), cloth.lightened(0.28), 10.0, true)
	draw_circle(Vector2(40, 7 + breathe), 5.0, cloth.lightened(0.36))
	# Regulator hose curls from the cylinder to the lower mask.
	draw_arc(Vector2(15, -14), 24.0, PI * 1.11, PI * 1.95, 16, Color("#0b2531"), 4.5, true)
	# The selected hair asset is drawn behind the helmet before the visor.
	Doll.draw_swimmer_hair(self,appearance,time_s,is_moving,breathe)
	# Both body variants use the same rig and physics, with suit details as skins.
	if str(appearance.get("body","female")) == "male":
		draw_line(Vector2(-24,-15),Vector2(12,-17),cloth.lightened(0.18),3.6,true)
	else:
		draw_line(Vector2(-19,-14),Vector2(6,-17),cloth.lightened(0.18),2.3,true)
	# Helmet, mask, shadowed skin and rim lighting.
	draw_circle(Vector2(33, -17 + breathe), 19.5, Color("#0b2331"))
	draw_circle(Vector2(34, -18 + breathe), 16.0, cloth.lightened(0.42))
	draw_circle(Vector2(35, -19 + breathe), 12.8, Color("#ae9782"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(28, -31 + breathe), Vector2(46, -29 + breathe),
		Vector2(51, -20 + breathe), Vector2(47, -15 + breathe),
		Vector2(28, -17 + breathe)
	]), visor.darkened(0.64))
	draw_colored_polygon(PackedVector2Array([
		Vector2(30, -29 + breathe), Vector2(43, -28 + breathe),
		Vector2(46, -24 + breathe), Vector2(33, -24 + breathe)
	]), Color(visor.r, visor.g, visor.b, 0.58))
	draw_arc(Vector2(33, -17 + breathe), 18.0, PI * 0.95, PI * 1.85, 18, visor, 2.6, true)
	draw_circle(Vector2(46, -12 + breathe), 5.0, Color("#122a35"))
	draw_line(Vector2(47, -12 + breathe), Vector2(56, -7 + breathe), Color("#4d7d85"), 3.4, true)
	_draw_equipped_tool(breathe)
	# Tiny respirator bubbles rise only near the actual regulator.
	for k in range(3):
		var rise := fposmod(time_s * (12.0 + float(k) * 3.0) + float(k) * 25.0, 67.0)
		var p := Vector2(57.0 + sin(time_s * 1.6 + float(k)) * 4.0, -14.0 - rise)
		draw_arc(p, 2.2 + float(k) * 0.7, 0, TAU, 12, Color(0.60, 0.93, 0.92, 0.45), 1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_equipped_tool(breathe: float) -> void:
	if equipped_tool == "propulsionUnit":
		# Twin-nozzle electric water scooter with illuminated impellers.
		draw_line(Vector2(-34,12),Vector2(-62,16),Color("#071a27"),17.0,true)
		draw_line(Vector2(-34,12),Vector2(-62,16),Color("#3a7688"),11.0,true)
		draw_rect(Rect2(-70,6,16,21),Color("#182b41"))
		draw_rect(Rect2(-67,9,8,14),Color("#65ddd9"))
		draw_arc(Vector2(-68,16),9.0,0,TAU,20,Color("#d5f5fa"),2.2,true)
		draw_circle(Vector2(-70,16),3.2,Color("#f3b977"))
		if is_propelling:
			draw_colored_polygon(PackedVector2Array([
				Vector2(-74,10),Vector2(-116-8.0*sin(time_s*26.0),16),
				Vector2(-74,23)
			]),Color(0.38,0.88,0.93,0.19))
	elif equipped_tool == "abyssPickaxe":
		var swing := sin(time_s*10.0)*0.28 if is_extracting else 0.0
		draw_set_transform(Vector2(45,7),visual_heading+swing,Vector2.ONE)
		draw_line(Vector2.ZERO,Vector2(19,20),Color("#b57e56"),6.0,true)
		draw_colored_polygon(PackedVector2Array([
			Vector2(15,13),Vector2(19,-9),Vector2(34,-18),Vector2(32,-9),Vector2(22,17)
		]),Color("#b7d6d7"))
		draw_line(Vector2(18,-7),Vector2(32,-13),Color("#6ce5e9"),2.0,true)
	elif equipped_tool == "emptyCylinder":
		draw_rect(Rect2(42,-7,14,29),Color("#789baa"))
		draw_rect(Rect2(44,-4,10,23),Color("#0c3950"))
		draw_rect(Rect2(45,9,8,9),Color("#5be6db"))
		draw_rect(Rect2(44,-10,10,4),Color("#f6ce91"))
		draw_circle(Vector2(49,-12),3.0,Color("#97e0e6"))

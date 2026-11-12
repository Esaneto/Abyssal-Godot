extends CharacterBody2D
## Explorador nativo: movimento submarino continuo, sem combate.
## Colisoes Godot, nado com aceleracao/arrasto, flutuabilidade e correntes.
signal diver_died
const Look = preload("res://scripts/diver_appearance.gd")
const NativeRig = preload("res://scripts/native_diver_rig.gd")
const InkSwimmer = preload("res://scripts/anime_swimmer_ink.gd")

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
	# High-resolution texture mesh with independently deforming hair/fins, not the older polygon doll.
	anime_rig.update_look(appearance,time_s,false,true)
	anime_rig.rotation = 0.0
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
	if anime_rig != null:
		anime_rig.rotation = visual_heading
		anime_rig.update_look(appearance,time_s,is_moving or is_propelling,true)
	if propulsion_bubbles != null:
		propulsion_bubbles.emitting = is_propelling
		propulsion_bubbles.position = Vector2(-58.0, 10.0).rotated(visual_heading)
		propulsion_bubbles.rotation = visual_heading
	if anime_rig == null or not anime_rig.has_visible_character():
		queue_redraw()

func set_appearance(candidate: Dictionary) -> void:
	appearance = Look.normalize(candidate)
	if anime_rig != null:
		anime_rig.update_look(appearance,time_s,is_moving,true)
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
	# Only fallback to hand-inked procedural artwork if an imported texture is actually missing.
	if anime_rig != null and anime_rig.has_visible_character():
		return
	draw_set_transform(Vector2.ZERO,visual_heading,Vector2.ONE)
	InkSwimmer.paint(self,appearance,time_s,is_moving,is_propelling,
		equipped_tool,is_extracting,velocity.length())
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

extends SceneTree
## Run with: godot --headless --path godot-client --script res://scripts/ci_smoke.gd
func _initialize() -> void:
	call_deferred("_smoke")

func _smoke() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("Cena principal nao carregou")
		quit(2)
		return
	var main := scene.instantiate()
	root.add_child(main)
	await process_frame
	var bridge := main.get_node_or_null("CinematicCabin3D")
	if bridge == null or bridge.call("texture") == null:
		push_error("Cabine 3D cinematografica nao inicializou")
		quit(9)
		return
	# Performance invariant: the ocean world must not exist behind the cabin.
	if main.get_node_or_null("ExpedicaoOceanica") != null:
		push_error("Expedicao Oceanica foi carregada escondida no menu")
		quit(3)
		return
	var command_bridge = main.get_node_or_null("OriginalAnimatedPilot")
	if command_bridge == null or command_bridge.call("texture") == null:
		push_error("Animated cabin pilot not initialized")
		quit(22)
		return
	var high_res_art = load("res://scripts/anime_diver_art.gd")
	if high_res_art.texture_for("female") == null or high_res_art.texture_for("male") == null:
		push_error("Committed high-resolution diver assets failed to load")
		quit(20)
		return
	main.call("_start_sea")
	await physics_frame
	var world := main.get_node_or_null("ExpedicaoOceanica")
	if world == null:
		push_error("Expedicao Oceanica nao foi criada ao mergulhar")
		quit(3)
		return
	if world.get_node_or_null("Native3DOcean") != null:
		push_error("Preview 3D foi carregado sem ser solicitado")
		quit(10)
		return
	if not world.visible:
		push_error("Mar Aberto nao abriu")
		quit(4)
		return
	var diver := world.get_node_or_null("Mergulhador")
	if diver == null:
		push_error("Mergulhador nativo ausente")
		quit(5)
		return
	var old_y: float = diver.position.y
	Input.action_press("move_down")
	for i in range(35):
		await physics_frame
	Input.action_release("move_down")
	if diver.position.y <= old_y + 10.0:
		push_error("Fisica de mergulho nao respondeu ao controle")
		quit(6)
		return

	# Six-axis cardinal and diagonal orientation is driven by swimming input.
	if absf(wrapf(float(diver.visual_heading)-PI*0.5,-PI,PI)) > 0.28:
		push_error("Diver did not turn downward while swimming down")
		quit(11)
		return
	Input.action_press("move_up")
	for frame in range(36):
		await physics_frame
	Input.action_release("move_up")
	if absf(wrapf(float(diver.visual_heading)+PI*0.5,-PI,PI)) > 0.28:
		push_error("Diver did not turn upward")
		quit(12)
		return
	Input.action_press("move_right")
	Input.action_press("move_up")
	for frame in range(32):
		await physics_frame
	Input.action_release("move_up")
	if absf(wrapf(float(diver.visual_heading)+PI*0.25,-PI,PI)) > 0.28:
		push_error("Diver did not turn diagonally")
		quit(13)
		return
	var profile = main.progress
	if profile.get_count("propulsionUnit") != 1 or not profile.select_tool("propulsionUnit"):
		push_error("Starting propulsion unit missing")
		quit(14)
		return
	diver.set_equipped_tool("propulsionUnit")
	var initial_charge: float = diver.propulsion_energy
	Input.action_press("boost")
	for frame in range(28):
		await physics_frame
	Input.action_release("boost")
	Input.action_release("move_right")
	if not diver.propulsion_energy < initial_charge-5.0:
		push_error("Hydrojet did not consume energy")
		quit(15)
		return
	if diver.swim_force.length() < 500.0:
		push_error("Hydrojet did not apply physical thrust")
		quit(16)
		return
	if diver.propulsion_bubbles == null:
		push_error("Hydrojet bubble emitter missing")
		quit(17)
		return
	var discharge: float = diver.propulsion_energy
	for frame in range(45):
		await physics_frame
	if diver.propulsion_energy <= discharge:
		push_error("Hydrojet did not recharge")
		quit(18)
		return
	var anime_ink = load("res://scripts/anime_swimmer_ink.gd")
	var immersion_hud = load("res://scripts/abyss_hud_immersive.gd")
	if anime_ink == null or immersion_hud == null:
		push_error("Anime diver ink or immersive HUD failed to load")
		quit(19)
		return
	var ecology = load("res://scripts/marine_ecology.gd")
	if ecology == null or ecology.SPECIES.size() < 8:
		push_error("Catalogo da fauna ausente ou incompleto")
		quit(7)
		return
	for species in ecology.SPECIES:
		if float(species["length_px"]) < ecology.MIN_LENGTH_PX:
			push_error("Criatura abaixo da escala minima: " + species["id"])
			quit(8)
			return
	main.call("_unhandled_input", InputEventKey.new())
	print("GODOT_SMOKE_PASS: cabine 3D, oceano 3D, fisica 2D, fauna e progressao")
	quit(0)

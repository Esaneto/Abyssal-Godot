extends Node
## New original cabin pilot art is physically bundled and animated on a deforming mesh.
## Unlike the old paper-doll SVG, this is a separate upright command-bridge character.
const FEMALE := preload("res://assets/art/character/abyssal_pilot_cabin_female.webp")
const MALE := preload("res://assets/art/character/abyssal_pilot_cabin_male.webp")
const PILOT_SHADER := preload("res://shaders/animated_cabin_pilot.gdshader")
var viewport: SubViewport
var portrait: MeshInstance2D
var shader_material: ShaderMaterial
var selected_body := ""

func _ready() -> void:
	viewport = SubViewport.new()
	viewport.name = "Articulated anime pilot transparent layer"
	viewport.size = Vector2i(420,736)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	portrait = MeshInstance2D.new()
	portrait.name = "Breathing and hair rig"
	portrait.mesh = _mesh()
	portrait.position = Vector2(15,0)
	portrait.texture = FEMALE
	shader_material = ShaderMaterial.new()
	shader_material.shader = PILOT_SHADER
	portrait.material = shader_material
	viewport.add_child(portrait)
	selected_body = "female"

func _mesh() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var idx := PackedInt32Array()
	var x_steps := 24
	var y_steps := 40
	for yi in range(y_steps+1):
		for xi in range(x_steps+1):
			var u := float(xi)/float(x_steps)
			var v := float(yi)/float(y_steps)
			vertices.append(Vector3(u*390.0,v*736.0,0.0))
			uvs.append(Vector2(u,v))
	for yi in range(y_steps):
		for xi in range(x_steps):
			var a := yi*(x_steps+1)+xi
			var b := a+1
			var c := a+x_steps+1
			var d := c+1
			idx.append_array(PackedInt32Array([a,b,c,b,d,c]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = idx
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return result

func update_appearance(candidate: Dictionary, time_s: float) -> void:
	if portrait == null:
		return
	var body := str(candidate.get("body","female"))
	if body != selected_body:
		selected_body = body
		portrait.texture = MALE if body=="male" else FEMALE
	shader_material.set_shader_parameter("anim_time",time_s)
	shader_material.set_shader_parameter("long_hair",1.0 if body!="male" else 0.0)
	shader_material.set_shader_parameter("breath",0.5+0.5*sin(time_s*1.25))

func texture() -> Texture2D:
	return viewport.get_texture()

func set_enabled(enabled: bool) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	if viewport != null:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if enabled else SubViewport.UPDATE_DISABLED
	if portrait != null:
		portrait.visible = enabled

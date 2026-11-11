shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;

// Lightweight moving underwater refraction: no static screenshot or texture.
uniform vec4 water_tint : source_color = vec4(0.06, 0.28, 0.37, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.55;

void fragment() {
	vec2 p = UV * vec2(15.0, 8.0);
	float a = sin(p.x * 2.1 + TIME * 0.42 + sin(p.y * 1.3 - TIME * 0.25));
	float b = cos(p.y * 2.6 - TIME * 0.30 + sin(p.x * 0.9 + TIME * 0.14));
	float bands = pow(max(0.0, a * b), 5.0);
	float ripple = sin((UV.y + sin(UV.x * 18.0 + TIME * 0.45) * 0.007) * 87.0 + TIME * 0.22);
	ALBEDO = water_tint.rgb + vec3(0.18, 0.45, 0.54) * bands;
	EMISSION = vec3(0.035, 0.15, 0.19) * bands * intensity;
	ALPHA = intensity * (0.070 + bands * 0.072 + ripple * 0.007);
}

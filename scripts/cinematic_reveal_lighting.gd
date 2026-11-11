extends RefCounted
## Cinematic 2.5D lighting: light is selective; darkness carries the composition.
## All light masks are drawn in world coordinates and track the living diver.
## No still-image background and no full-screen opaque blackout.

static func grade(c: CanvasItem, area: Rect2, focus: Vector2, heading: float,
		depth: float, solar: float, t: float) -> void:
	var abyss := smoothstep(105.0,820.0,depth)
	var night := 1.0-solar
	var base := clampf(0.27+abyss*0.43+night*0.21,0.16,0.86)
	# Thin transparent ink across all geometry, before a directional reveal.
	c.draw_rect(area,Color(0.005,0.011,0.027,base*0.34))
	# Polygonal annuli form a feathered radial mask. Darkest outside, open at
	# the diver and along the direction of the lamp. Avoid hard flashlight wedges.
	var sectors := 48
	var rings := 13
	var max_radius := maxf(area.size.x,area.size.y)*1.35
	var forward := Vector2.RIGHT.rotated(heading)
	for ring in range(rings):
		var inner := max_radius*float(ring)/float(rings)
		var outer := max_radius*float(ring+1)/float(rings)
		for segment in range(sectors):
			var a0 := TAU*float(segment)/float(sectors)
			var a1 := TAU*float(segment+1)/float(sectors)
			var amid := (a0+a1)*0.5
			var direction := Vector2(cos(amid),sin(amid))
			var facing := maxf(0.0,direction.dot(forward))
			var beam := pow(facing,7.0)
			var near := smoothstep(105.0,560.0,inner)
			var ink := base*(0.14+0.66*near)*(1.0-0.78*beam)
			# Shallow water keeps a broad reading window, abyss stays intimate.
			ink *= lerpf(0.59,1.0,abyss)
			ink = clampf(ink,0.0,0.83)
			if ink<0.013:
				continue
			var p0 := focus+Vector2(cos(a0),sin(a0))*inner
			var p1 := focus+Vector2(cos(a1),sin(a1))*inner
			var p2 := focus+Vector2(cos(a1),sin(a1))*outer
			var p3 := focus+Vector2(cos(a0),sin(a0))*outer
			c.draw_colored_polygon(PackedVector2Array([p0,p1,p2,p3]),
				Color(0.003,0.009,0.023,ink))
	# Bioluminescent islands in the darkness. Pools breathe slowly, never blink.
	for i in range(4):
		var k := float(i)
		var px := floorf(focus.x/1100.0)*1100.0+300.0+k*330.0
		var py := focus.y+230.0*sin(k*2.5+floorf(focus.y/900.0))
		var p := Vector2(px,py)
		if not area.grow(150.0).has_point(p):
			continue
		var strength := (0.020+0.026*sin(t*0.45+k)*sin(t*0.45+k))*abyss
		for halo in range(5):
			c.draw_arc(p,18.0+float(halo)*14.0,0.0,TAU,32,
				Color(0.14,0.66,0.72,strength*(1.0-float(halo)/5.0)),1.7,true)

static func diver_tint(depth: float, solar: float) -> Color:
	var shade := clampf(0.16+0.52*smoothstep(95.0,900.0,depth)+(1.0-solar)*0.18,0.0,0.76)
	# The protagonist remains readable as an outline, not a bright flat sticker.
	return Color(1.0-shade*0.78,1.0-shade*0.69,1.0-shade*0.58,1.0)

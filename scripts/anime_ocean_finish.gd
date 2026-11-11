extends RefCounted
## Inked 2.5D ocean atmosphere. Every stroke is generated and animated in-world.
## Draws behind the live character and fauna; it never replaces gameplay geometry.
static func background(c: CanvasItem, area: Rect2, t: float, sunlight: float, depth_m: float) -> void:
	var shallow := clampf(exp(-depth_m/240.0)*sunlight,0.0,1.0)
	var ink := Color("#061b2b")
	# Three slow parallax strata of jagged seabed silhouettes; muted, not neon.
	for layer in range(3):
		var z := float(layer)
		var baseline := area.position.y+area.size.y*(0.72+z*0.105)
		var vertices := PackedVector2Array()
		for i in range(31):
			var px := area.position.x+float(i)/30.0*area.size.x
			var displaced := 23.0*sin(px*(0.005+z*0.002)+z*3.3)+10.0*sin(px*0.015+z)
			var drift := sin(t*0.08+z)*4.0
			vertices.append(Vector2(px,baseline+displaced+drift))
		vertices.append(Vector2(area.end.x,area.end.y+240.0))
		vertices.append(Vector2(area.position.x,area.end.y+240.0))
		c.draw_colored_polygon(vertices,Color(0.035+z*0.009,0.12+z*0.01,0.18+z*0.007,0.17+z*0.065))
	# A limited number of caustic strokes fade naturally with depth and night.
	if shallow>0.04:
		for i in range(16):
			var seed := float(i)*0.91
			var px := floorf(area.position.x/170.0)*170.0+float(i)*170.0
			var bend := 22.0*sin(t*0.36+seed)
			var top := area.position.y-18.0
			var bottom := minf(area.end.y,area.position.y+470.0)
			c.draw_colored_polygon(PackedVector2Array([
				Vector2(px+bend,top),Vector2(px+11.0+bend,top),
				Vector2(px+65.0+bend,bottom),Vector2(px+23.0+bend,bottom)
			]),Color(0.53,0.84,0.91,shallow*0.012))
	# Subtle sketched current lines visually connect the water to its inertia.
	for i in range(18):
		var x := floorf(area.position.x/105.0)*105.0+float(i)*105.0+12.0
		var y := area.position.y+83.0+fposmod(float(i*117)+t*(2.0+float(i%3)),maxf(100.0,area.size.y-150.0))
		var wave := 8.0*sin(t*0.45+x*0.016)
		c.draw_arc(Vector2(x,y+wave),21.0,PI*0.87,PI*1.64,12,
			Color(0.47,0.75,0.80,0.045+shallow*0.028),1.1,true)

static func foreground(c: CanvasItem, area: Rect2, t: float, depth_m: float) -> void:
	# Foreground vegetation is anchored to the bottom edges and swings in currents.
	var l := clampf(1.0-depth_m/560.0,0.0,1.0)
	if l>0.01:
		for side in [0,1]:
			for i in range(7):
				var seed := float(i)+float(side)*8.2
				var x := area.position.x+30.0+float(i)*36.0 if side==0 else area.end.x-30.0-float(i)*36.0
				var y := area.end.y+70.0
				var height := (85.0+float(i%4)*41.0)*l
				var top := Vector2(x+17.0*sin(t*0.54+seed),y-height)
				var middle := Vector2(x+8.0*sin(t*0.45+seed*0.61),y-height*0.58)
				c.draw_line(Vector2(x,y),middle,Color(0.025,0.10,0.11,0.33),6.0,true)
				c.draw_line(middle,top,Color(0.065,0.24,0.24,0.41),3.5,true)
				for j in range(3):
					var origin := middle.lerp(top,float(j)/3.0)
					var tip := origin+Vector2((19.0+float(j)*7.0)*(1.0 if j%2==0 else -1.0),-13.0+sin(t*0.42+seed)*6.0)
					c.draw_line(origin,tip,Color(0.12,0.33,0.28,0.41),2.7,true)
	# Drifting foreground bioluminescent plankton is densest in the abyss.
	var darkness := clampf((depth_m-230.0)/650.0,0.0,1.0)
	for i in range(40):
		var k := float(i)
		var x := area.position.x+fposmod(k*331.1+sin(t*0.17+k)*21.0,area.size.x)
		var y := area.position.y+fposmod(k*137.7-t*(6.0+k*0.09),area.size.y)
		var glow := 0.09+darkness*0.25
		c.draw_circle(Vector2(x,y),0.9+float(i%3)*0.4,Color(0.54,0.92,0.91,glow))
	# Darkened view edges for claustrophobic exploration without hiding the HUD.
	for i in range(5):
		var wide := 25.0+float(i)*26.0
		var alpha := 0.035+float(i)*0.009
		c.draw_rect(Rect2(area.position.x+float(i)*25.0,area.position.y,wide,area.size.y),
			Color(0.005,0.016,0.035,alpha))
		c.draw_rect(Rect2(area.end.x-wide-float(i)*25.0,area.position.y,wide,area.size.y),
			Color(0.005,0.016,0.035,alpha))


static func film_grade(c: CanvasItem, area: Rect2, focus: Vector2, t: float, solar: float, depth_m: float) -> void:
	# Animated color grading, a dim live scene rather than a static dark overlay screenshot.
	var darkness := clampf(0.09 + (1.0-solar)*0.16 + depth_m/1600.0*0.14,0.05,0.36)
	c.draw_rect(area,Color(0.006,0.014,0.035,darkness))
	# Radial, stepped penumbra around the explorer, gently shifted by the currents.
	var dist_x := maxf(1.0,area.size.x)
	var dist_y := maxf(1.0,area.size.y)
	for band in range(7):
		var b := float(band)
		var inset := b * 22.0
		var alpha := (0.010+b*0.002)*(0.45+depth_m/1000.0)
		c.draw_rect(Rect2(area.position.x+inset,area.position.y+inset,dist_x-inset*2.0,16.0),
			Color(0.004,0.013,0.026,alpha))
		c.draw_rect(Rect2(area.position.x+inset,area.end.y-inset-16.0,dist_x-inset*2.0,16.0),
			Color(0.004,0.013,0.026,alpha))
	# Occasional flowing caustic arcs move across visible rocks and coral tops.
	var sunlight := clampf(solar*exp(-depth_m/210.0),0.0,1.0)
	if sunlight>0.045:
		for i in range(11):
			var f := float(i)
			var px := floorf(area.position.x/145.0)*145.0+f*145.0
			var py := area.position.y+fposmod(f*137.0+t*6.0,maxf(200.0,area.size.y))
			var bend := sin(t*0.29+f*1.6)*12.0
			c.draw_arc(Vector2(px+bend,py),21.0+float(i%3)*8.0,PI*0.17,PI*0.77,12,
				Color(0.57,0.78,0.78,sunlight*0.035),1.2,true)
	# Fine, drifting underwater motes are brighter near the flashlight.
	for i in range(26):
		var k := float(i)
		var px := area.position.x+fposmod(k*97.7+sin(t*0.21+k)*15.0,area.size.x)
		var py := area.position.y+fposmod(k*229.1-t*12.0,area.size.y)
		var near := clampf(1.0-Vector2(px,py).distance_to(focus)/400.0,0.0,1.0)
		c.draw_circle(Vector2(px,py),0.55+float(i%3)*0.23,
			Color(0.56,0.75,0.78,0.055+near*0.20))

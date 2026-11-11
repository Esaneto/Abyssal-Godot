extends RefCounted
## Live cinematic distant life. Visual-only schools are not collectible organisms.
## Deterministic world cells keep positions stable while the camera streams horizontally.
## All shapes are freshly drawn each frame; nothing is a static background image.

static func draw_ambient(c: CanvasItem, area: Rect2, seconds: float, depth: float, sunlight: float) -> void:
	var depth_dim := clampf(exp(-depth/590.0),0.10,1.0)
	var visibility := clampf(0.30*depth_dim + 0.11*sunlight,0.065,0.35)
	var start_x := int(floor(area.position.x / 920.0)) - 1
	var end_x := int(ceil(area.end.x / 920.0)) + 1
	var start_y := int(floor(area.position.y / 570.0)) - 1
	var end_y := int(ceil(area.end.y / 570.0)) + 1
	for cy in range(start_y,end_y+1):
		for cx in range(start_x,end_x+1):
			var seed := float(cx*73+cy*199)
			var wave := sin(seed*1.35)
			if wave < -0.31:
				continue
			var center := Vector2((float(cx)+0.44+0.17*sin(seed))*920.0,
				(float(cy)+0.29+0.34*absf(sin(seed*2.27)))*570.0)
			# Schools travel together, without drawing a perfect repeated grid.
			var flow := Vector2(46.0*sin(seconds*0.115+seed),
				17.0*sin(seconds*0.083+seed*0.7))
			var school_center := center+flow
			if not area.grow(125.0).has_point(school_center):
				continue
			var count := 6+int(absf(sin(seed))*8.0)
			var facing := 1.0 if sin(seed*0.69)>0.0 else -1.0
			for i in range(count):
				var k := float(i)
				var x := k*26.0+sin(k*1.67+seed)*8.0
				var row := float(i%4)-1.5
				var offset := Vector2(x*facing,row*16.0+sin(seconds*0.82+k*0.69)*5.0)
				var animal := school_center+offset
				if not area.grow(35.0).has_point(animal):
					continue
				var size := 3.1+float(i%5)*1.18
				var opacity := visibility*(0.30+0.45*(1.0-absf(row)*0.28))
				_fish(c,animal,size,facing,seconds+k*0.63,opacity)
	# Slow suspended spores have different velocities from fish; no repeated sky stars.
	for i in range(54):
		var k := float(i)
		var x := area.position.x+fposmod(123.7*k+19.0*sin(k*0.66+seconds*0.22),area.size.x)
		var y := area.position.y+fposmod(k*171.9-seconds*(3.9+float(i%4)),area.size.y)
		var r := 0.5+float(i%3)*0.32
		c.draw_circle(Vector2(x,y),r,Color(0.52,0.74,0.73,0.075+visibility*0.21))

static func _fish(c: CanvasItem, at: Vector2, length: float, facing: float,
		seconds: float, alpha: float) -> void:
	var pulse := sin(seconds*4.5)
	var tone := Color(0.22,0.39,0.45,alpha)
	var light := Color(0.48,0.64,0.68,alpha*0.42)
	var front := at+Vector2(length*facing,0)
	var tail := at-Vector2(length*facing*0.85,0)
	c.draw_colored_polygon(PackedVector2Array([
		front,at+Vector2(-0.7*facing,-length*0.34),
		tail,at+Vector2(-0.7*facing,length*0.34)
	]),tone)
	var tail_tip := tail+Vector2(-length*facing*0.61,0)
	c.draw_colored_polygon(PackedVector2Array([
		tail,tail_tip+Vector2(0,-length*0.53+pulse*0.50),
		tail_tip+Vector2(0,length*0.53+pulse*0.50)
	]),tone)
	c.draw_line(at+Vector2(0,-length*0.15),front,light,0.65,true)

static func draw_lurking_depth(c: CanvasItem, area: Rect2, seconds: float, depth: float) -> void:
	# Rare remote silhouettes at depth: deliberately non-interactive parallax art.
	# Nothing resembling a large threat appears in every chunk.
	if depth < 380.0:
		return
	var cell := int(floor(area.position.x / 5200.0))
	for i in range(2):
		var index := cell+i
		if posmod(index*37+11,7)>1:
			continue
		var x := (float(index)+0.48)*5200.0+sin(seconds*0.065+float(index))*210.0
		var y := area.position.y+area.size.y*(0.27+0.12*sin(float(index)*0.91))
		if not area.grow(530.0).has_point(Vector2(x,y)):
			continue
		var p := Vector2(x,y)
		var darkness := clampf((depth-370.0)/950.0,0.0,1.0)
		var size := 185.0+float(posmod(index,3))*67.0
		var back := Vector2(-size,0)
		var forward := Vector2(size*0.7,0)
		var hue := Color(0.01,0.035,0.055,0.10+darkness*0.11)
		c.draw_colored_polygon(PackedVector2Array([
			p+back,p+Vector2(-size*0.27,-size*0.22),p+Vector2(size*0.23,-size*0.12),
			p+forward,p+Vector2(size*0.32,size*0.10),p+Vector2(-size*0.35,size*0.15)
		]),hue)
		var rear := p+back
		c.draw_colored_polygon(PackedVector2Array([
			rear,rear+Vector2(-size*0.32,-size*0.19),
			rear+Vector2(-size*0.26,size*0.16)
		]),hue)
		# Single low-energy photophore, never a giant fluorescent decoration.
		c.draw_circle(p+Vector2(size*0.47,-size*0.025),2.0,
			Color(0.32,0.76,0.78,0.16+darkness*0.25))

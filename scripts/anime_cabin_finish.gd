extends RefCounted
## Animated 2.5D ink overlay for the 3D command bridge.
## Functional instrument buttons remain in the native cabin UI.
static func paint(c: CanvasItem, t: float) -> void:
	var warm := Color("#e0a96e")
	var teal := Color("#6cbdc4")
	# Filmic shadow grade reduces the cyan prototype appearance without hiding ocean life.
	c.draw_rect(Rect2(0.0,76.0,1280.0,535.0),Color(0.015,0.020,0.037,0.26))
	# Warm industrial ceiling, contrasted with the blue deep sea beyond.
	c.draw_rect(Rect2(0.0,92.0,1280.0,18.0),Color(0.12,0.064,0.041,0.36))
	# Stylized hatchwork follows pressure-hull contours, but never covers faces.
	for ix in [39.0, 82.0, 454.0, 832.0, 1237.0]:
		for j in range(15):
			var y := 42.0+float(j)*34.0
			c.draw_line(Vector2(ix-11.0,y+9.0),Vector2(ix+9.0,y-9.0),
				Color(0.025,0.055,0.09,0.16),1.4,true)
	# Painterly floating light reflections, subdued and timed rather than a fixed image.
	for i in range(16):
		var n := float(i)
		var px := 85.0+fposmod(n*183.7+sin(t*0.19+n)*13.0,1150.0)
		var py := 180.0+fposmod(n*83.1-t*(1.8+n*0.11),325.0)
		c.draw_circle(Vector2(px,py),0.8+float(i%3)*0.35,Color(0.66,0.87,0.90,0.22))
	# Subtle moving window reflections.
	for i in range(6):
		var x := 120.0+float(i)*210.0+sin(t*0.23+float(i))*11.0
		c.draw_line(Vector2(x,91),Vector2(x+19.0,394),Color(0.62,0.91,0.98,0.09),1.8,true)
		c.draw_line(Vector2(x+5.0,91),Vector2(x+26.0,394),Color(0.14,0.72,0.80,0.04),3.6,true)
	# Warm brass corner highlights give the impression of a hand-inked anime set.
	for side in [0,1]:
		var x := 23.0 if side==0 else 1257.0
		var sx := 1.0 if side==0 else -1.0
		c.draw_line(Vector2(x,82),Vector2(x+sx*76.0,82),Color(warm.r,warm.g,warm.b,0.30),2.0,true)
		c.draw_line(Vector2(x,82),Vector2(x,145.0),Color(warm.r,warm.g,warm.b,0.30),2.0,true)
	# Slowly fluctuating systems telemetry, not a static UI backdrop.
	for i in range(5):
		var x := 525.0+float(i)*33.0
		var h := 8.0+16.0*(0.5+0.5*sin(t*1.3+float(i)*1.91))
		c.draw_rect(Rect2(x,34.0-h*0.18,19.0,h),Color(teal.r,teal.g,teal.b,0.17))
	# Visible labels for the industrial layout.
	c.draw_string(ThemeDB.fallback_font,Vector2(29,49),"A B Y S S A L    /    CENTRO DE COMANDO",
		HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.79,0.90,0.89,0.85))
	c.draw_string(ThemeDB.fallback_font,Vector2(963,49),"SISTEMAS OCEANICOS   •   MODO LOCAL",
		HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(0.86,0.69,0.48,0.79))

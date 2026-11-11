extends RefCounted
## Immersive expedition instruments: compact ink/bronze, no oversized neon dashboard.
## All values are live from existing physics, research, inventory and field guide.
const UI = preload("res://scripts/ui_art_primitives.gd")
const TOOLS := ["abyssPickaxe","emptyCylinder","propulsionUnit"]
const LABELS := ["PICARETA","AMOSTRADOR","HIDROJATO"]
const BRASS := Color("#ba9870")
const PAPER := Color("#d1dee0")
const MUTED := Color("#789ba5")
const SEA := Color("#6ea7a6")
const PANEL := Color(0.012,0.027,0.046,0.83)

static func _frame(c: CanvasItem, rect: Rect2, chosen: bool = false) -> void:
	c.draw_rect(rect,Color(0.006,0.013,0.026,0.77))
	c.draw_rect(Rect2(rect.position+Vector2(2,2),rect.size-Vector2(4,4)),PANEL)
	c.draw_line(rect.position+Vector2(8,2),rect.position+Vector2(rect.size.x-8,2),
		BRASS if chosen else Color(0.34,0.49,0.52,0.45),1.6,true)
	c.draw_line(rect.position+Vector2(1,12),rect.position+Vector2(1,rect.size.y-9),
		Color(0.19,0.31,0.37,0.54),1.0,true)
	for sign in [0.0,1.0]:
		var sx: float = rect.position.x+(8.0 if sign==0.0 else rect.size.x-8.0)
		c.draw_line(Vector2(sx,rect.position.y+rect.size.y-9),
			Vector2(sx+(-5 if sign==0 else 5),rect.position.y+rect.size.y-9),
			BRASS if chosen else MUTED.darkened(0.35),1.3,true)

static func _bar(c: CanvasItem, pos: Vector2, width: float, ratio: float,
	color: Color) -> void:
	c.draw_rect(Rect2(pos,Vector2(width,4.0)),Color("#162f3c"))
	c.draw_rect(Rect2(pos+Vector2(0,0),Vector2(width*clampf(ratio,0.0,1.0),4.0)),color)
	c.draw_rect(Rect2(pos+Vector2(0,0),Vector2(width,1.0)),Color(0.75,0.91,0.89,0.09))

static func paint(c: Node2D, rect: Rect2, diver: CharacterBody2D, progress: RefCounted,
	observed: int, nearest_deposit: Dictionary, extract_time: float, deposit_time: float,
	nearest_species: Dictionary, message: String, show_status: bool, sunlight: float) -> void:
	var x := rect.position.x
	var y := rect.position.y
	var top := Vector2(x+24.0,y+21.0)
	_frame(c,Rect2(top,Vector2(288.0,225.0)))
	UI.caption(c,"A B Y S S A L",top+Vector2(17,28),20,PAPER)
	UI.caption(c,"RELATORIO DE MERGULHO  /  SOLO",top+Vector2(17,46),10,MUTED)
	c.draw_line(top+Vector2(17,56),top+Vector2(268,56),Color(0.53,0.65,0.67,0.20),1.0,true)
	UI.caption(c,"PROFUNDIDADE",top+Vector2(17,76),11,MUTED)
	UI.caption(c,"%.0f m" % diver.depth_m,top+Vector2(163,78),20,PAPER)
	UI.caption(c,"PRESSAO",top+Vector2(17,96),11,MUTED)
	UI.caption(c,"%.1f atm" % (1.0+diver.depth_m/10.0),top+Vector2(190,96),13,PAPER)
	var oxygen := clampf(float(diver.oxygen)/maxf(1.0,float(diver.oxygen_capacity)),0.0,1.0)
	var health := clampf(float(diver.health)/maxf(1.0,float(diver.MAX_HEALTH)),0.0,1.0)
	var battery := clampf(float(diver.propulsion_energy)/maxf(1.0,float(diver.propulsion_capacity)),0.0,1.0)
	UI.caption(c,"O2   %d%%" % int(oxygen*100.0),top+Vector2(17,124),13,Color("#e0a08c") if oxygen<0.22 else PAPER)
	_bar(c,top+Vector2(126,116),144.0,oxygen,Color("#79c7c2"))
	UI.caption(c,"VIDA   %d%%" % int(health*100.0),top+Vector2(17,152),13,PAPER)
	_bar(c,top+Vector2(126,144),144.0,health,Color("#8eb2a5"))
	UI.caption(c,"PROPULSOR",top+Vector2(17,181),13,BRASS if diver.is_propelling else MUTED)
	_bar(c,top+Vector2(126,173),144.0,battery,BRASS if diver.is_propelling else SEA)
	if diver.depth_m > diver.safe_depth:
		UI.caption(c,"!  PRESSAO CRITICA",top+Vector2(17,211),12,Color("#f1a777"))
	else:
		var biome := "ZONA ILUMINADA" if diver.depth_m<190.0 else "PENUMBRA" if diver.depth_m<850.0 else "ZONA ABISSAL"
		UI.caption(c,biome,top+Vector2(17,211),11,Color("#89a4aa"))
	var state := "LUMINOSO" if sunlight>0.5 else "CREPUSCULO" if sunlight>0.16 else "ESCURO"
	UI.caption(c,"AMBIENTE  /  "+state,Vector2(x+rect.size.x-227.0,y+41.0),11,Color(0.66,0.80,0.78,0.72))
	UI.caption(c,"REGISTROS  %d" % observed,Vector2(x+rect.size.x-191.0,y+59.0),11,Color(0.66,0.80,0.78,0.56))
	if not nearest_deposit.is_empty():
		var panel_center := Vector2(x+rect.size.x*0.52,y+rect.size.y*0.39)
		_frame(c,Rect2(panel_center-Vector2(162,21),Vector2(324,45)))
		UI.caption(c,"SEGURE [G] PARA EXTRAIR",panel_center+Vector2(-140,5),13,PAPER)
		_bar(c,panel_center+Vector2(-139,11),280,extract_time/maxf(0.1,deposit_time),BRASS)
	elif not nearest_species.is_empty():
		var label := "F  OBSERVAR  •  "+str(nearest_species.get("name",""))
		UI.caption(c,label,Vector2(x+rect.size.x*0.48,y+rect.size.y*0.36),14,Color("#bad6ce"))
	if show_status:
		var note := Vector2(x+rect.size.x*0.49,y+rect.size.y*0.48)
		_frame(c,Rect2(note-Vector2(202,19),Vector2(410,39)))
		UI.caption(c,message,note+Vector2(-183,8),13,Color("#e4ba80"),371)
	# Three dedicated *equipment* slots; minerals remain browsable in I inventory.
	var slot_width := 89.0
	var slot_gap := 7.0
	var total := slot_width*3.0+slot_gap*2.0
	var base := Vector2(x+(rect.size.x-total)*0.5,y+rect.size.y-91.0)
	for index in range(3):
		var name: String = TOOLS[index]
		var left := base+Vector2(float(index)*(slot_width+slot_gap),0)
		var active: bool = progress != null and progress.selected_tool()==name
		_frame(c,Rect2(left,Vector2(slot_width,64.0)),active)
		UI.item(c,name,left+Vector2(25,29),0.76)
		UI.caption(c,str(index+1),left+Vector2(7,15),10,BRASS if active else MUTED)
		UI.caption(c,LABELS[index],left+Vector2(6,57),10,Color("#e6c89a") if active else MUTED)
		if index==2:
			_bar(c,left+Vector2(50,25),29.0,battery,BRASS if active else SEA)
	# The low-contrast footer never competes with the actual dive.
	UI.caption(c,"WASD  NADAR    1/2/3  EQUIPAR    SHIFT  PROPULSAO    G  EXTRAIR    F  OBSERVAR    I  INVENTARIO    V  VISUAL",
		Vector2(x+rect.size.x*0.14,y+rect.size.y-8),11,Color(0.54,0.68,0.68,0.47))

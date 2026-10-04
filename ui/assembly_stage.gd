extends Control
const Palette=preload("res://ui/demo_theme.gd")

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	var center:=size*.5
	var radius:=minf(size.x*.40,size.y*.46)
	draw_circle(center,radius,Color("211f26"))
	draw_arc(center,radius,-PI*.9,PI*.9,72,Palette.LINE,1,true)
	draw_arc(center,radius-12,PI*.18,PI*.82,32,Color("393038"),1,true)
	draw_line(Vector2(center.x-radius,center.y),Vector2(center.x-radius+24,center.y),Palette.GOLD,2)
	draw_line(Vector2(center.x+radius-24,center.y),Vector2(center.x+radius,center.y),Palette.GOLD,2)
	draw_string(ThemeDB.fallback_font,Vector2(12,size.y-6),"VISTA TÉCNICA · Montajes visuales",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Palette.MUTED)

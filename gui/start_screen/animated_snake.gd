extends Node2D
# what percentage of the way the snake is along its path. [0,1]
@export var distance : float = 0.0

enum {SLITHER, IDLE}
var state = SLITHER
@onready var points : PackedVector2Array
var body_color = Global.LIGHTEST
var body_percentage : float

func _draw():
	
	var length = points.size()
	var tail_point = int(length * (distance - body_percentage))
	var head_point = int(length * distance)
	
	# draw shadow
	#draw_set_transform(Vector2(-2, 2))
	#for i in range(length * .75):
	#	if i + tail_point < 0 : continue
	#	var width = clamp(ceil(15.0 * (1-cos(i * 2 * PI / length))), 1.0, 6.0)
	#	draw_circle(points[i + tail_point], width, Global.DARKEST)
	#draw_polyline(points.slice(max(0, tail_point), max(2, head_point + 1)), Global.DARKEST, 3.0)
	
	# draw body
	draw_set_transform(Vector2.ZERO)
	for i in range(length * body_percentage):
		if i + tail_point < 0 : continue
		var width = clamp(ceil(15.0 * (1-cos(i * 2 * PI / length))), 1.0, 5.0)
		draw_circle(points[i + tail_point], width, body_color)
	draw_polyline(points.slice(max(0, tail_point), max(2, head_point + 1)), body_color, 3.0)
	
	
	if state == IDLE:
		# draw highlight
		draw_set_transform(Vector2(1.5, -1.5))
		for i in range(0, length * .75, 1):
			if i + tail_point < 0 : continue
			var width = clamp(ceil(15.0 * (1-cos(i * 2 * PI / length))), 0.0, 5.0)
			draw_circle(points[i + tail_point], width / 2.0, Global.LIGHTEST)
		draw_polyline(points.slice(max(0, tail_point), max(2, head_point + 1)), Global.LIGHTEST, 1.0)

		# draw tongue
	
		draw_set_transform(points[-1] + Vector2(0, 7))
		var tongue_points : PackedVector2Array = $TonguePath.curve.tessellate_even_length(5, 2)
		var tongue_length = ceil(tongue_points.size() * max(0, -1 + 2 * sin(PI * get_tree().get_frame() / 60.0)))
		if tongue_length > 1:
			draw_polyline(tongue_points.slice(0,tongue_length), Global.DARK, 1.0)
		
		# draw head
		
		draw_set_transform(points[-1], PI / 2.0)
		
		draw_circle(Vector2(0,0), 9.0, Global.LIGHT)
		draw_circle(Vector2(7,0), 6.0, Global.LIGHT)
		draw_circle(Vector2(-7, 0), 3.0, Global.LIGHTEST)
		draw_circle(Vector2(-2,-3), 4.0, Global.LIGHTEST)
		draw_circle(Vector2(-2,3), 4.0, Global.LIGHTEST)
		draw_circle(Vector2(7,0), 4.0, Global.LIGHTEST)
		draw_circle(Vector2(4,0), 4.0, Global.LIGHTEST)
		# nostrils
		draw_circle(Vector2(11,-2), 1.0, Global.DARK)
		draw_circle(Vector2(11,2), 1.0, Global.DARK)
		#eyes
		draw_circle(Vector2(3,-7), 3.0, Global.DARK)
		draw_circle(Vector2(2,-8), .75, Global.LIGHTEST)
		draw_line(Vector2(5, -7), Vector2(1, -7), Global.DARKEST, 2.0)
		draw_arc(Vector2(3, -7), 3.0, PI/3, PI, 6, Global.LIGHTEST, 2.0)
		
		draw_circle(Vector2(3,7), 3.0, Global.DARK)
		draw_circle(Vector2(2,8), .75, Global.LIGHTEST)
		draw_line(Vector2(5, 7), Vector2(1, 7), Global.DARKEST, 2.0)
		draw_arc(Vector2(3, 7), 3.0, -PI/3, -PI, 6, Global.LIGHTEST, 2.0)
	else:
		#draw_set_transform(points[head_point -2], (points[head_point-1] - points[head_point-2]).angle())
		draw_set_transform(points[head_point -2], PI)
		draw_circle(Vector2(0,0), 9.0, body_color)
		draw_circle(Vector2(7,0), 6.0, body_color)
		#draw_circle(Vector2(3,-7), 3.0, Global.LIGHT)
		#draw_circle(Vector2(3,7), 3.0, Global.LIGHT)

	


func _ready():
	animate()
	
	

func _process(_delta):
	queue_redraw()


func animate():
	body_percentage = .35
	points = $SlitherPath.curve.tessellate_even_length(5, 2)
	state = SLITHER
	body_color = Global.LIGHTEST
	$AnimationPlayer.play("slither")
	await $AnimationPlayer.animation_finished
	body_percentage = .75
	points = $IdlePath.curve.tessellate_even_length(5, 2)
	body_color = Global.LIGHT
	state = IDLE
	$AnimationPlayer.play("idle")

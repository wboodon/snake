extends Node2D
# what percentage of the way the snake is along its path. [0,1]
@export var distance : float = 0.0

enum {SLITHER, IDLE}
var state = SLITHER

func _draw():
	var points : PackedVector2Array = $Path2D.curve.tessellate_even_length(5, 2)
	var length = points.size()
	var tail_point = int(length * (distance - 0.75))
	var head_point = int(length * distance)
	
	# draw shadow
	draw_set_transform(Vector2(-2, 2))
	for i in range(length * .75):
		if i + tail_point < 0 : continue
		var width = clamp(ceil(15.0 * (1-cos(i * 2 * PI / length))), 1.0, 6.0)
		draw_circle(points[i + tail_point], width, Global.DARKEST)
	draw_polyline(points.slice(max(0, tail_point), max(2, head_point + 1)), Global.DARKEST, 3.0)
	
	# draw tongue
	if state == IDLE:
		draw_set_transform(points[-1])
		var tongue_points : PackedVector2Array = $TonguePath.curve.tessellate_even_length(5, 2)
		var tongue_length = ceil(tongue_points.size() * max(0, -1 + 2 * sin(PI * get_tree().get_frame() / 60.0)))
		if tongue_length > 1:
			draw_polyline(tongue_points.slice(0,tongue_length), Global.DARKEST, 1.0)
	
	# draw body
	draw_set_transform(Vector2.ZERO)
	for i in range(length * .75):
		if i + tail_point < 0 : continue
		var width = clamp(ceil(15.0 * (1-cos(i * 2 * PI / length))), 1.0, 5.0)
		draw_circle(points[i + tail_point], width, Global.LIGHT)
	draw_polyline(points.slice(max(0, tail_point), max(2, head_point + 1)), Global.LIGHT, 3.0)
	
	# draw highlight
	draw_set_transform(Vector2(1.5, -1.5))
	for i in range(0, length * .75, 1):
		if i + tail_point < 0 : continue
		var width = clamp(ceil(15.0 * (1-cos(i * 2 * PI / length))), 0.0, 5.0)
		draw_circle(points[i + tail_point], width / 2.0, Global.LIGHTEST)
	draw_polyline(points.slice(max(0, tail_point), max(2, head_point + 1)), Global.LIGHTEST, 1.0)
	
	# draw head
	if state == IDLE:
		draw_set_transform(points[-1], PI / 2.0)
	else:
		draw_set_transform(points[head_point -2], (points[head_point-1] - points[head_point-2]).angle())
	
	draw_circle(Vector2(0,0), 9.0, Global.LIGHT)
	draw_circle(Vector2(7,0), 6.0, Global.LIGHT)
	draw_circle(Vector2(-1,-3), 5.0, Global.LIGHTEST)
	draw_circle(Vector2(-1,3), 5.0, Global.LIGHTEST)
	draw_circle(Vector2(7,0), 4.0, Global.LIGHTEST)
	# nostrils
	draw_circle(Vector2(11,-2), 1.0, Global.DARK)
	draw_circle(Vector2(11,2), 1.0, Global.DARK)
	#eyes
	draw_circle(Vector2(3,-7), 3.0, Global.DARK)
	draw_circle(Vector2(2,-8), .75, Global.LIGHTEST)
	draw_line(Vector2(5, -7), Vector2(1, -7), Global.DARKEST, 2.0)
	draw_arc(Vector2(3, -7), 3.0, PI/3, PI, 6, Global.LIGHT, 2.0)
	
	draw_circle(Vector2(3,7), 3.0, Global.DARK)
	draw_circle(Vector2(2,8), .75, Global.LIGHTEST)
	draw_line(Vector2(5, 7), Vector2(1, 7), Global.DARKEST, 2.0)
	draw_arc(Vector2(3, 7), 3.0, -PI/3, -PI, 6, Global.LIGHT, 2.0)
	


func _ready():
	animate()
	
	

func _process(_delta):
	queue_redraw()


func animate():
	state = SLITHER
	$AnimationPlayer.play("slither")
	await $AnimationPlayer.animation_finished
	state = IDLE
	$AnimationPlayer.play("idle")

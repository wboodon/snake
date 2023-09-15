extends Node2D
# what percentage of the way the snake is along its path. [0,1]
@export var distance : float = 0.0

func _draw():
	var points : PackedVector2Array = $Path2D.curve.tessellate_even_length(5, 2)
	var length = points.size()
		
	
	if distance == 1:
		var head_point = points[-1]
		var tongue_points : PackedVector2Array = $TonguePath.curve.tessellate_even_length(5, 2)
		var tongue_length = max(0, -1 + 2 * sin(PI * get_tree().get_frame() / 60.0))
		for i in range((tongue_points.size() * tongue_length) - 1):
			draw_line(tongue_points[i] + head_point, tongue_points[i+1] + head_point, Global.DARKEST, 1.0)
	
	var tail_point = int(length * (distance - 0.75))

	for i in range(length * .75):
		if i + tail_point < 0 : continue
		draw_circle(points[i + tail_point], min(floor(15.0 * (1-cos(i * 2 * PI / length))), 5.0), Global.LIGHTEST)
	
	


func _ready():
	animate()
	

func _process(_delta):
	queue_redraw()


func animate():
	$AnimationPlayer.play("slither")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")

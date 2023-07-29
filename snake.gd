extends Area2D

var rectangle : RectangleShape2D
var head : SnakeSquare
var tail : SnakeSquare
@onready var head_hitbox = $Head
enum {UP, DOWN, LEFT, RIGHT}
var direction = UP
var grow_next_move = false
var input_queue = []
signal dead
signal eat

# Called when the node enters the scene tree for the first time.
func _ready():
	rectangle = RectangleShape2D.new()
	rectangle.set_size(Vector2(Global.CELL_SIZE, Global.CELL_SIZE))
	new_square(Global.GRID_WIDTH / 2, Global.GRID_HEIGHT / 2)
	head = tail
	head.set_deferred("disabled", true)
	head_hitbox.position = head.position


func _unhandled_input(event):
	if event.is_action_pressed("up"):
		input_queue.push_back(UP)
	if event.is_action_pressed("down"):
		input_queue.push_back(DOWN)
	if event.is_action_pressed("left"):
		input_queue.push_back(LEFT)
	if event.is_action_pressed("right"):
		input_queue.push_back(RIGHT)
	while input_queue.size() > 4:
		input_queue.pop_front()

func new_square(x : int, y : int):
	tail = SnakeSquare.new(x, y, rectangle, tail)
	add_child(tail)

func _on_timer_timeout():
	# handle input queue
	var next_direction = -1
	while next_direction == -1 and not input_queue.is_empty():
		var input = input_queue.pop_front()
		if (direction == LEFT or direction == RIGHT) and (input == UP or input == DOWN):
			next_direction = input
		elif (input == LEFT or input == RIGHT) and (direction == UP or direction == DOWN):
			next_direction = input
	direction = next_direction if next_direction != -1 else direction
	
	# move the snake and add a new square if needed
	var new_x = head.pos.x
	var new_y = head.pos.y
	match direction:
		UP:
			new_y -= 1
		DOWN:
			new_y += 1
		LEFT:
			new_x -= 1
		RIGHT:
			new_x += 1
	if grow_next_move:
		grow_next_move = false
		new_square(new_x, new_y)
	else:
		tail.set_pos(new_x, new_y)
	if tail != head:
		head.prev = tail
		head.set_deferred("disabled", false)
		head = tail
		head.set_deferred("disabled", true)
		tail = tail.prev
		head.prev = null
	head_hitbox.position = head.position


func _on_head_area_entered(area):
	if area.is_in_group("snake") or area.is_in_group("border"):
		emit_signal("dead")
	elif area.is_in_group("food"):
		grow_next_move = true
		emit_signal("eat")


func is_spot_occupied(x : int, y : int) -> bool:
	var curr : SnakeSquare = tail
	while curr != head:
		if curr.pos.x == x and curr.pos.y == y:
			return true
		curr = curr.prev
	return false


class SnakeSquare extends CollisionShape2D:
	var pos = {"x" : 0, "y" : 0}
	var prev : SnakeSquare
		
	func _init(x : int, y : int, rect_shape : RectangleShape2D, previous : SnakeSquare):
		var color_rect = ColorRect.new()
		color_rect.set_color(Global.DARK)
		color_rect.set_size(Vector2(Global.CELL_SIZE, Global.CELL_SIZE))
		color_rect.position = Vector2(-.5 * Global.CELL_SIZE, -.5 * Global.CELL_SIZE)
		add_child(color_rect)
		set_shape(rect_shape)
		set_pos(x, y)
		prev = previous
	
	func set_pos(x : int, y : int):
		pos.x = x
		pos.y = y
		position = Vector2((.5 + x) * Global.CELL_SIZE, (.5 + y) * Global.CELL_SIZE)
	
	


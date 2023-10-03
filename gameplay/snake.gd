extends Area2D

var rectangle : RectangleShape2D
var head : SnakeSquare
var tail : SnakeSquare
@onready var head_hitbox = $Head
@onready var eat_sound_player : AudioStreamPlayer = $EatSoundPlayer
@onready var turn_sound_player : AudioStreamPlayer = $TurnSoundPlayer
enum {UP, DOWN, LEFT, RIGHT}
var direction = UP
var grow_next_move = true
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
	tail = SnakeSquare.new(x, y, rectangle, tail, $Sprite2D.duplicate(), direction)
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
	if next_direction != -1:
		direction = next_direction
		turn_sound_player.play()
	
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
		head.next_direction = direction
		head.update_sprite()
		head.set_deferred("disabled", false)
		
		head = tail
		
		head.next_direction = -1
		head.initial_direction = direction
		head.update_sprite()
		head.set_deferred("disabled", true)
		
		tail = tail.prev
		tail.initial_direction = -1
		tail.update_sprite()
		head.prev = null
		
	head_hitbox.position = head.position


func _on_head_area_entered(area):
	if area.is_in_group("snake") or area.is_in_group("border"):
		emit_signal("dead")
	elif area.is_in_group("food"):
		grow_next_move = true
		eat_sound_player.play()
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
	var sprite : Sprite2D
	var initial_direction = -1
	var next_direction = -1
		
	func _init( x : int, 
				y : int, 
				rect_shape : RectangleShape2D, 
				previous : SnakeSquare, 
				new_sprite : Sprite2D,
				direction):
		sprite = new_sprite
		sprite.visible = true
		add_child(sprite)
		set_shape(rect_shape)
		set_pos(x, y)
		initial_direction = direction
		prev = previous
		update_sprite()


	func set_pos(x : int, y : int):
		pos.x = x
		pos.y = y
		position = Vector2((.5 + x) * Global.CELL_SIZE, (.5 + y) * Global.CELL_SIZE)
	
	
	func update_sprite():
		# reset sprite
		sprite.rotation = 0.0
		sprite.flip_h = false
		sprite.flip_v = false
		if next_direction == -1:
			# head
			sprite.frame = 0
			var rot = 0.0
			if initial_direction > DOWN: rot -= 0.5
			if initial_direction % 2 == 1: rot += 1.0
			sprite.rotation = rot * PI
		elif initial_direction == -1:
			# tail
			sprite.frame = 3
			var rot = 0.0
			if next_direction > DOWN: rot -= 0.5
			if next_direction % 2 == 1: rot += 1.0
			sprite.rotation = rot * PI
		elif next_direction == initial_direction:
			# straight
			sprite.frame = 2
			sprite.rotation = (PI / 2.0) if initial_direction > DOWN else 0.0
		else:
			# bent
			sprite.frame = 1
			if initial_direction == DOWN or next_direction == UP:
				sprite.flip_v = true
			if initial_direction == RIGHT or next_direction == LEFT:
				sprite.flip_h = true

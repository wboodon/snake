extends Node2D

@onready var food : Area2D = $Food 
@onready var snake : Area2D = $Snake
@onready var border : Area2D = $Border

var all_positions : Array
var spawn_positions : PackedVector2Array

signal score
signal dead
signal win

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.size = Global.CELL_SIZE * Vector2(Global.GRID_WIDTH, Global.GRID_HEIGHT)
	
	var horizontal_rect = RectangleShape2D.new()
	horizontal_rect.set_size(Global.CELL_SIZE * Vector2(Global.GRID_WIDTH + 2, 1))
	var vertical_rect = RectangleShape2D.new()
	vertical_rect.set_size(Global.CELL_SIZE * Vector2(1, Global.GRID_HEIGHT + 2))
	
	var upper_border = CollisionShape2D.new()
	upper_border.set_shape(horizontal_rect)
	upper_border.position = Global.CELL_SIZE * Vector2(Global.GRID_WIDTH / 2.0, -.5)
	border.add_child(upper_border)
	
	var lower_border = CollisionShape2D.new()
	lower_border.set_shape(horizontal_rect)
	lower_border.position = Global.CELL_SIZE * Vector2(Global.GRID_WIDTH / 2.0,  .5 + Global.GRID_HEIGHT)
	border.add_child(lower_border)
	
	var left_border = CollisionShape2D.new()
	left_border.set_shape(vertical_rect)
	left_border.position = Global.CELL_SIZE * Vector2(-.5, Global.GRID_WIDTH / 2.0)
	border.add_child(left_border)
	
	var right_border = CollisionShape2D.new()
	right_border.set_shape(vertical_rect)
	right_border.position = Global.CELL_SIZE * Vector2(.5 + Global.GRID_WIDTH, Global.GRID_HEIGHT / 2.0)
	border.add_child(right_border)
	
	all_positions = []
	for i in range(0, Global.GRID_WIDTH):
		for j in range(0, Global.GRID_HEIGHT):
			all_positions.push_back(Vector2(i, j))
	
	move_food()


func move_food():
	# go through the remaining spawn positions, then generate them again and 
	# loop one more time
	for i in range(2):
		while len(spawn_positions) > 0:
			var new_pos : Vector2 = spawn_positions[-1]
			spawn_positions.remove_at(len(spawn_positions)-1)
			if not snake.is_spot_occupied(new_pos.x, new_pos.y):
				food.position = Global.CELL_SIZE * (new_pos + Vector2(.5, .5))
				return
		all_positions.shuffle()
		spawn_positions = PackedVector2Array(all_positions)
	
	emit_signal("win")


func _on_food_area_entered(area):
	emit_signal("score")
	move_food()


func _on_snake_dead():
	emit_signal("dead")

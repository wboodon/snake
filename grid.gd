extends Node2D

@onready var food : Area2D = $Food 
@onready var snake : Area2D = $Snake
@onready var border : Area2D = $Border

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
	
	move_food()

func move_food():
	var new_x = randi_range(0, Global.GRID_WIDTH - 1)
	var new_y = randi_range(0, Global.GRID_HEIGHT - 1)
	
	while snake.is_spot_occupied(new_x, new_y):
		new_x = randi_range(0, Global.GRID_WIDTH - 1)
		new_y = randi_range(0, Global.GRID_HEIGHT - 1)
	
	food.position = Global.CELL_SIZE * Vector2(.5 + new_x, .5 + new_y)


func _on_food_area_entered(area):
	move_food()

extends Control

@onready var pause_screen = $PauseScreen
@onready var game_over_screen = $GameOverScreen
@onready var score_text : RichTextLabel = %ScoreText
@onready var game = %Game

var grid_scene = preload("res://grid.tscn")
var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	get_tree().set_deferred("paused", true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	score_text.text = "[center]SCORE
" + str(score) + "


HIGH SCORE
" + str(Global.high_score) + "[/center]"


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			pause_screen.visible = false
			get_tree().paused = false
		else:
			pause_screen.visible = true
			get_tree().paused = true
	if event.is_action_pressed("restart"):
		final_score()
		new_game()


func new_game():
	if game.get_child_count() > 0:
		game.get_child(0).queue_free()
	
	var new_grid = grid_scene.instantiate()
	game.add_child(new_grid)
	
	new_grid.score.connect(_on_game_score)
	new_grid.dead.connect(_on_game_dead)
	
	score = 0

	game_over_screen.visible = false
	pause_screen.visible = false
	get_tree().paused = false


func final_score():
	if score > Global.high_score:
		Global.high_score = score

func _on_game_score():
	score += 1


func _on_game_dead():
	final_score()
	get_tree().paused = true
	game_over_screen.visible = true

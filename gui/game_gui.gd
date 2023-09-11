extends Control

@onready var score_text : RichTextLabel = %ScoreText
@onready var game = %Game
@onready var gui = $GUI
@onready var menu_title : RichTextLabel = %MenuTitle
@onready var resume_button = %ResumeButton
@onready var new_game_button = %NewGameButton
@onready var credits_button = %CreditsButton
@onready var controls_scroll = $ControlsScroll


var grid_scene = preload("res://gameplay/grid.tscn")
var score : int = 0

enum {START, GAME_OVER, PLAYING}
var state = START

var scroll_progress : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game_button.pressed.connect(new_game)
	resume_button.pressed.connect(resume)
	start_screen()
	# get_tree().set_deferred("paused", true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	scroll_progress += delta * 50
	if scroll_progress >= 792:
		scroll_progress = 0
	
	controls_scroll.scroll_horizontal = int(scroll_progress)
	
	score_text.text = "[center]SCORE
" + str(score) + "


HIGH SCORE
" + str(Global.high_score) + "[/center]"


func _unhandled_input(event):
	if state == PLAYING and event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()
	if event.is_action_pressed("restart"):
		final_score()
		new_game()


func start_screen():
	state = START
	gui.visible = true
	menu_title.text = "WELCOME!"
	resume_button.visible = false
	new_game_button.visible = true
	new_game_button.grab_focus()
	credits_button.visible = true
	get_tree().paused = true


func pause():
	gui.visible = true
	get_tree().paused = true
	resume_button.grab_focus()
	

func resume():
	gui.visible = false
	get_tree().paused = false


func new_game():
	if game.get_child_count() > 0:
		game.get_child(0).queue_free()
	
	var new_grid = grid_scene.instantiate()
	game.add_child(new_grid)
	
	new_grid.score.connect(_on_game_score)
	new_grid.dead.connect(_on_game_dead)
	
	score = 0

	menu_title.text = "PAUSED"
	resume_button.visible = true
	
	state = PLAYING
	gui.visible = false
	get_tree().paused = false


func final_score():
	if score > Global.high_score:
		Global.high_score = score


func _on_game_score():
	score += 1


func _on_game_dead():
	final_score()
	get_tree().paused = true
	state = GAME_OVER
	menu_title.text = "GAME OVER"
	resume_button.visible = false
	new_game_button.grab_focus()
	gui.visible = true


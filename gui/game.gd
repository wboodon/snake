extends Node2D

@onready var grid_viewport = %GridViewport
@onready var start_menu = %StartMenu
@onready var score_text = %ScoreText
@onready var record_text = %RecordText
@onready var in_game_gui = %InGameGUI

var grid_scene = preload("res://gameplay/grid.tscn")
var score : int = 0

enum {START, GAME_OVER, PLAYING}
var state = START


func _ready():
	get_tree().paused = true
	
	%StartNewGameButton.pressed.connect(new_game)
	%PauseNewGameButton.pressed.connect(new_game)
	%GameOverNewGameButton.pressed.connect(new_game)
	%ResumeButton.pressed.connect(resume)
	%PauseQuitButton.pressed.connect(open_start_menu)
	%GameOverQuitButton.pressed.connect(open_start_menu)
	
	open_start_menu()


func _unhandled_input(event):
	if state == PLAYING and event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()
	elif event.is_action_pressed("restart"):
		new_game()


func open_start_menu():
	state = START
	%StartMenu.visible = true
	%StartNewGameButton.grab_focus()


func new_game():
	var new_grid = grid_scene.instantiate()
	
	if grid_viewport.get_child_count() > 0:
		grid_viewport.get_child(0).queue_free()
	grid_viewport.add_child(new_grid)
	
	new_grid.score.connect(_on_game_score)
	new_grid.dead.connect(_on_game_dead)
	
	score = 0
	score_text.text = "[left]" + str(score) + "[/left]"
	
	hide_gui()
	in_game_gui.visible = true
	state = PLAYING
	get_tree().paused = false


func pause():
	get_tree().paused = true
	%PauseMenu.visible = true
	%ResumeButton.grab_focus()


func resume():
	hide_gui()
	get_tree().paused = false


func hide_gui():
	%StartMenu.visible = false
	%PauseMenu.visible = false
	%GameOverMenu.visible = false


func _on_game_score():
	score += 1
	score_text.text = "[left]" + str(score) + "[/left]"
	if score > Global.record: 
		Global.record = score 
		record_text.text = "[right]" + str(score) + "[/right]"


func _on_game_dead():
	state = GAME_OVER
	%GameOverMenu.visible = true
	%GameOverNewGameButton.grab_focus()
	get_tree().paused = true

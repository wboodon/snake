extends Node2D

@onready var grid_viewport = %GridViewport
@onready var start_menu = %StartMenu
@onready var score_text = %ScoreText
@onready var record_text = %RecordText
@onready var in_game_gui = %InGameGUI
@onready var palette_paths = []
@onready var palette_shader : ShaderMaterial = %PaletteSwapper.get("material")

var grid_scene = preload("res://gameplay/grid.tscn")
var score : int = 0
var palette = 0
enum {START, GAME_OVER, PLAYING, ANIMATION}
var state = START
var music_volume = 10
var sfx_volume = 10


func _ready():
	
	hide_gui()
	
	var dir = DirAccess.open("res://gui/palettes")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.match("*.png"):
				palette_paths.append(file_name)
			file_name = dir.get_next()
	update_palette()
	
	update_volume()
	
	get_tree().paused = true
	
	%StartNewGameButton.pressed.connect(new_game)
	%PauseNewGameButton.pressed.connect(new_game)
	%GameOverNewGameButton.pressed.connect(new_game)
	%ResumeButton.pressed.connect(resume)
	%PauseQuitButton.pressed.connect(open_start_menu)
	%GameOverQuitButton.pressed.connect(open_start_menu)
	%StartQuitButton.pressed.connect(get_tree().quit)
	%StartSettingsButton.pressed.connect(open_settings_menu)
	%PauseSettingsButton.pressed.connect(open_settings_menu)
	
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
	

func open_settings_menu():
	%SettingsMenu.visible = true
	%ExitSettingsButton.grab_focus()
	

func close_settings_menu():
	%SettingsMenu.visible = false
	match state:
		START:
			%StartNewGameButton.grab_focus()
		GAME_OVER:
			%GameOverNewGameButton.grab_focus()
		PLAYING:
			%ResumeButton.grab_focus()


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
	%CountdownLabel.visible = true
	state = ANIMATION
	
	for i in range(3,0,-1):
		%CountdownLabel.text = str(i)
		await get_tree().create_timer(1.0).timeout
	
	%CountdownLabel.visible = false
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
	%SettingsMenu.visible = false
	

func update_palette():
	palette = clampi(palette, 0, palette_paths.size() - 1)
	%PaletteNumberLabel.text = str(palette).pad_zeros(2)
	palette_shader.set("shader_parameter/palette", load("res://gui/palettes/" + palette_paths[palette]))
	
	%PaletteDecreaseButton.disabled = (palette == 0)
	%PaletteIncreaseButton.disabled = (palette == palette_paths.size() - 1)


func update_volume():
	music_volume = clampi(music_volume, 0, 10)
	sfx_volume = clampi(sfx_volume, 0, 10)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), (music_volume * 6) - 60)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), (sfx_volume * 6) - 60)
	
	%MusicNumberLabel.text = str(music_volume).pad_zeros(2)
	%MusicDecreaseButton.disabled = music_volume == 0
	%MusicIncreaseButton.disabled = music_volume == 10
	
	%SFXNumberLabel.text = str(sfx_volume).pad_zeros(2)
	%SFXDecreaseButton.disabled = sfx_volume == 0
	%SFXIncreaseButton.disabled = sfx_volume == 10


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


func _on_palette_decrease_button_pressed():
	palette -= 1
	update_palette()


func _on_palette_increase_button_pressed():
	palette += 1
	update_palette()


func _on_check_box_toggled(button_pressed):
	palette_shader.set("shader_parameter/invert", button_pressed)


func _on_music_decrease_button_pressed():
	music_volume -= 1
	update_volume()


func _on_music_increase_button_pressed():
	music_volume += 1
	update_volume()


func _on_sfx_decrease_button_pressed():
	sfx_volume -= 1
	update_volume()


func _on_sfx_increase_button_pressed():
	sfx_volume += 1
	update_volume()

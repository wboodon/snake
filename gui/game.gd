extends Node2D

@onready var grid_viewport = %GridViewport
@onready var start_menu = %StartMenu
@onready var score_text = %ScoreText
@onready var record_text = %RecordText
@onready var in_game_gui = %InGameGUI
#@onready var palette_paths = []
@onready var palette_shader : ShaderMaterial = %PaletteSwapper.get("material")

@export var palettes : Array[CompressedTexture2D]

var grid_scene = preload("res://gameplay/grid.tscn")
var score : int = 0
var palette = 0
enum {START, GAME_OVER, PLAYING, ANIMATION, USER_GESTURE}
var state = USER_GESTURE
var music_volume = 10
var sfx_volume = 10
var game_speed = 3
var play_focus_sound = false
var first_startup = true
var ingame_music_start_pos = 0.0


func _ready():
	
	hide_gui()
	
	# this doesn't work when the project is exported
	#var dir = DirAccess.open("res://gui/palettes")
	#if dir:
	#	dir.list_dir_begin()
	#	var file_name = dir.get_next()
	#	while file_name != "":
	#		if file_name.match("*.png"):
	#			palette_paths.append(file_name)
	#		file_name = dir.get_next()
	
	update_palette()
	update_speed()
	update_volume()
	
	get_tree().paused = true
	
	var children = get_all_descendants(self).filter(func(child): return child is BaseButton)
	for child in children:
		child.focus_entered.connect(_on_button_focus_entered)
	
	%StartNewGameButton.pressed.connect(new_game_from_start)
	%PauseNewGameButton.pressed.connect(new_game)
	%GameOverNewGameButton.pressed.connect(new_game)
	%ResumeButton.pressed.connect(resume)
	%PauseQuitButton.pressed.connect(open_start_menu)
	%GameOverQuitButton.pressed.connect(open_start_menu)
	%StartQuitButton.pressed.connect(get_tree().quit)
	%StartSettingsButton.pressed.connect(open_settings_menu)
	%PauseSettingsButton.pressed.connect(open_settings_menu)
	
	#open_start_menu()


func _unhandled_input(event):
	if state == PLAYING and event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()
	elif event.is_action_pressed("restart"):
		new_game()
	elif state == USER_GESTURE:
		state = START
		$UserGestureSplash.hide()
		open_start_menu()


func get_all_descendants(node : Node) -> Array:
	var descendants = [node]
	for child in node.get_children():
		descendants += get_all_descendants(child)
	return descendants


func open_start_menu():
	state = START
	
	%StartMenu.visible = true
	%InGameMusicPlayer.stop()
	if first_startup:
		first_startup = false
	else:
		%SelectSoundPlayer.play()
	%StartSFXPlayer.play()
	
	%AnimatedSnake.animate()
	%StartAnimation.play("fade_in")
	
	await %StartAnimation.animation_finished
	
	%StartMusicPlayer.play()
	play_focus_sound = false
	%StartNewGameButton.grab_focus()


func open_settings_menu():
	%SelectSoundPlayer.play()
	%SettingsMenu.visible = true
	play_focus_sound = false
	%ExitSettingsButton.grab_focus()


func close_settings_menu():
	%ExitSoundPlayer.play()
	%SettingsMenu.visible = false
	play_focus_sound = false
	match state:
		START:
			%StartNewGameButton.grab_focus()
		GAME_OVER:
			%GameOverNewGameButton.grab_focus()
		PLAYING:
			%ResumeButton.grab_focus()


func new_game_from_start():
	ingame_music_start_pos = 0.0
	%SelectSoundPlayer.play()
	%StartMusicPlayer.stop()
	await new_game()


func new_game():
	var new_grid = grid_scene.instantiate()
	
	if grid_viewport.get_child_count() > 0:
		grid_viewport.get_child(0).queue_free()
	grid_viewport.add_child(new_grid)
	
	new_grid.score.connect(_on_game_score)
	new_grid.dead.connect(_on_game_dead)
	new_grid.win.connect(_on_game_win)
	
	score = 0
	score_text.text = "[left]" + str(score) + "[/left]"
	
	hide_gui()
	in_game_gui.visible = true
	await countdown()
	
	%InGameMusicPlayer.play(ingame_music_start_pos)
	get_tree().paused = false


func pause():
	%SelectSoundPlayer.play()
	get_tree().paused = true
	%PauseMenu.visible = true
	play_focus_sound = false
	%ResumeButton.grab_focus()


func resume():
	%ExitSoundPlayer.play()
	ingame_music_start_pos = %InGameMusicPlayer.get_playback_position()
	%InGameMusicPlayer.stop()
	hide_gui()
	
	await countdown()
	
	%InGameMusicPlayer.play(ingame_music_start_pos)
	get_tree().paused = false


func hide_gui():
	%StartMenu.visible = false
	%PauseMenu.visible = false
	%GameOverMenu.visible = false
	%SettingsMenu.visible = false


func update_palette():
	# had to deprecate this bc it wouldn't work when exported :pensive:
	#palette = clampi(palette, 0, palette_paths.size() - 1)
	#%PaletteNumberLabel.text = str(palette).pad_zeros(2)
	#palette_shader.set("shader_parameter/palette", load("res://gui/palettes/" + palette_paths[palette]))
	
	palette = clampi(palette, 0, palettes.size() - 1)
	%PaletteNumberLabel.text = str(palette).pad_zeros(2)
	palette_shader.set("shader_parameter/palette", palettes[palette])
	
	%PaletteDecreaseButton.disabled = (palette == 0)
	%PaletteIncreaseButton.disabled = (palette == palettes.size() - 1)


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


func update_speed():
	game_speed = clampi(game_speed, 1, 5)
	
	Engine.time_scale = float (game_speed + 1) / 4.0
	
	%SpeedNumberLabel.text = str(game_speed)
	%SpeedDecreaseButton.disabled = game_speed == 1
	%SpeedIncreaseButton.disabled = game_speed == 5


func countdown():
	state = ANIMATION
	%CountdownLabel.visible = true
	%CountdownPlayer.play()
	
	for i in range(3,0,-1):
		%CountdownLabel.text = str(i)
		await get_tree().create_timer(1.0).timeout
	
	%CountdownLabel.text = "GO"
	await get_tree().create_timer(1.0).timeout
	
	%CountdownLabel.visible = false
	state = PLAYING


func _on_button_focus_entered():
	if play_focus_sound:
		%FocusSoundPlayer.play()
	else:
		play_focus_sound = true


func _on_game_score():
	score += 1
	score_text.text = "[left]" + str(score) + "[/left]"
	if score > Global.record: 
		Global.record = score 
		record_text.text = "[right]" + str(score) + "[/right]"


func _on_game_dead():
	state = GAME_OVER
	
	ingame_music_start_pos = %InGameMusicPlayer.get_playback_position()
	%InGameMusicPlayer.stop()
	%GameOverMusicPlayer.play()
	
	%GameOverLabel.text = "[center]GAME OVER"
	%GameOverMenu.visible = true
	play_focus_sound = false
	%GameOverNewGameButton.grab_focus()
	get_tree().paused = true
	

func _on_game_win():
	state = GAME_OVER
	
	ingame_music_start_pos = %InGameMusicPlayer.get_playback_position()
	%InGameMusicPlayer.stop()
	%GameOverMusicPlayer.play()
	
	%GameOverLabel.text = "[center]HOW!?!"
	%GameOverMenu.visible = true
	play_focus_sound = false
	%GameOverNewGameButton.grab_focus()
	get_tree().paused = true


func _on_palette_decrease_button_pressed():
	%DecreaseSoundPlayer.play()
	palette -= 1
	update_palette()


func _on_palette_increase_button_pressed():
	%IncreaseSoundPlayer.play()
	palette += 1
	update_palette()


func _on_check_box_toggled(button_pressed):
	(%IncreaseSoundPlayer if button_pressed else %DecreaseSoundPlayer).play()
	palette_shader.set("shader_parameter/invert", button_pressed)


func _on_music_decrease_button_pressed():
	%DecreaseSoundPlayer.play()
	music_volume -= 1
	update_volume()


func _on_music_increase_button_pressed():
	%IncreaseSoundPlayer.play()
	music_volume += 1
	update_volume()


func _on_sfx_decrease_button_pressed():
	%DecreaseSoundPlayer.play()
	sfx_volume -= 1
	update_volume()


func _on_sfx_increase_button_pressed():
	%IncreaseSoundPlayer.play()
	sfx_volume += 1
	update_volume()


func _on_speed_decrease_button_pressed():
	%DecreaseSoundPlayer.play()
	game_speed -= 1
	update_speed()


func _on_speed_increase_button_pressed():
	%IncreaseSoundPlayer.play()
	game_speed += 1
	update_speed()

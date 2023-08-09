extends Control

@onready var pause_screen = $PauseScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_deferred("paused", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			pause_screen.visible = false
			get_tree().paused = false
		else:
			pause_screen.visible = true
			get_tree().paused = true

extends Control


func _draw():
	var vertical = PackedVector2Array()
	for i in range(Global.GRID_WIDTH):
		vertical.append(Vector2(i * Global.CELL_SIZE + 0.5, 0))
		vertical.append(Vector2(i * Global.CELL_SIZE + 0.5, Global.GRID_HEIGHT * Global.CELL_SIZE))
		vertical.append(Vector2((i+1) * Global.CELL_SIZE - 0.5, 0))
		vertical.append(Vector2((i+1) * Global.CELL_SIZE - 0.5, Global.GRID_HEIGHT * Global.CELL_SIZE))
	draw_multiline(vertical, Global.DARK, 1)

	var horizontal = PackedVector2Array()
	for i in range(Global.GRID_HEIGHT):
		horizontal.append(Vector2(0, i * Global.CELL_SIZE + 0.5))
		horizontal.append(Vector2(Global.GRID_WIDTH * Global.CELL_SIZE, i * Global.CELL_SIZE + 0.5))
		horizontal.append(Vector2(0, (i+1) * Global.CELL_SIZE - 0.5))
		horizontal.append(Vector2(Global.GRID_WIDTH * Global.CELL_SIZE, (i+1) * Global.CELL_SIZE - 0.5))
	draw_multiline(horizontal, Global.DARK, 1)

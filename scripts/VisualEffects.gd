class_name VisualEffects

var main: Node

func _init(m: Node):
	main = m

func show_floating_text(grid_pos, text, color, align = "center"):
	var lbl = Label.new()
	lbl.text = str(text)
	lbl.set("theme_override_colors/font_color", color)
	lbl.set("theme_override_colors/font_outline_color", Color.BLACK)
	lbl.set("theme_override_constants/outline_size", 6)
	lbl.set("theme_override_font_sizes/font_size", 24)
	if align == "center":
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var start_pos = grid_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0)
	lbl.position = start_pos - Vector2(20, 20)
	lbl.z_index = 100
	main.board_node.add_child(lbl)
	
	var tween = main.create_tween()
	tween.tween_property(lbl, "position", start_pos - Vector2(20, 60), 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_callback(lbl.queue_free)

func shake_board(intensity: float, duration: float):
	var tween = main.create_tween()
	for i in range(4):
		tween.tween_property(main.board_node, "position", main.BOARD_OFFSET + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), duration/5.0)
	tween.tween_property(main.board_node, "position", main.BOARD_OFFSET, duration/5.0)

func spawn_blood_puddle(pos):
	var puddle = ColorRect.new()
	puddle.size = (main.CELL_SIZE_V * 0.7)
	puddle.position = pos * main.CELL_SIZE_V + (main.CELL_SIZE_V * 0.15)
	puddle.color = Color(0.6, 0.0, 0.0, 0.7)
	puddle.z_index = -3
	main.board_node.add_child(puddle)
	main.blood_puddles.append({"node": puddle, "pos": pos})

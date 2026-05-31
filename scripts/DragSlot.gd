extends TextureRect
class_name DragSlot

var slot_type = "pool" # "pool" or "piece"
var item_id = "" # "knife", "bottle", "boots", etc.
var slot_index = -1

func _ready():
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var main_node = get_tree().get_first_node_in_group("main")
	if main_node and main_node.inventory_manager.has_method("get_item_texture"):
		texture = main_node.inventory_manager.get_item_texture(item_id)
	else:
		texture = null
		
	mouse_entered.connect(func():
		var m = get_tree().get_first_node_in_group("main")
		if m and item_id != "":
			if m.has_method("show_custom_tooltip"):
				m.show_custom_tooltip(ItemManager.get_item_description(item_id))
	)
	
	mouse_exited.connect(func():
		var m2 = get_tree().get_first_node_in_group("main")
		if m2 and m2.has_method("hide_custom_tooltip"):
			m2.hide_custom_tooltip()
	)
	
	var m3 = get_tree().get_first_node_in_group("main")
	# Lock removed so players can drag items mid-combat

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var main = get_tree().get_first_node_in_group("main")
		# Handle active items (if equipped)
		if slot_type == "piece" and item_id == "bottle" and main and main.has_method("start_bottle_targeting"):
			var p = main.player_pawns[main.current_view_index]
			main.start_bottle_targeting(p)

func _get_drag_data(at_position):
	if item_id == "": return null
	
	var main = get_tree().get_first_node_in_group("main")
	if main and main.state != main.GameState.SHOP and main.state != main.GameState.MAP and not main.inv_panel.visible: return null
	
	var c = Control.new()
	c.z_index = 4096
	var preview = Sprite2D.new()
	preview.texture = texture
	if texture:
		var t_size = texture.get_size()
		if t_size.x > 0 and t_size.y > 0:
			var scale_factor = min(80.0 / t_size.x, 80.0 / t_size.y)
			preview.scale = Vector2(scale_factor, scale_factor)
	preview.modulate = Color(1, 1, 1, 0.9)
	
	c.add_child(preview)
	set_drag_preview(c)
	
	return self

func _can_drop_data(at_position, data):
	var main = get_tree().get_first_node_in_group("main")
	if main and main.state != main.GameState.SHOP and main.state != main.GameState.MAP and not main.inv_panel.visible: return false
	return data is DragSlot and data != self

func _drop_data(_at_position, data):
	var main = get_tree().get_first_node_in_group("main")
	if main and main.inventory_manager and main.inventory_manager.has_method("on_item_dropped"):
		main.inventory_manager.on_item_dropped(data, self)

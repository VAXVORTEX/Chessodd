extends ColorRect
class_name BestiaryMenu

var main: Node
var tabs: TabContainer

var grid_pieces: GridContainer
var grid_items: GridContainer

var info_name: Label
var info_desc: Label

var item_pool = ["knife", "bottle", "boots", "dark_mirror", "hand", "blood_knife", "torch", "finger", "shark_tooth", "hoof", "brain_jar"]

func _init(_main: Node):
	main = _main
	color = Color(0.1, 0.1, 0.15, 1.0)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 2000
	hide()
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_right", 80)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	var header = Label.new()
	header.text = "Bestiary"
	header.set("theme_override_font_sizes/font_size", 60)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 30)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	# Left: Tabs for grids
	tabs = TabContainer.new()
	tabs.custom_minimum_size = Vector2(1000, 700)
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(tabs)
	
	var scroll_p = ScrollContainer.new()
	scroll_p.name = "Figures"
	tabs.add_child(scroll_p)
	
	grid_pieces = GridContainer.new()
	grid_pieces.columns = 7
	grid_pieces.add_theme_constant_override("h_separation", 20)
	grid_pieces.add_theme_constant_override("v_separation", 20)
	var gp_margin = MarginContainer.new()
	gp_margin.add_theme_constant_override("margin_top", 20)
	gp_margin.add_theme_constant_override("margin_left", 20)
	gp_margin.add_child(grid_pieces)
	scroll_p.add_child(gp_margin)
	
	var scroll_i = ScrollContainer.new()
	scroll_i.name = "Artifacts"
	tabs.add_child(scroll_i)
	
	grid_items = GridContainer.new()
	grid_items.columns = 7
	grid_items.add_theme_constant_override("h_separation", 20)
	grid_items.add_theme_constant_override("v_separation", 20)
	var gi_margin = MarginContainer.new()
	gi_margin.add_theme_constant_override("margin_top", 20)
	gi_margin.add_theme_constant_override("margin_left", 20)
	gi_margin.add_child(grid_items)
	scroll_i.add_child(gi_margin)
	
	# Right: Info panel
	var info_panel = PanelContainer.new()
	info_panel.custom_minimum_size = Vector2(450, 700)
	info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.15, 0.2)
	sb.border_width_left = 4
	sb.border_width_top = 4
	sb.border_width_right = 4
	sb.border_width_bottom = 4
	sb.border_color = Color(0.3, 0.3, 0.4)
	info_panel.add_theme_stylebox_override("panel", sb)
	hbox.add_child(info_panel)
	
	var info_margin = MarginContainer.new()
	info_margin.add_theme_constant_override("margin_top", 20)
	info_margin.add_theme_constant_override("margin_bottom", 20)
	info_margin.add_theme_constant_override("margin_left", 20)
	info_margin.add_theme_constant_override("margin_right", 20)
	info_panel.add_child(info_margin)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 20)
	info_margin.add_child(info_vbox)
	
	info_name = Label.new()
	info_name.text = "Hover over an icon"
	info_name.set("theme_override_font_sizes/font_size", 40)
	info_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(info_name)
	
	info_desc = Label.new()
	info_desc.text = ""
	info_desc.set("theme_override_font_sizes/font_size", 28)
	info_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(info_desc)
	
	var btn_close = Button.new()
	btn_close.text = "Close"
	btn_close.set("theme_override_font_sizes/font_size", 40)
	btn_close.custom_minimum_size = Vector2(200, 80)
	btn_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_close.pressed.connect(func(): hide())
	vbox.add_child(btn_close)
	
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		populate_grids()

func populate_grids():
	for c in grid_pieces.get_children():
		c.queue_free()
	for c in grid_items.get_children():
		c.queue_free()
		
	var seen_pieces = main.meta_data.get("seen_pieces", [])
	var seen_items = main.meta_data.get("seen_items", [])
	
	# Populate Pieces
	var pieces = PieceData.registry.keys()
	pieces.sort()
	for p_type in pieces:
		var data = PieceData.registry[p_type]
		var is_seen = seen_pieces.has(p_type)
		var tex = PieceData.get_piece_texture(p_type, true)
		if not tex: tex = PieceData.get_piece_texture(p_type, false)
		
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(100, 100)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = tex
		
		var wrapper = PanelContainer.new()
		var w_sb = StyleBoxFlat.new()
		w_sb.bg_color = Color(0.2, 0.2, 0.25)
		w_sb.corner_radius_top_left = 10
		w_sb.corner_radius_top_right = 10
		w_sb.corner_radius_bottom_left = 10
		w_sb.corner_radius_bottom_right = 10
		wrapper.add_theme_stylebox_override("panel", w_sb)
		wrapper.add_child(icon)
		
		if not is_seen:
			icon.self_modulate = Color(0, 0, 0, 1) # Silhouette
		
		wrapper.gui_input.connect(func(event):
			if event is InputEventMouseMotion:
				if is_seen:
					info_name.text = data.get("title", "Unknown")
					info_desc.text = data.get("desc", "")
				else:
					info_name.text = "???"
					info_desc.text = "You haven't encountered this figure yet."
		)
		grid_pieces.add_child(wrapper)
		
	# Populate Items
	for it in item_pool:
		var is_seen = seen_items.has(it)
		var tex = main.inventory_manager.get_item_texture(it)
		
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(100, 100)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = tex
		
		var wrapper = PanelContainer.new()
		var w_sb = StyleBoxFlat.new()
		w_sb.bg_color = Color(0.2, 0.2, 0.25)
		w_sb.corner_radius_top_left = 10
		w_sb.corner_radius_top_right = 10
		w_sb.corner_radius_bottom_left = 10
		w_sb.corner_radius_bottom_right = 10
		wrapper.add_theme_stylebox_override("panel", w_sb)
		wrapper.add_child(icon)
		
		if not is_seen:
			icon.self_modulate = Color(0, 0, 0, 1) # Silhouette
			
		wrapper.gui_input.connect(func(event):
			if event is InputEventMouseMotion:
				if is_seen:
					info_name.text = it.replace("_", " ").capitalize()
					info_desc.text = ItemManager.get_item_description(it)
				else:
					info_name.text = "???"
					info_desc.text = "You haven't encountered this artifact yet."
		)
		grid_items.add_child(wrapper)

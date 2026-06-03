extends Node2D
class_name Main

const CELL_SIZE_V: Vector2 = Vector2(130, 130)
@export var CELL_SPACING: Vector2 = Vector2(4, 4)
const COLS = 5
const ROWS = 8
var BOARD_OFFSET: Vector2 = Vector2(635, 60)

enum PieceType { PAWN, KNIGHT, BISHOP, KING, ROCK, POOP, ROOK, QUEEN, SPIKED_PAWN, EVIL_EYE, BOSS_DEADKING, BOSS_HEAD, BOSS_BODY, BOMB_BARREL, TELEPAWN, NIGHTMARE_PAWN, CHECKER, BLOOD_QUEEN }
enum GameState { PLAYING, SHOP, TARGETING_SACRIFICE, TARGETING_DARK_MIRROR, TARGETING_HAND, MAP, TARGETING_BLOOD_KNIFE, TARGETING_TORCH, TARGETING_FINGER, MAIN_MENU, SAVE_SELECTION }

var board = {}
var hazards = []
var blood_hazards = {}
var tex_blood_hazards = []

var info_statuses = null
var active_item_slot_ui = null
var current_turn = 0
var any_player_piece_died = false 
var player_pawns = []
var bot_pawns = []
var state = GameState.PLAYING
var level = 1
var turn_count = 1
var act = 1
var act1_color1 = Color("#3d4a5d")
var act1_color2 = Color("#5a6988")
var act2_color1 = Color("#4a2c3a")
var act2_color2 = Color("#753c4d")
var time_elapsed: float = 0.0
var coins = 0
var shop_rerolls_used = 0
var is_levelup_active = false
var game_over = false
var normal_move_used = false

var combat_manager = CombatManager.new(self)
var map_manager = preload("res://scripts/MapManager.gd").new()
var inventory_manager = preload("res://scripts/InventoryManager.gd").new(self)
var vfx_manager = preload("res://scripts/VisualEffects.gd").new(self)
var event_manager = preload("res://scripts/EventManager.gd").new(self)
var shop_manager = preload("res://scripts/ShopManager.gd").new(self)
var map_king = null
var map_scroll_tween: Tween = null

var tex_pawn_player: Texture2D
var tex_pawn_bot: Texture2D
var tex_knight_player: Texture2D
var tex_knight_bot: Texture2D
var tex_bishop_player: Texture2D
var tex_bishop_bot: Texture2D
var tex_king_player: Texture2D
var tex_king_bot: Texture2D
var tex_rook_player: Texture2D
var tex_rook_bot: Texture2D
var tex_queen_player: Texture2D
var tex_queen_bot: Texture2D
var tex_spiked_pawn: Texture2D

var tex_rock: Texture2D
var tex_poop: Texture2D
var tex_bomb_barrel: Texture2D
var tex_bomb_barrel_burst: Texture2D
var tex_telepawn: Texture2D
var tex_shop_bg: Texture2D
var tex_sword: Texture2D
var tex_knife: Texture2D
var tex_heart: Texture2D
var tex_bottle: Texture2D
var tex_boots: Texture2D
var tex_dark_mirror: Texture2D
var tex_hand: Texture2D
var tex_blood_knife: Texture2D
var tex_torch: Texture2D
var tex_finger: Texture2D
var tex_shark_tooth: Texture2D
var tex_hoof: Texture2D
var tex_brain_jar: Texture2D
var tex_desk1: Texture2D
var tex_desk2: Texture2D
var tex_forest_bg: Texture2D
var mirror_used_this_level = false
var clone_active = false
var active_clone_piece = null
var force_clone_move = false

var tex_deadking: Texture2D
var tex_deadking_head: Texture2D
var tex_deadking_body: Texture2D

var tex_blood: Texture2D
var blood_puddles = []

var ui_layer: CanvasLayer
var status_label: Label
var coins_label: Label
var timer_label: Label
var room_label: Label
var shop_panel: ColorRect
var shop_items_container: HBoxContainer

var board_node: Node2D
var overlay: Node2D
var selected_piece = null
var hovered_grid_pos = Vector2(-1, -1)
var bottle_user_piece = null
var info_panel: PanelContainer
var info_name: Label
var info_stats: Label
var info_desc: Label
var info_tex: TextureRect
var settings_panel: ColorRect
var cancel_btn: Button
var graveyard_panel: PanelContainer
var graveyard_container: Container
var lbl_settings_title: Label
var lbl_graveyard_title: Label
var graveyard = []
var enemy_graveyard = []
var enemy_graveyard_container: Container
var main_menu_panel: ColorRect
var save_slots_panel: ColorRect
var save_slots_container: VBoxContainer
var current_save_slot = 0
var info_item_slots: HBoxContainer
var game_over_label: Label
var right_click_target = null

var unassigned_items = ["knife"]
var current_view_index = 0
var inv_panel: ColorRect
var inv_piece_tex: TextureRect
var inv_piece_name: Label
var inv_piece_desc: Label
var inv_piece_stats: Label
var inv_piece_slots: HBoxContainer
var inv_pool_grid: GridContainer

var inv_coins_lbl: Label
var inv_pieces_list: GridContainer
var inv_start_btn: Button

var item_tooltip: PanelContainer
var item_tooltip_lbl: Label
var world_env: WorldEnvironment
var canvas_modulate: CanvasModulate
var clouds_rect: TextureRect
var bg_location: TextureRect
var pause_panel: ColorRect

var selected_item_data = null
var game_over_panel: ColorRect
var inv_level_lbl: Label
var inv_time_lbl: Label

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game_state()
		get_tree().quit()


func _setup_visuals():
	var game_bg = TextureRect.new()
	game_bg.texture = load("res://images/forest_bg.png")
	game_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	game_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_bg.z_index = -100
	game_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(game_bg)
	
	world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.adjustment_enabled = true
	world_env.environment = env
	add_child(world_env)
	

	
	clouds_rect = TextureRect.new()
	clouds_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clouds_rect.size = Vector2(2560, 1440)
	clouds_rect.position = Vector2(-200, -200)
	clouds_rect.z_index = 50 # Above board, below UI
	if ResourceLoader.exists("res://images/clouds.png"):
		clouds_rect.texture = load("res://images/clouds.png")
	add_child(clouds_rect)
	
	var light_rect = TextureRect.new()
	light_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	light_rect.size = Vector2(2560, 1440)
	light_rect.position = Vector2(-200, -200)
	light_rect.z_index = 45 # Below clouds
	if ResourceLoader.exists("res://images/light.png"):
		light_rect.texture = load("res://images/light.png")
	add_child(light_rect)
	
	apply_visual_settings()

func apply_visual_settings():
	var st = SaveManager.load_settings()
	if world_env and world_env.environment:
		world_env.environment.adjustment_brightness = st.get("gamma", 100.0) / 100.0
		world_env.environment.adjustment_contrast = st.get("contrast", 100.0) / 100.0
		world_env.environment.adjustment_saturation = st.get("saturation", 100.0) / 100.0
	
	if clouds_rect:
		clouds_rect.visible = st.get("clouds", true)
	
	# Shadows are applied when spawning pieces, so we just toggle their visibility
	var show_shadows = st.get("shadows", true)
	for p in player_pawns + bot_pawns:
		if is_instance_valid(p) and p.has_node("DropShadow"):
			p.get_node("DropShadow").visible = show_shadows

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	add_to_group("main")
	tex_pawn_player = load("res://images/pawn.png")
	tex_pawn_bot = load("res://images/pawn.png")
	tex_knight_player = load("res://images/knight_player.svg")
	tex_knight_bot = load("res://images/knight_bot.svg")
	tex_bishop_player = load("res://images/bishop_player.svg")
	tex_bishop_bot = load("res://images/bishop_bot.svg")
	tex_king_player = load("res://images/king_player.svg")
	tex_king_bot = load("res://images/king_bot.svg")
	tex_rook_player = load("res://images/rook_player.svg")
	tex_rook_bot = load("res://images/rook_bot.svg")
	tex_queen_player = load("res://images/queen_player.svg")
	tex_queen_bot = load("res://images/queen_bot.svg")
	
	tex_spiked_pawn = load("res://images/spiked_pawn.svg")

	
	tex_rock = load("res://images/rock.svg")
	tex_poop = load("res://images/poop.svg")
	
	tex_bomb_barrel = load("res://images/bomb_barrel.png")
	if not tex_bomb_barrel:
		var img = Image.load_from_file("res://images/bomb_barrel.png")
		if img: tex_bomb_barrel = ImageTexture.create_from_image(img)
		
	tex_bomb_barrel_burst = load("res://images/bomb_barrel_burst.png")
	if not tex_bomb_barrel_burst:
		var img = Image.load_from_file("res://images/bomb_barrel_burst.png")
		if img: tex_bomb_barrel_burst = ImageTexture.create_from_image(img)
		
	tex_telepawn = load("res://images/Telepawn.png")
	if not tex_telepawn:
		var img = Image.load_from_file("res://images/Telepawn.png")
		if img: tex_telepawn = ImageTexture.create_from_image(img)
	tex_shop_bg = null
	tex_sword = load("res://images/sword.svg")
	tex_knife = load("res://images/knife.svg")
	tex_heart = load("res://images/heart.svg")
	tex_bottle = load("res://images/bottle.svg")
	tex_boots = load("res://images/boots.svg")
	tex_dark_mirror = load("res://images/blackmirror.png")
	if not tex_dark_mirror:
		var img = Image.load_from_file("res://images/blackmirror.png")
		if img: tex_dark_mirror = ImageTexture.create_from_image(img)
	tex_hand = load("res://images/hand.svg")
	tex_blood_knife = load("res://images/blood_knife.png") if ResourceLoader.exists("res://images/blood_knife.png") else load("res://images/sword.svg")
	tex_torch = load("res://images/torch.svg")
	
	tex_finger = load("res://images/finger.png")
	tex_shark_tooth = load("res://images/shark_tooth.png")
	tex_hoof = load("res://images/hoof.png")
	tex_brain_jar = load("res://images/brain_in_a_bar.png")
	tex_blood_hazards.append(load("res://images/blood1.png"))
	tex_blood_hazards.append(load("res://images/blood2.png"))
	tex_blood_hazards.append(load("res://images/blood3.png"))

	tex_deadking = load("res://images/deadking.png")
	tex_deadking_head = load("res://images/deadking_head.png")
	tex_deadking_body = load("res://images/deadking_body.png")
	tex_blood = null
	tex_forest_bg = load("res://images/forest_bg.png")
	if not tex_forest_bg:
		var img = Image.load_from_file("res://images/forest_bg.png")
		if img: tex_forest_bg = ImageTexture.create_from_image(img)
	
	bg_location = TextureRect.new()
	bg_location.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_location.size = Vector2(1920, 1080)
	bg_location.position = Vector2.ZERO
	bg_location.z_index = -20
	bg_location.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if tex_forest_bg:
		bg_location.texture = tex_forest_bg
	add_child(bg_location)
	
	board_node = Node2D.new()
	board_node.position = BOARD_OFFSET
	add_child(board_node)
	

	redraw_board_grid()
			
	overlay = Node2D.new()
	# overlay inherits board_node's scale and position
	overlay.z_index = 10
	overlay.draw.connect(_on_overlay_draw)
	board_node.add_child(overlay)
			
	add_to_group("main")
	_setup_visuals()
	UIBuilder.create_ui(self)
	create_grid_labels()
	
	# Random spawns removed to respect starter layout
	
	var settings = SaveManager.load_settings()
	TranslationManager.set_locale(settings.language)
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if settings.get("fullscreen", false) else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	if mode == DisplayServer.WINDOW_MODE_WINDOWED:
		var res_idx = settings.get("resolution", 0)
		var sizes = [Vector2i(1920, 1080), Vector2i(1600, 900), Vector2i(1280, 720), Vector2i(1024, 576)]
		if res_idx >= 0 and res_idx < sizes.size():
			DisplayServer.window_set_size(sizes[res_idx])
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_position(screen_size / 2 - sizes[res_idx] / 2)
	update_ui_translation()
	open_main_menu()


func open_main_menu():
	state = GameState.MAIN_MENU
	main_menu_panel.show()
	save_slots_panel.hide()
	info_panel.hide()
	inv_panel.hide()
	shop_panel.hide()
	graveyard_panel.hide()
	board_node.hide()
	for lbl in get_tree().get_nodes_in_group("grid_labels"): lbl.hide()

func open_save_slots():
	state = GameState.SAVE_SELECTION
	main_menu_panel.hide()
	save_slots_panel.show()
	for child in save_slots_container.get_children():
		save_slots_container.remove_child(child)
		child.queue_free()
	
	for i in range(3):
		var slot_data = SaveManager.load_game(i)
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 20)
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(400, 80)
		if slot_data.is_empty():
			btn.text = "Slot " + str(i + 1) + " - Empty"
			btn.pressed.connect(func(): start_new_run(i))
		else:
			var lvl = slot_data.get("level", 1)
			btn.text = "Slot " + str(i + 1) + " - Floor " + str(lvl)
			btn.pressed.connect(func(): load_run(i, slot_data))
		hbox.add_child(btn)
		
		if not slot_data.is_empty():
			var del_btn = Button.new()
			del_btn.text = "Delete"
			del_btn.set("theme_override_colors/font_color", Color.RED)
			del_btn.custom_minimum_size = Vector2(100, 80)
			del_btn.pressed.connect(func(): SaveManager.delete_game(i); open_save_slots())
			hbox.add_child(del_btn)
			
		save_slots_container.add_child(hbox)

func start_new_run(slot: int):
	game_over = false
	any_player_piece_died = false
	act = 1
	level = 1
	current_turn = 0
	turn_count = 1
	normal_move_used = false
	mirror_used_this_level = false
	clone_active = false
	active_clone_piece = null
	force_clone_move = false
	coins = 5
	time_elapsed = 0.0
	if is_instance_valid(game_over_panel): game_over_panel.hide()
	current_save_slot = slot
	main_menu_panel.hide()
	save_slots_panel.hide()
	board_node.show()
	graveyard_panel.show()
	
	blood_hazards.clear()
	graveyard.clear()
	enemy_graveyard.clear()
	unassigned_items.clear()
	player_pawns.clear()
	bot_pawns.clear()
	board.clear()
	for child in board_node.get_children():
		if child != overlay and child != map_king and child is Sprite2D:
			child.queue_free()
	for bp in blood_puddles:
		if is_instance_valid(bp["node"]): bp["node"].queue_free()
	blood_puddles.clear()
	
	map_manager.generate_map()
	update_ui()
	EnemySpawner.spawn_piece(self, 2, ROWS - 1, true, PieceType.KING)
	
	start_map_mode()
	save_game_state()

func load_run(slot: int, data: Dictionary):
	game_over = false
	if is_instance_valid(game_over_panel): game_over_panel.hide()
	current_save_slot = slot
	main_menu_panel.hide()
	save_slots_panel.hide()
	board_node.show()
	graveyard_panel.show()
	coins = data.get("coins", 5)
	any_player_piece_died = data.get("any_player_piece_died", false)
	level = data.get("level", 1)
	act = data.get("act", 1)
	time_elapsed = data.get("time_elapsed", 0.0)
	turn_count = data.get("turn_count", 1)
	unassigned_items = data.get("unassigned_items", [])
	
	# Load map
	map_manager.current_node_id = data.get("current_node_id", -1)
	map_manager.map_data = data.get("map_data", [])
	map_manager.current_floor = -1
	if map_manager.current_node_id != -1:
		var curr_node = map_manager.get_node_by_id(map_manager.current_node_id)
		if curr_node:
			map_manager.current_floor = curr_node.floor
	
	player_pawns.clear()
	bot_pawns.clear()
	board.clear()
	for child in board_node.get_children():
		if child != overlay and child != map_king and child is Sprite2D:
			child.queue_free()
			
	var p_data = data.get("player_pawns", [])
	if level == 1 and act == 1 and turn_count == 1:
		p_data = [] # Ignore corrupted saves for new runs
		#EnemySpawner.spawn_piece(self, 0, ROWS - 1, true, PieceType.KNIGHT)
		#EnemySpawner.spawn_piece(self, 1, ROWS - 1, true, PieceType.BISHOP)
		EnemySpawner.spawn_piece(self, 2, ROWS - 1, true, PieceType.KING)
		#EnemySpawner.spawn_piece(self, 3, ROWS - 1, true, PieceType.QUEEN)
		#EnemySpawner.spawn_piece(self, 4, ROWS - 1, true, PieceType.ROOK)
		#for i in range(COLS):
		#	EnemySpawner.spawn_piece(self, i, ROWS - 2, true, PieceType.PAWN)
			
	for p in p_data:
		var pos = Vector2(p.x, p.y)
		var piece = EnemySpawner.spawn_piece(self, pos.x, pos.y, true, p.type)
		piece.current_hp = p.hp
		piece.max_hp = p.max_hp
		piece.attack_damage = p.atk
		piece.artifacts = p.artifacts
		if p.has("lvl"): piece.level = p.lvl
		if p.has("meta"):
			for k in p.meta.keys():
				var val = p.meta[k]
				if typeof(val) == TYPE_STRING and val.begins_with("(") and val.ends_with(")"):
					var vec_str = val.replace("(", "").replace(")", "").split(",")
					if vec_str.size() == 2:
						val = Vector2(float(vec_str[0]), float(vec_str[1]))
				piece.set_meta(k, val)
	
	var b_data = data.get("bot_pawns", [])
	for b in b_data:
		var pos = Vector2(b.x, b.y)
		var piece = EnemySpawner.spawn_piece(self, pos.x, pos.y, false, b.type)
		piece.current_hp = b.hp
		piece.max_hp = b.max_hp
		piece.attack_damage = b.atk
		piece.artifacts = b.artifacts
		if b.has("lvl"): piece.level = b.lvl
		if b.has("meta"):
			for k in b.meta.keys():
				var val = b.meta[k]
				if typeof(val) == TYPE_STRING and val.begins_with("(") and val.ends_with(")"):
					var vec_str = val.replace("(", "").replace(")", "").split(",")
					if vec_str.size() == 2:
						val = Vector2(float(vec_str[0]), float(vec_str[1]))
				piece.set_meta(k, val)
		
	graveyard = data.get("graveyard", [])
	enemy_graveyard = data.get("enemy_graveyard", [])
	update_graveyard_ui()
	
	var saved_state = data.get("state", GameState.MAP)
	state = saved_state
	
	if saved_state == GameState.MAP:
		start_map_mode()
	elif saved_state == GameState.SHOP:
		shop_rerolls_used = 0
		generate_shop()
		shop_panel.show()
		info_panel.hide()
		inv_panel.hide()
		clear_map_stuff()
		if is_instance_valid(map_king): map_king.hide()
		update_ui()
	else:
		state = GameState.PLAYING
		redraw_board_grid()
		update_ui()
		board_node.show()
		shop_panel.hide()
		clear_map_stuff()
		if is_instance_valid(map_king): map_king.hide()
		for lbl in get_tree().get_nodes_in_group("grid_labels"): lbl.show()
		update_ui()

func save_game_state():
	var p_data = []
	for p in player_pawns:
		if is_instance_valid(p):
			var m = {}; for k in p.get_meta_list(): m[k] = p.get_meta(k)
			p_data.append({"x": p.grid_pos.x, "y": p.grid_pos.y, "type": p.piece_type, "hp": p.current_hp, "max_hp": p.max_hp, "atk": p.attack_damage, "artifacts": p.artifacts, "lvl": p.level, "meta": m})
	var b_data = []
	for b in bot_pawns:
		if is_instance_valid(b):
			var m = {}; for k in b.get_meta_list(): m[k] = b.get_meta(k)
			b_data.append({"x": b.grid_pos.x, "y": b.grid_pos.y, "type": b.piece_type, "hp": b.current_hp, "max_hp": b.max_hp, "atk": b.attack_damage, "artifacts": b.artifacts, "lvl": b.level, "meta": m})
	
	var data = {
		"state": state,
		"coins": coins,
		"level": level,
		"act": act,
		"time_elapsed": time_elapsed,
		"turn_count": turn_count,
		"unassigned_items": unassigned_items,
		"any_player_piece_died": any_player_piece_died,
		"player_pawns": p_data,
		"graveyard": graveyard,
		"enemy_graveyard": enemy_graveyard,
		"bot_pawns": b_data,
		"current_node_id": map_manager.current_node_id,
		"map_data": map_manager.map_data
	}
	SaveManager.save_game(current_save_slot, data)

func _process(delta):
	if get_tree().paused: return
	
	if item_tooltip and item_tooltip.visible:
		var mp = get_viewport().get_mouse_position()
		item_tooltip.position = mp + Vector2(20, 20)
		
	if state == GameState.SHOP or game_over or inv_panel.visible: return
	
	if state == GameState.PLAYING and not pause_panel.visible:
		time_elapsed += delta
		var m = int(floor(time_elapsed / 60.0))
		var s = int(fmod(time_elapsed, 60.0))
		timer_label.text = "Time: %02d:%02d" % [m, s]
		
		# Removed day/night cycle per user request
		
	var mpos = board_node.get_local_mouse_position()
	
	var step_x = CELL_SIZE_V.x
	var step_y = CELL_SIZE_V.y
	
	var col = floor(mpos.x / step_x)
	var row = floor(mpos.y / step_y)
	
	var new_hovered = Vector2(-1, -1)
	
	if col >= 0 and col < COLS and row >= 0 and row < ROWS:
		new_hovered = Vector2(col, row)
		
	if hovered_grid_pos != new_hovered:
		hovered_grid_pos = new_hovered
		overlay.queue_redraw()
		
func toggle_pause_menu():
	if pause_panel.visible:
		pause_panel.hide()
		get_tree().paused = false
	else:
		pause_panel.show()
		get_tree().paused = true

func update_ui_translation():
	for node in get_tree().get_nodes_in_group("translateable"):
		if node is Button or node is Label:
			if node.name == "PlayButton" or node.text.to_lower() == "play" or node.text == "Играть" or node.text == "Грати":
				node.text = TranslationManager.translate("play")
			elif node.name == "SettingsButton" or node.text.to_lower() == "settings" or node.text == "Настройки" or node.text == "Налаштування":
				node.text = TranslationManager.translate("settings")
			elif node.name == "QuitButton" or node.text.to_lower() == "quit" or node.text == "Выйти" or node.text == "Вийти":
				node.text = TranslationManager.translate("quit")

	if is_instance_valid(lbl_settings_title):
		lbl_settings_title.text = TranslationManager.translate("settings")
		
	if is_instance_valid(settings_panel) and settings_panel is SettingsMenu:
		settings_panel.tabs.set_tab_title(0, TranslationManager.translate("audio"))
		settings_panel.tabs.set_tab_title(1, TranslationManager.translate("display"))
		settings_panel.tabs.set_tab_title(2, TranslationManager.translate("game"))

	if is_instance_valid(inv_panel):
		var title = inv_panel.get_child(0).get_child(0)
		title.text = TranslationManager.translate("inventory")

	if is_instance_valid(pause_panel):
		var p_vbox = pause_panel.get_child(0).get_child(0)
		if p_vbox.get_child_count() > 5:
			p_vbox.get_child(3).text = TranslationManager.translate("settings")
			p_vbox.get_child(4).text = TranslationManager.translate("main_menu")
			p_vbox.get_child(5).text = TranslationManager.translate("quit")

	if state == GameState.MAP:
		start_map_mode()
	elif state != GameState.MAIN_MENU and state != GameState.SAVE_SELECTION:
		status_label.text = TranslationManager.translate("player_turn", [turn_count])
	update_ui()
	update_graveyard_ui()



func get_dead_piece_tooltip(dead: Dictionary) -> String:
	var s = "[color=yellow]" + str(dead.name) + "[/color]\n"
	s += "[color=red]0 HP (Dead)[/color]\n"
	if dead.has("artifacts") and dead.artifacts.size() > 0:
		s += "\n[color=aqua]Items:[/color]\n"
		for a_id in dead.artifacts:
			s += "- " + ItemManager.get_item_name(a_id) + "\n"
	return s

func populate_gy_container(container: Control, list: Array):
	for child in container.get_children():
		child.queue_free()
	for dead in list:
		var tex_rect = TextureRect.new()
		if dead.has("type"):
			tex_rect.texture = PieceData.get_piece_texture(dead.type, dead.is_player)
		elif typeof(dead.tex) == TYPE_STRING and dead.tex != "" and not dead.tex.begins_with("<"):
			if ResourceLoader.exists(dead.tex):
				tex_rect.texture = load(dead.tex)
		elif typeof(dead.tex) == TYPE_OBJECT:
			tex_rect.texture = dead.tex
		if tex_rect.texture == null:
			tex_rect.texture = preload("res://images/pawn.png")
		tex_rect.custom_minimum_size = Vector2(110, 110)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		
		tex_rect.pivot_offset = Vector2(55, 55)
		var base_color = Color.WHITE
		if dead.has("is_player") and not dead.is_player and dead.has("type") and dead.type != PieceType.POOP and dead.type != PieceType.ROCK and dead.type != PieceType.BOMB_BARREL:
			base_color = Color(1.0, 0.4, 0.4)
		tex_rect.modulate = base_color
		
		tex_rect.mouse_entered.connect(func():
			tex_rect.modulate = Color(base_color.r * 1.2, base_color.g * 1.2, base_color.b * 1.2, 1.0)
			tex_rect.z_index = 10
			var tween = create_tween()
			tween.tween_property(tex_rect, "scale", Vector2(1.15, 1.15), 0.1)
		)
		tex_rect.mouse_exited.connect(func():
			tex_rect.modulate = base_color
			tex_rect.z_index = 0
			var tween = create_tween()
			tween.tween_property(tex_rect, "scale", Vector2(1.0, 1.0), 0.1)
		)
		tex_rect.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				show_dead_piece_info(dead)
		)
		container.add_child(tex_rect)

func update_graveyard_ui():
	if graveyard_container:
		populate_gy_container(graveyard_container, graveyard)
	if enemy_graveyard_container:
		populate_gy_container(enemy_graveyard_container, enemy_graveyard)
	if graveyard_panel:
		graveyard_panel.visible = (state != GameState.MAP and state != GameState.MAIN_MENU)

func update_ui():
	coins_label.text = "Coins: %d" % coins
	room_label.text = "Room: %d" % level

func start_bottle_targeting(p, slot_ui = null):
	inv_panel.hide()
	state = GameState.TARGETING_SACRIFICE
	bottle_user_piece = p
	active_item_slot_ui = slot_ui
	if active_item_slot_ui:
		active_item_slot_ui.modulate = Color(0.2, 1.0, 0.2)
	if cancel_btn: cancel_btn.show()
	status_label.text = "Select allied piece to sacrifice..."
	status_label.set("theme_override_colors/font_color", Color.RED)

func cancel_active_item():
	if active_item_slot_ui:
		active_item_slot_ui.modulate = Color.WHITE
		active_item_slot_ui = null
	if cancel_btn: cancel_btn.hide()
	state = GameState.PLAYING
	status_label.text = TranslationManager.translate("player_turn", [turn_count])
	status_label.set("theme_override_colors/font_color", Color.WHITE)
	overlay.queue_redraw()

func update_piece_slots(piece):
	var box = piece.get_node_or_null("SlotsBox")
	if box:
		box.queue_free()



const MAP_COLS = 5
const MAP_ROWS = 14

func redraw_board_grid():
	var to_del = []
	for c in board_node.get_children():
		if c is ColorRect and c.z_index == -6: to_del.append(c)
		elif c is TextureRect and c.z_index == -6: to_del.append(c)
		elif c is ReferenceRect and c.z_index == -5: to_del.append(c)
		elif c is Sprite2D and c.z_index == -4: to_del.append(c)
		elif c is Label and c.z_index == -3: to_del.append(c)
	for c in to_del: c.queue_free()
	var c_cols = MAP_COLS if state == GameState.MAP else COLS
	var c_rows = MAP_ROWS if state == GameState.MAP else ROWS
	
	for x in range(c_cols):
		for y in range(c_rows):
			var rect = ColorRect.new()
			if act == 2:
				rect.color = Color("#4b4d54") if (x + y) % 2 == 0 else Color("#6d707a")
			else:
				rect.color = Color("#507a46") if (x + y) % 2 == 0 else Color("#72a865")
			rect.size = CELL_SIZE_V
			rect.position = Vector2(x, y) * CELL_SIZE_V
			rect.z_index = -6
			board_node.add_child(rect)
			var border = ReferenceRect.new()
			border.size = CELL_SIZE_V
			border.position = Vector2(x, y) * CELL_SIZE_V
			border.border_color = Color("#222831")
			border.border_width = 3
			border.editor_only = false
			border.z_index = -5
			board_node.add_child(border)
			
			var rng = RandomNumberGenerator.new()
			rng.seed = level * 1000 + x * 100 + y + act * 10000
			if rng.randf() < 0.25:
				if state == GameState.PLAYING and board.has(Vector2(x, y)) and board[Vector2(x, y)].has_meta("is_obstacle"):
					continue
				var deco = Sprite2D.new()
				var d_type = rng.randi() % 3
				var t_path = "res://images/forest_grass.png"
				if d_type == 1: t_path = "res://images/forest_leaf.png"
				elif d_type == 2: t_path = "res://images/forest_grasswithflower.png"
				if ResourceLoader.exists(t_path):
					deco.texture = load(t_path)
					if deco.texture:
						deco.position = Vector2(x, y) * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
						var dx = [-0.3, 0.0, 0.3][rng.randi() % 3]
						var dy = [-0.3, 0.0, 0.3][rng.randi() % 3]
						deco.position += Vector2(dx * CELL_SIZE_V.x, dy * CELL_SIZE_V.y)
						if d_type == 1:
							deco.rotation_degrees = rng.randf_range(-180, 180)
						else:
							deco.rotation_degrees = 0
						deco.z_index = -4
						var ts = deco.texture.get_size()
						if ts.x > 0:
							var sf = min((CELL_SIZE_V.x * 0.84) / ts.x, (CELL_SIZE_V.y * 0.84) / ts.y)
							deco.scale = Vector2(sf, sf)
							# Clamp to board bounds
							var hw = ts.x * sf / 2.0
							var hh = ts.y * sf / 2.0
							var bw = c_cols * CELL_SIZE_V.x
							var bh = c_rows * CELL_SIZE_V.y
							deco.position.x = clamp(deco.position.x, hw, bw - hw)
							deco.position.y = clamp(deco.position.y, hh, bh - hh)
						board_node.add_child(deco)
	if state == GameState.MAP:
		update_map_scroll()
	else:
		if map_scroll_tween and map_scroll_tween.is_running():
			map_scroll_tween.kill()
		board_node.scale = Vector2(1, 1)
		board_node.position = BOARD_OFFSET

func is_inside(pos):
	if state == GameState.MAP:
		return pos.x >= 0 and pos.x < MAP_COLS and pos.y >= 0 and pos.y < MAP_ROWS
	return pos.x >= 0 and pos.x < COLS and pos.y >= 0 and pos.y < ROWS

func can_move_or_attack(pos, is_player):
	if not board.has(pos): return true
	var p = board[pos]
	if p.piece_type == PieceType.CHECKER and p.is_player == is_player: return true
	if p.has_meta("is_obstacle"): return p.piece_type == PieceType.POOP or p.piece_type == PieceType.BOMB_BARREL
	return p.is_player != is_player

func get_valid_moves(pawn):
	var type = pawn.piece_type
	var is_hoof = pawn.artifacts.has("hoof")
	var is_knight = type == PieceType.KNIGHT
	if is_hoof and not is_knight: type = PieceType.KNIGHT
	if not PieceData.registry.has(type): return []
	var func_call = PieceData.registry[type].get("movement_func")
	if func_call == null: return []
	var range_bonus = 1 if pawn.artifacts.has("boots") else 0
	if pawn.has_meta("stacked_checker_count") and pawn.get_meta("stacked_checker_count") > 0: range_bonus += 1
	if is_hoof and is_knight: range_bonus += 1
	return func_call.call(self, pawn, range_bonus)


func spawn_random_piece(is_player, type):
	var p = Entity.new()
	p.piece_type = type
	p.is_player = is_player
	
	var data = PieceData.registry.get(type, PieceData.registry[PieceType.PAWN])
	p.texture = PieceData.get_piece_texture(type, is_player)
	
	var ts = Vector2(1,1)
	if p.texture: ts = p.texture.get_size()
	if ts.x == 0: ts = Vector2(1,1)
	var sf = min(CELL_SIZE_V.x * 0.8 / ts.x, CELL_SIZE_V.y * 0.8 / ts.y)
	if type == PieceType.CHECKER: sf *= 0.6
	elif type == PieceType.NIGHTMARE_PAWN: sf *= 0.8
	p.scale = Vector2(sf, sf)
	p.z_index = 0
	
	p.max_hp = data.get("hp", 1)
	p.current_hp = p.max_hp
	p.attack_damage = data.get("atk", 1)
	
	if data.get("is_boss", false): p.set_meta("is_boss", true)
	if data.get("is_obstacle", false): p.set_meta("is_obstacle", true)
	
	var rows = [5, 6, 7] if is_player else [0, 1, 2]
	var pos = Vector2(randi() % COLS, rows[randi() % rows.size()])
	while board.has(pos) or is_hazard_cell(pos):
		pos = Vector2(randi() % COLS, rows[randi() % rows.size()])
		
	p.grid_pos = pos
	board[pos] = p
	p.position = pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
	
	if is_player: player_pawns.append(p)
	else: bot_pawns.append(p)
	board_node.add_child(p)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if state in [GameState.TARGETING_SACRIFICE, GameState.TARGETING_DARK_MIRROR, GameState.TARGETING_HAND, GameState.TARGETING_BLOOD_KNIFE, GameState.TARGETING_TORCH, GameState.TARGETING_FINGER]:
			cancel_active_item()
			get_viewport().set_input_as_handled()
			return
		toggle_pause_menu()
		get_viewport().set_input_as_handled()
		return
		
	if get_tree().paused: return
	if inv_panel.visible: return
	
	if state == GameState.MAP:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mpos = board_node.get_local_mouse_position()
			var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
			if is_inside(g_pos):
				var nmap = _get_node_pos_map()
				for c in board_node.get_children():
					if c is Sprite2D and c.has_meta("map_node"):
						var n = c.get_meta("map_node")
						if nmap.get(n.id, Vector2(-1,-1)) == g_pos:
							trigger_map_node(n)
							return
		return
	
	if state == GameState.TARGETING_SACRIFICE:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_active_item()
				return
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mpos = board_node.get_local_mouse_position()
				var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
				if is_inside(g_pos) and board.has(g_pos) and board[g_pos].is_player and bottle_user_piece:
					var t = board[g_pos]
					if t == bottle_user_piece:
						cancel_active_item()
						return
					bottle_user_piece.current_hp += 2
					bottle_user_piece.attack_damage += 1
					vfx_manager.show_floating_text(bottle_user_piece.grid_pos, "DRANK ALLY!", Color.GREEN)
					take_damage(t, 9999)
					bottle_user_piece.bottle_used_this_level = true
					var idx = bottle_user_piece.artifacts.find("bottle")
					if idx != -1:
						bottle_user_piece.artifacts[idx] = ""
					update_info_panel(bottle_user_piece.grid_pos)
					cancel_active_item()
					inventory_manager.update_inventory_screen()
				else:
					cancel_active_item()
			return
			
	elif state == GameState.TARGETING_DARK_MIRROR:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_active_item()
				return
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mpos = board_node.get_local_mouse_position()
				var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
				if selected_piece and is_inside(g_pos) and not board.has(g_pos) and (g_pos - selected_piece.grid_pos).length() < 2:
					spawn_clone_piece(selected_piece, g_pos)
					
					mirror_used_this_level = true
					inventory_manager.recalc_pawn_stats(selected_piece)
					update_piece_slots(selected_piece)
					update_info_panel(selected_piece.grid_pos)
					
					if cancel_btn: cancel_btn.hide()
					state = GameState.PLAYING
				if not normal_move_used:
					status_label.text = TranslationManager.translate("player_turn", [turn_count])
					status_label.set("theme_override_colors/font_color", Color.WHITE)
				else:
					status_label.text = "Move the Clone!"
					status_label.set("theme_override_colors/font_color", Color.CYAN)
				
				if active_item_slot_ui:
					active_item_slot_ui.modulate = Color.WHITE
					active_item_slot_ui = null
				overlay.queue_redraw()
			else:
				cancel_active_item()
			return
			
	elif state == GameState.TARGETING_FINGER:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_active_item()
				return
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mpos = board_node.get_local_mouse_position()
				var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
				if is_inside(g_pos) and board.has(g_pos) and is_instance_valid(board[g_pos]) and board[g_pos].current_hp > 0:
					var target = board[g_pos]
					if not target.is_player and not target.has_meta("is_obstacle"):
						target.is_player = true
						var moves = get_valid_moves(target)
						target.is_player = false
						var valid_targets = []
						for m in moves:
							if board.has(m) and not board[m].is_player and not board[m].has_meta("is_obstacle"): valid_targets.append(m)
						if valid_targets.size() > 0:
							var t = valid_targets[randi() % valid_targets.size()]
							vfx_manager.show_floating_text(g_pos, TranslationManager.translate("controlled"), Color.MAGENTA)
							selected_piece.set_meta("finger_used_this_turn", true)
							update_piece_slots(selected_piece)
							perform_action(target, t)
						else:
							vfx_manager.show_floating_text(g_pos, TranslationManager.translate("no_targets"), Color.GRAY)
					cancel_active_item()
			return
	elif state == GameState.TARGETING_HAND:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_active_item()
				return
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mpos = board_node.get_local_mouse_position()
				var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
				if selected_piece and is_inside(g_pos) and board.has(g_pos) and is_instance_valid(board[g_pos]) and board[g_pos].current_hp > 0:
					var target = board[g_pos]
					var diff = g_pos - selected_piece.grid_pos
					var dist = abs(diff.x) + abs(diff.y)
					var is_orthogonal = diff.x == 0 or diff.y == 0
					if not target.is_player and target.piece_type != PieceType.ROCK and is_orthogonal and dist <= 2:
						var push_dir = diff.normalized()
						var push_pos = g_pos + push_dir
						
						selected_piece.set_meta("hand_used_this_turn", true)
						inventory_manager.recalc_pawn_stats(selected_piece)
						update_piece_slots(selected_piece)
						
						var blocked = not is_inside(push_pos) or board.has(push_pos)
						
						if blocked:
							vfx_manager.show_floating_text(g_pos, "COLLISION!", Color.RED)
							take_damage(target, 2, selected_piece)
							if is_inside(push_pos) and board.has(push_pos):
								var standing = board[push_pos]
								take_damage(standing, 1, selected_piece)
							if selected_piece: update_info_panel(selected_piece.grid_pos)
							
							var bump_px = (g_pos * CELL_SIZE_V + push_pos * CELL_SIZE_V) / 2.0 + (CELL_SIZE_V / 2.0)
							var orig_px = g_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
							var tween = create_tween()
							tween.tween_property(target, "position", bump_px, 0.1)
							tween.tween_property(target, "position", orig_px, 0.1)
						else:
							vfx_manager.show_floating_text(g_pos, "PUSH!", Color.ORANGE)
							take_damage(target, 1, selected_piece)
							if is_instance_valid(target) and target.current_hp > 0:
								board.erase(g_pos)
								target.grid_pos = push_pos
								board[push_pos] = target
								
								var tween = create_tween()
								tween.tween_property(target, "position", push_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.2)
								tween.tween_callback(func(): check_nightmare_pawns_interaction(target))
							if selected_piece: update_info_panel(selected_piece.grid_pos)
							
				cancel_active_item()
				check_win_condition()
			return
	elif state == GameState.TARGETING_BLOOD_KNIFE or state == GameState.TARGETING_TORCH:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_active_item()
				return
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mpos = board_node.get_local_mouse_position()
				var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
				if selected_piece and is_inside(g_pos) and board.has(g_pos) and is_instance_valid(board[g_pos]) and board[g_pos].current_hp > 0:
					var target = board[g_pos]
					var diff = g_pos - selected_piece.grid_pos
					var is_orthogonal = diff.x == 0 or diff.y == 0
					var dist = abs(diff.x) + abs(diff.y)
					if is_orthogonal and dist > 0 and dist <= 3 and not target.has_meta("is_obstacle"):
						if state == GameState.TARGETING_BLOOD_KNIFE:
							target.bleed_stacks += 3
							vfx_manager.show_floating_text(g_pos, "BLEED +3!", Color.RED)
							selected_piece.set_meta("blood_knife_used_this_turn", true)
						else:
							if target.piece_type == PieceType.BOMB_BARREL:
								take_damage(target, 9999)
							elif target.bleed_stacks > 0:
								var dmg = target.bleed_stacks * 2
								take_damage(target, dmg)
								target.bleed_stacks = 0
								vfx_manager.show_floating_text(g_pos, "CAUTERIZED!", Color.MAGENTA)
							else:
								target.burn_stacks += 2
								vfx_manager.show_floating_text(g_pos, "BURN +2!", Color.ORANGE)
							selected_piece.set_meta("torch_used_this_turn", true)
						
						inventory_manager.recalc_pawn_stats(selected_piece)
						update_piece_slots(selected_piece)
						if selected_piece: update_info_panel(selected_piece.grid_pos)
				cancel_active_item()
			return

			
	if state != GameState.PLAYING or current_turn != 0 or game_over: return
	
	if event is InputEventMouseMotion:
		var mpos = board_node.get_local_mouse_position()
		var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
		if is_inside(g_pos):
			hovered_grid_pos = g_pos
		else:
			hovered_grid_pos = Vector2(-1, -1)
		overlay.queue_redraw()
		
		pass
		
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mpos = board_node.get_local_mouse_position()
		var g_pos = Vector2(floor(mpos.x / CELL_SIZE_V.x), floor(mpos.y / CELL_SIZE_V.y))
		
		if not is_inside(g_pos): return
		
		if force_clone_move and is_instance_valid(active_clone_piece):
			if selected_piece != active_clone_piece:
				selected_piece = active_clone_piece
			var moves = get_valid_moves(selected_piece)
			if g_pos in moves:
				perform_action(selected_piece, g_pos)
				selected_piece = null
			else:
				if board.has(g_pos) and board[g_pos] == active_clone_piece:
					update_info_panel(g_pos)
				elif board.has(g_pos):
					update_info_panel(g_pos)
			overlay.queue_redraw()
			return
		
		if selected_piece:
			var moves = get_valid_moves(selected_piece)
			if g_pos in moves:
				perform_action(selected_piece, g_pos)
				selected_piece = null
			elif board.has(g_pos) and board[g_pos].is_player:
				selected_piece = board[g_pos]
				update_info_panel(g_pos)
			else:
				selected_piece = null
				update_info_panel(g_pos)
		else:
			if board.has(g_pos) and board[g_pos].is_player:
				selected_piece = board[g_pos]
			elif board.has(g_pos):
				pass
			update_info_panel(g_pos)
		overlay.queue_redraw()

func _on_overlay_draw():
	for pos in blood_hazards.keys():
		var h = blood_hazards[pos]
		var tex = tex_blood_hazards[h.tex_idx]
		if tex:
			var s = tex.get_size()
			var sf = min((CELL_SIZE_V.x) / s.x, (CELL_SIZE_V.y) / s.y) * 0.9
			var sz = s * sf
			var offset = (CELL_SIZE_V - sz) / 2.0
			overlay.draw_texture_rect(tex, Rect2(pos * CELL_SIZE_V + offset, sz), false)
	if state == GameState.MAP:
		var node_pos_map = _get_node_pos_map()
		
		# Draw blue highlight under the current King node
		if map_manager.current_node_id != -1 and node_pos_map.has(map_manager.current_node_id):
			var king_gp = node_pos_map[map_manager.current_node_id]
			overlay.draw_rect(Rect2(king_gp * CELL_SIZE_V, CELL_SIZE_V), Color(0.2, 0.4, 1.0, 0.5))
		elif map_manager.current_node_id == -1:
			var king_gp = Vector2(2, 13)
			overlay.draw_rect(Rect2(king_gp * CELL_SIZE_V, CELL_SIZE_V), Color(0.2, 0.4, 1.0, 0.5))
		
		# Draw red highlight under reachable nodes
		var avail = map_manager.get_available_next_nodes()
		for n in avail:
			if node_pos_map.has(n.id):
				var gp = node_pos_map[n.id]
				overlay.draw_rect(Rect2(gp * CELL_SIZE_V, CELL_SIZE_V), Color(1.0, 0.2, 0.2, 0.3))
		
		if hovered_grid_pos.x != -1:
			overlay.draw_rect(Rect2(hovered_grid_pos * CELL_SIZE_V, CELL_SIZE_V), Color(1, 1, 1, 0.2))
		return

	if game_over or (state != GameState.PLAYING and state != GameState.TARGETING_SACRIFICE and state != GameState.TARGETING_DARK_MIRROR and state != GameState.TARGETING_HAND and state != GameState.TARGETING_BLOOD_KNIFE and state != GameState.TARGETING_TORCH and state != GameState.TARGETING_FINGER): return
	
	if hovered_grid_pos.x != -1:
		overlay.draw_rect(Rect2(hovered_grid_pos * CELL_SIZE_V, CELL_SIZE_V), Color(1, 1, 1, 0.2))
	
	if selected_piece and state != GameState.PLAYING:
		overlay.draw_rect(Rect2(selected_piece.grid_pos * CELL_SIZE_V, CELL_SIZE_V), Color(0.2, 0.4, 1.0, 0.5))
	if state == GameState.TARGETING_SACRIFICE and is_instance_valid(bottle_user_piece):
		overlay.draw_rect(Rect2(bottle_user_piece.grid_pos * CELL_SIZE_V, CELL_SIZE_V), Color(0.2, 0.4, 1.0, 0.5))
		
	if state == GameState.TARGETING_SACRIFICE:
		for p in player_pawns:
			if is_instance_valid(p) and p != bottle_user_piece:
				overlay.draw_rect(Rect2(p.grid_pos * CELL_SIZE_V, CELL_SIZE_V), Color(0, 1, 0, 0.3))
	elif state == GameState.TARGETING_DARK_MIRROR:
		if selected_piece:
			var g = selected_piece.grid_pos
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					if dx == 0 and dy == 0: continue
					var t = g + Vector2(dx, dy)
					if is_inside(t) and not board.has(t):
						overlay.draw_rect(Rect2(t * CELL_SIZE_V, CELL_SIZE_V), Color(0.6, 0.2, 0.8, 0.4))
	elif state == GameState.TARGETING_FINGER:
		for b in bot_pawns:
			if is_instance_valid(b) and b.current_hp > 0 and not b.has_meta("is_obstacle"):
				overlay.draw_rect(Rect2(b.grid_pos * CELL_SIZE_V, CELL_SIZE_V), Color(1.0, 0.2, 0.8, 0.4))
	elif state == GameState.TARGETING_HAND:
		if selected_piece:
			var g = selected_piece.grid_pos
			for d in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
				for i in range(1, 3):
					var t = g + d * i
					if is_inside(t):
						if board.has(t) and not board[t].is_player and not board[t].has_meta("is_obstacle") and board[t].current_hp > 0:
							overlay.draw_rect(Rect2(t * CELL_SIZE_V, CELL_SIZE_V), Color(1.0, 0.6, 0.0, 0.5))
						else:
							overlay.draw_rect(Rect2(t * CELL_SIZE_V, CELL_SIZE_V), Color(1.0, 0.8, 0.4, 0.2))
	elif state == GameState.TARGETING_BLOOD_KNIFE or state == GameState.TARGETING_TORCH:
		if selected_piece:
			var g = selected_piece.grid_pos
			for d in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
				for i in range(1, 4):
					var t = g + d * i
					if is_inside(t):
						overlay.draw_rect(Rect2(t * CELL_SIZE_V, CELL_SIZE_V), Color(1.0, 0.2, 0.2, 0.4) if state == GameState.TARGETING_BLOOD_KNIFE else Color(1.0, 0.5, 0.0, 0.4))
	else:
		if selected_piece:
			if state == GameState.PLAYING:
				overlay.draw_rect(Rect2(selected_piece.grid_pos * CELL_SIZE_V, CELL_SIZE_V), Color(0.2, 0.4, 1.0, 0.5))
			if not selected_piece.has_meta("is_obstacle"):
				var moves = get_valid_moves(selected_piece)
				for m in moves:
					overlay.draw_rect(Rect2(m * CELL_SIZE_V, CELL_SIZE_V), Color(1, 0, 0, 0.3))
		
func take_damage(piece, amt, attacker = null):
	if amt > 0:
		vfx_manager.shake_board(15.0, 0.25)

	if amt < 9999 and piece.has_meta("stacked_checker_count") and piece.get_meta("stacked_checker_count") > 0:
		var count = piece.get_meta("stacked_checker_count")
		count -= 1
		piece.set_meta("stacked_checker_count", count)
		
		var s = piece.get_node_or_null("StackedChecker")
		if s and count == 0:
			s.queue_free()
			piece.offset = Vector2.ZERO
			
		vfx_manager.show_floating_text(piece.grid_pos, "SHIELD BROKE!", Color.WHITE)
		update_info_panel(piece.grid_pos)
		vfx_manager.shake_board(10.0, 0.2)
		amt -= 1
		if amt <= 0: return
		
	var hp = piece.current_hp - amt
	piece.current_hp = hp
	
	vfx_manager.show_floating_text(piece.grid_pos, "-%d" % amt, Color.RED, "left")
	update_ui()
	
	if piece == selected_piece:
		update_info_panel(piece.grid_pos)
		
	if hp <= 0:
		if not is_instance_valid(piece):
			return
		if piece.is_player:
			any_player_piece_died = true
		if is_instance_valid(attacker) and attacker.piece_type == PieceType.BLOOD_QUEEN:
			var heal_amt = 1
			var p_name = ""
			if PieceData.registry.has(piece.piece_type):
				p_name = PieceData.registry[piece.piece_type].get("title", "").to_lower()
			if p_name.find("blood") != -1:
				heal_amt = 2
			attacker.current_hp += heal_amt
			vfx_manager.show_floating_text(attacker.grid_pos, "+%d HP" % heal_amt, Color.RED)
			update_ui()
			
		if piece.piece_type == PieceType.BOSS_DEADKING:
			var g = piece.grid_pos
			board.erase(g)
			bot_pawns.erase(piece)
			piece.queue_free()
			
			# Spawn Head and Body
			var body = EnemySpawner.spawn_piece(self, g.x, g.y, false, PieceType.BOSS_BODY)
			var head = EnemySpawner.spawn_piece(self, g.x, g.y, false, PieceType.BOSS_HEAD)
			board[g] = body # Body takes the current cell
			
			# Head flies 2 cells diagonally
			var h_dirs = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
			var best_dir = Vector2(0, 1)
			# Find a valid dir that stays on board
			for d in h_dirs:
				var t = g + d * 2
				if is_inside(t):
					best_dir = d
					break
			
			var target_head_pos = g + best_dir * 2
			head.grid_pos = target_head_pos
			
			# Wait, head should be added to board if the cell is empty?
			# The prompt says "летит по диагонали на 2 клетки и если есть фигура на его пути то он ее сталкивает на 1 клетку назад и наносит 1 урон"
			var tween = create_tween()
			tween.tween_property(head, "position", target_head_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.5)
			
			# Handle push on the way
			var path_pieces = [g + best_dir, g + best_dir * 2]
			for step_pos in path_pieces:
				if is_inside(step_pos) and board.has(step_pos):
					var obstacle = board[step_pos]
					if obstacle and obstacle != head and obstacle != body:
						var push_t = step_pos + best_dir
						if is_inside(push_t) and not board.has(push_t):
							board.erase(step_pos)
							obstacle.grid_pos = push_t
							board[push_t] = obstacle
							take_damage(obstacle, 1)
							if is_instance_valid(obstacle) and obstacle.current_hp > 0:
								tween.parallel().tween_property(obstacle, "position", push_t * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.2)
						else:
							take_damage(obstacle, 1)
						vfx_manager.show_floating_text(step_pos, "BUMP!", Color.RED)
			
			# Only place Head on board if its final cell is free. If it pushed someone from its final cell, it is free now.
			if not board.has(target_head_pos):
				board[target_head_pos] = head
			else:
				# If somehow still occupied, find a nearby empty spot
				var placed = false
				for d in [Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]:
					var alt = target_head_pos + d
					if is_inside(alt) and not board.has(alt):
						head.grid_pos = alt
						board[alt] = head
						placed = true
						tween.tween_property(head, "position", alt * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.2)
						break
				if not placed:
					# Nowhere to place head, just destroy it
					head.queue_free()
					bot_pawns.erase(head)
			
			vfx_manager.show_floating_text(g, "PHASE 2!", Color.RED)
			return
			
		elif piece.piece_type == PieceType.BOSS_HEAD:
			# Drop the item
			unassigned_items.append("deadking_head")
			vfx_manager.show_floating_text(piece.grid_pos, "GOT DEAD KING'S HEAD!", Color.GOLD)
			# Kill the body too
			for p in bot_pawns:
				if is_instance_valid(p) and p.piece_type == PieceType.BOSS_BODY:
					take_damage(p, 9999)
					break
		elif piece.piece_type == PieceType.BOMB_BARREL:
			if not piece.has_meta("exploded"):
				piece.set_meta("exploded", true)
				var g = piece.grid_pos
				
				var burst = Sprite2D.new()
				burst.texture = tex_bomb_barrel_burst
				burst.position = g * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
				burst.z_index = 5
				var ts = Vector2(1,1)
				if tex_bomb_barrel_burst: ts = tex_bomb_barrel_burst.get_size()
				if ts.x == 0: ts = Vector2(1,1)
				var sf = min((CELL_SIZE_V.x * 3.0) / ts.x, (CELL_SIZE_V.y * 3.0) / ts.y)
				burst.scale = Vector2(sf, sf)
				board_node.add_child(burst)
				var tween = create_tween()
				tween.tween_property(burst, "modulate:a", 0.0, 2.0)
				tween.tween_callback(burst.queue_free)
				
				var outline = Node2D.new()
				var script = GDScript.new()
				script.source_code = "extends Node2D\nvar size: Vector2\nfunc _draw():\n\tvar rect = Rect2(-size/2, size)\n\tvar pts = [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y), rect.position]\n\tfor i in range(4):\n\t\tdraw_dashed_line(pts[i], pts[i+1], Color.RED, 4.0, 10.0)"
				script.reload()
				outline.set_script(script)
				outline.set("size", CELL_SIZE_V * 3.0)
				outline.position = g * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
				outline.z_index = 4
				board_node.add_child(outline)
				var outline_tween = create_tween()
				outline_tween.tween_property(outline, "modulate:a", 0.0, 2.0)
				outline_tween.tween_callback(outline.queue_free)
				
				var targets = []
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						var t = g + Vector2(dx, dy)
						if is_inside(t) and board.has(t) and board[t] != piece:
							targets.append(board[t])
				
				if is_instance_valid(attacker) and not targets.has(attacker):
					targets.append(attacker)
				
				for t in targets:
					if is_instance_valid(t):
						if t.has_meta("is_obstacle"):
							take_damage(t, 999)
						else:
							take_damage(t, 2)
		if piece.is_player and piece.piece_type == PieceType.KING and not piece.has_meta("is_clone"):
			trigger_game_over("Game Over! King Died!")
			
		var g = piece.grid_pos
		board.erase(g)
			
		if not piece.is_player and piece.piece_type != PieceType.POOP:
			vfx_manager.spawn_blood_puddle(g)
			
		var dead_tex = PieceData.get_piece_texture(piece.piece_type, piece.is_player)
		var dead_title = PieceData.registry.get(piece.piece_type, {}).get("title", "?")
		var dead_entry = {"tex": dead_tex, "type": piece.piece_type, "name": dead_title, "is_player": piece.is_player, "max_hp": piece.max_hp, "artifacts": piece.artifacts.duplicate()}
		
		var is_junk = piece.piece_type == PieceType.POOP or piece.piece_type == PieceType.ROCK
		if piece.is_player:
			if not is_junk: graveyard.append(dead_entry)
			player_pawns.erase(piece)
			if player_pawns.is_empty():
				trigger_game_over("Game Over! All pieces lost!")
		elif bot_pawns.has(piece):
			if not is_junk: enemy_graveyard.append(dead_entry)
			bot_pawns.erase(piece)
			
		if board.has(piece.grid_pos) and board[piece.grid_pos] == piece:
			board.erase(piece.grid_pos)
			
		piece.queue_free()
		if piece == selected_piece: selected_piece = null
		update_info_panel(g)
		update_graveyard_ui()
		check_win_condition()

func trigger_game_over(msg):
	if game_over: return
	game_over = true
	info_panel.hide()
	status_label.text = msg
	status_label.set("theme_override_colors/font_color", Color.RED)
	game_over_panel.show()

func perform_action(piece, target_pos):
	var g_pos = piece.grid_pos
	var is_player = piece.is_player
	var atk = piece.attack_damage
	var type = piece.piece_type
	var target_piece = board.get(target_pos)
	
	if target_piece:
		if target_piece.piece_type == PieceType.CHECKER and target_piece.is_player == piece.is_player:
			if piece.has_meta("is_clone"):
				vfx_manager.show_floating_text(piece.grid_pos, "SPLAT!", Color.AQUA)
				take_damage(piece, 9999)
				var tween = create_tween()
				end_turn_with_tween(null, target_pos, tween, piece.is_player)
				return
			
			var count = piece.get_meta("stacked_checker_count") if piece.has_meta("stacked_checker_count") else 0
			count += 1
			piece.set_meta("stacked_checker_count", count)
			piece.attack_damage += 1
			
			vfx_manager.show_floating_text(target_pos, "+1 RANGE (Checker Stacked)", Color.YELLOW)
			
			board.erase(target_pos)
			if target_piece.is_player:
				player_pawns.erase(target_piece)
			else:
				bot_pawns.erase(target_piece)
			target_piece.queue_free()
			
			var s = piece.get_node_or_null("StackedChecker")
			if not s:
				piece.offset = Vector2(0, -10)
				var checker_sprite = Sprite2D.new()
				checker_sprite.name = "StackedChecker"
				checker_sprite.texture = PieceData.get_piece_texture(PieceType.CHECKER, piece.is_player)
				checker_sprite.position = Vector2(0, 15)
				checker_sprite.show_behind_parent = true
				var ts = checker_sprite.texture.get_size() if checker_sprite.texture else Vector2(1,1)
				var sf_checker = min(CELL_SIZE_V.x * 0.8 / ts.x, CELL_SIZE_V.y * 0.8 / ts.y) * 0.6
				if piece.scale.x > 0 and piece.scale.y > 0:
					checker_sprite.scale = Vector2(sf_checker / piece.scale.x, sf_checker / piece.scale.y)
				piece.add_child(checker_sprite)
				update_piece_slots(piece)
				
			board.erase(g_pos)
			piece.grid_pos = target_pos
			board[target_pos] = piece
			
			var tween = create_tween()
			tween.tween_property(piece, "position", target_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.3)
			end_turn_with_tween(piece, target_pos, tween)
			return
			
		var was_poop = target_piece.has_meta("is_obstacle") and target_piece.piece_type == PieceType.POOP
		
		if piece.has_meta("is_clone") and was_poop:
			vfx_manager.show_floating_text(piece.grid_pos, TranslationManager.translate("splat"), Color.BROWN)
			take_damage(piece, 9999)
			var tween = create_tween()
			end_turn_with_tween(null, target_pos, tween, piece.is_player)
			return
			
		take_damage(target_piece, atk, piece)
		
		if is_instance_valid(piece) and piece.artifacts.has("shark_tooth") and is_instance_valid(target_piece) and target_piece.current_hp > 0:
			target_piece.bleed_stacks += 1
			vfx_manager.show_floating_text(target_pos, TranslationManager.translate("bleed"), Color.RED)
		
		if is_instance_valid(target_piece) and target_piece.has_spikes:
			take_damage(piece, 1)
			vfx_manager.show_floating_text(g_pos, TranslationManager.translate("spiked"), Color.RED)
			
		var bump_pos = (g_pos * CELL_SIZE_V + target_pos * CELL_SIZE_V) / 2.0 + (CELL_SIZE_V / 2.0)
		var tween = create_tween()
		if is_instance_valid(piece):
			tween.tween_property(piece, "position", bump_pos, 0.15)
		
		if not is_instance_valid(target_piece) or target_piece.current_hp <= 0:
			if is_instance_valid(piece) and piece.current_hp > 0:
				if piece.artifacts.has("deadking_head"):
					piece.current_hp += 1
					vfx_manager.show_floating_text(piece.grid_pos, "+1 HP", Color.GREEN)
					if piece == selected_piece: update_info_panel(piece.grid_pos)
				
				if not board.has(target_pos) or board[target_pos] == target_piece:
					board.erase(g_pos)
					piece.grid_pos = target_pos
					board[target_pos] = piece
					handle_movement_bleed(piece, g_pos, target_pos)
					tween.tween_property(piece, "position", target_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.15)
				else:
					tween.tween_property(piece, "position", g_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.15)
				
				if was_poop and is_player:
					var r = randf()
					if r < 0.75:
						var c = randi_range(1, 3)
						coins += c
						update_ui()
						vfx_manager.show_floating_text(target_pos, "+%d Coins" % c, Color(1, 0.8, 0))
					else:
						piece.current_hp += 1
						vfx_manager.show_floating_text(target_pos, "+1 HP", Color(0.2, 1, 0.2))
					
		else:
			var stop_pos = get_cell_before_target(g_pos, target_pos)
			if stop_pos != g_pos and not board.has(stop_pos):
				board.erase(g_pos)
				piece.grid_pos = stop_pos
				board[stop_pos] = piece
				handle_movement_bleed(piece, g_pos, stop_pos)
				var move_px = stop_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
				tween.tween_property(piece, "position", move_px, 0.15)
			else:
				tween.tween_property(piece, "position", g_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.15)
				
		if is_instance_valid(piece) and piece.current_hp > 0 and piece.piece_type == PieceType.TELEPAWN:
			var empty_spots = []
			for x in range(COLS):
				for y in range(ROWS):
					var pos2 = Vector2(x, y)
					if not board.has(pos2): empty_spots.append(pos2)
			if empty_spots.size() > 0:
				var tp = empty_spots[randi() % empty_spots.size()]
				var old_gp = piece.grid_pos
				board.erase(piece.grid_pos)
				piece.grid_pos = tp
				board[tp] = piece
				handle_movement_bleed(piece, old_gp, tp)
				tween.tween_property(piece, "position", tp * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.15)
				vfx_manager.show_floating_text(tp, "TELEPORT!", Color.CYAN)
				end_turn_with_tween(piece, tp, tween, is_player)
				return
				
		if is_instance_valid(piece) and piece.current_hp > 0:
			if piece.is_player and piece.artifacts.has("brain_jar") and not piece.get_meta("brain_used_this_turn", false):
				piece.set_meta("brain_used_this_turn", true)
				vfx_manager.show_floating_text(target_pos, "FREE ACTION!", Color.CYAN)
				normal_move_used = false
				selected_piece = null
				overlay.queue_redraw()
				update_ui()
				check_nightmare_pawns_interaction(piece)
			elif piece.is_player and piece.has_meta("swift") and piece.piece_type == PieceType.QUEEN:
				vfx_manager.show_floating_text(target_pos, "SWIFT STRIKE!", Color.CYAN)
				normal_move_used = false
				selected_piece = null
				overlay.queue_redraw()
				check_nightmare_pawns_interaction(piece)
			else:
				end_turn_with_tween(piece, target_pos, tween)
		else:
			end_turn_with_tween(null, target_pos, tween, is_player)
			
	else:
		board.erase(g_pos)
		piece.grid_pos = target_pos
		board[target_pos] = piece
		handle_movement_bleed(piece, g_pos, target_pos)
		
		var tween = create_tween()
		tween.tween_property(piece, "position", target_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0), 0.3)
		if piece.is_player and piece.artifacts.has("brain_jar") and not piece.get_meta("brain_used_this_turn", false):
			piece.set_meta("brain_used_this_turn", true)
			vfx_manager.show_floating_text(target_pos, "FREE ACTION!", Color.CYAN)
			normal_move_used = false
			selected_piece = null
			overlay.queue_redraw()
			update_ui()
			check_nightmare_pawns_interaction(piece)
		else:
			end_turn_with_tween(piece, target_pos, tween)




func show_floating_text(grid_pos, text, color, align = "center"):
	vfx_manager.show_floating_text(grid_pos, text, color, align)

func handle_movement_bleed(piece, start_pos, target_pos):
	combat_manager.handle_movement_bleed(piece, start_pos, target_pos)

func tick_statuses(is_player_turn):
	combat_manager.tick_statuses(is_player_turn)

func check_floor_hazards(_piece):
	pass


func is_hazard_cell(_pos):
	return false
func end_turn_with_tween(piece, _target_pos, tween, was_player = null, skip_turn_change = false):
	var is_player = was_player
	if is_instance_valid(piece):
		is_player = piece.is_player
		tween.tween_callback(func(): check_floor_hazards(piece))
		tween.tween_callback(func(): check_nightmare_pawns_interaction(piece))
	if is_player:
		var clone_died = clone_active and (not is_instance_valid(active_clone_piece) or active_clone_piece.current_hp <= 0)
		var moved_was_clone = piece != null and piece.has_meta("is_clone")
		if not moved_was_clone:
			normal_move_used = true
			
		if clone_active and not clone_died and normal_move_used:
			tween.tween_callback(func():
				force_clone_move = true
				selected_piece = active_clone_piece
				update_info_panel(active_clone_piece.grid_pos)
				overlay.queue_redraw()
				status_label.text = "Move the Clone!"
				status_label.set("theme_override_colors/font_color", Color.CYAN)
			)
		elif not normal_move_used:
			if clone_active and moved_was_clone:
				tween.tween_callback(func():
					if is_instance_valid(active_clone_piece):
						board.erase(active_clone_piece.grid_pos)
						player_pawns.erase(active_clone_piece)
						active_clone_piece.queue_free()
					clone_active = false
					active_clone_piece = null
					force_clone_move = false
				)
			tween.tween_callback(func():
				status_label.text = TranslationManager.translate("player_turn", [turn_count])
				status_label.set("theme_override_colors/font_color", Color.WHITE)
			)
		else:
			if clone_active:
				tween.tween_callback(func():
					if is_instance_valid(active_clone_piece):
						board.erase(active_clone_piece.grid_pos)
						player_pawns.erase(active_clone_piece)
						active_clone_piece.queue_free()
					clone_active = false
					active_clone_piece = null
					force_clone_move = false
				)
			if not skip_turn_change:
				current_turn = 1
				status_label.text = "Enemy Turn %d" % turn_count
				status_label.set("theme_override_colors/font_color", Color.RED)
				tween.tween_callback(bot_turn)
	else:
		if not skip_turn_change:
			tween.tween_callback(start_player_turn)

func get_cell_before_target(g_pos: Vector2, target_pos: Vector2) -> Vector2:
	return combat_manager.get_cell_before_target(g_pos, target_pos)

func start_player_turn():
	current_turn = 0
	turn_count += 1
	normal_move_used = false
	status_label.text = TranslationManager.translate("player_turn", [turn_count])
	status_label.set("theme_override_colors/font_color", Color.WHITE)
	tick_statuses(true)
	check_win_condition()

func bot_turn():
	tick_statuses(false)
	await get_tree().create_timer(0.4).timeout
	var moved = EnemyAI.process_bot_turn(self)
	
	if not moved:
		start_player_turn()

func show_dead_piece_info(dead):
	info_panel.set_meta("viewed_piece", dead)
	info_panel.show()
	info_item_slots.show()
	
	if info_statuses:
		for c in info_statuses.get_children():
			c.queue_free()
	
	var title = dead.get("name", "Unknown")
	var desc = ""
	var max_hp = dead.get("max_hp", 0)
	
	var dtype = dead.type
	if typeof(dtype) == TYPE_FLOAT or typeof(dtype) == TYPE_STRING: dtype = int(dtype)
	var data = PieceData.registry.get(dtype)
	if data:
		desc = data.get("desc", "")
	
	info_name.text = title
	info_stats.modulate.a = 1
	info_item_slots.modulate.a = 1
	
	info_stats.text = "0 HP   0 ATK"
	if dead.is_player:
		info_stats.set("theme_override_colors/font_color", Color(0.4, 0.8, 1.0))
	else:
		info_stats.set("theme_override_colors/font_color", Color(1.0, 0.4, 0.4))
		
	info_desc.text = desc
	
	if dead.has("tex"):
		if typeof(dead.tex) == TYPE_OBJECT:
			info_tex.texture = dead.tex
		elif typeof(dead.tex) == TYPE_STRING and ResourceLoader.exists(dead.tex):
			info_tex.texture = load(dead.tex)
		else:
			info_tex.texture = PieceData.get_piece_texture(dead.type, dead.is_player)
	else:
		info_tex.texture = PieceData.get_piece_texture(dead.type, dead.is_player)
	
	info_tex.scale = Vector2(1, 1)
	var base_c = Color.WHITE
	if not dead.is_player and dead.has("type") and dead.type != PieceType.POOP and dead.type != PieceType.ROCK and dead.type != PieceType.BOMB_BARREL:
		base_c = Color(1.0, 0.4, 0.4)
	info_tex.modulate = base_c
	
	for i in range(3):
		if i < info_item_slots.get_child_count():
			var slot = info_item_slots.get_child(i)
			if dead.has("artifacts") and i < dead.artifacts.size():
				slot.get_child(0).texture = load("res://images/items/%s.png" % dead.artifacts[i])
			else:
				slot.get_child(0).texture = null
				
func update_info_panel(g_pos):
	var found = null
	if board.has(g_pos): found = board[g_pos]
	else:
		for h in hazards:
			if is_instance_valid(h) and h.grid_pos == g_pos:
				found = h
				break
	


	if found:
		info_panel.set_meta("viewed_piece", found)
		info_panel.show()
		info_item_slots.show()
		
		if info_statuses:
			for c in info_statuses.get_children():
				c.queue_free()
			
			if found.get("bleed_stacks") != null:
				var statuses = []
				if found.bleed_stacks > 0:
					statuses.append({"tex": load("res://images/status_blood.png"), "text": "Bleed: %d" % found.bleed_stacks, "desc": "Takes 1 damage per stack per cell moved."})
				if found.burn_stacks > 0:
					statuses.append({"tex": load("res://images/status_fire.png"), "text": "Burn: %d" % found.burn_stacks, "desc": "Takes 1 damage per stack at the end of each turn."})
				if found.is_poisoned:
					statuses.append({"tex": load("res://images/status_poison.png"), "text": "Poisoned", "desc": "Takes 1 damage at the end of its team's turn."})
					
				for st in statuses:
					var tex_rect = TextureRect.new()
					tex_rect.texture = st.tex
					tex_rect.custom_minimum_size = Vector2(32, 32)
					tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
					tex_rect.tooltip_text = st.desc
					
					var lbl = Label.new()
					lbl.text = st.text
					lbl.set("theme_override_font_sizes/font_size", 16)
					
					var hbox = HBoxContainer.new()
					hbox.add_child(tex_rect)
					hbox.add_child(lbl)
					info_statuses.add_child(hbox)
		
		var title = "Unknown"
		var desc = ""
		
		var data = PieceData.registry.get(found.piece_type)
		if data:
			title = data.get("title", "Unknown")
			desc = data.get("desc", "")
		
		info_name.text = title
		
		if found.get("is_player") != null:
			if found.is_player:
				info_stats.set("theme_override_colors/font_color", Color(0.4, 0.8, 1.0))
			else:
				info_stats.set("theme_override_colors/font_color", Color(1.0, 0.4, 0.4))
		else:
			info_stats.set("theme_override_colors/font_color", Color.WHITE)
			
		if found.has_meta("is_obstacle") or found.piece_type == PieceType.CHECKER:
			info_stats.modulate.a = 0 if found.has_meta("is_obstacle") else 1
			info_item_slots.modulate.a = 0
			if info_tex.has_node("InfoStackedChecker"):
				info_tex.get_node("InfoStackedChecker").queue_free()
		else:
			info_stats.modulate.a = 1
			info_item_slots.modulate.a = 1
			
			var is_checker = found.piece_type == PieceType.CHECKER
			var has_stacked = found.has_meta("stacked_checker_count") and found.get_meta("stacked_checker_count") > 0
			
			if has_stacked:
				var count = found.get_meta("stacked_checker_count")
				info_stats.text = "%d+%d HP   %d+%d ATK" % [found.current_hp, count, found.attack_damage - count, count]
				desc = "Stacked Checker: Moves 1 step orthogonally. Can be stacked under another piece for +1 ATK and a 1-hit shield.\n\n" + desc
			else:
				info_stats.text = "%d HP   %d ATK" % [found.current_hp, found.attack_damage]
				
			# Setup stacked checker icon in preview
			if has_stacked:
				var stack_rect = info_tex.get_node_or_null("InfoStackedChecker")
				if not stack_rect:
					stack_rect = TextureRect.new()
					stack_rect.name = "InfoStackedChecker"
					stack_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
					stack_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					stack_rect.custom_minimum_size = Vector2(240, 240)
					stack_rect.size = Vector2(240, 240)
					stack_rect.position = Vector2(0, 45)
					stack_rect.show_behind_parent = true
					info_tex.add_child(stack_rect)
				stack_rect.texture = PieceData.get_piece_texture(PieceType.CHECKER, found.is_player)
			else:
				if info_tex.has_node("InfoStackedChecker"):
					info_tex.get_node("InfoStackedChecker").queue_free()
			
			# Set item icons
			var is_mirror = found.artifacts.size() > 1 and found.artifacts[1] == "dark_mirror"
			for i in range(3):
				var slot_node = info_item_slots.get_child(i)
				var tex_rect = slot_node.get_child(0)
				if i < found.artifacts.size():
					var art = found.artifacts[i]
					slot_node.set_meta("item_id", art)
					tex_rect.texture = inventory_manager.get_item_texture(art)
					if art == "hand" and found.has_meta("hand_used_this_turn") and found.get_meta("hand_used_this_turn"):
						tex_rect.modulate = Color(0.3, 0.3, 0.3)
					elif art == "dark_mirror" and mirror_used_this_level:
						tex_rect.modulate = Color(0.3, 0.3, 0.3)
					elif art == "blood_knife" and found.has_meta("blood_knife_used_this_turn") and found.get_meta("blood_knife_used_this_turn"):
						tex_rect.modulate = Color(0.3, 0.3, 0.3)
					elif art == "torch" and found.has_meta("torch_used_this_turn") and found.get_meta("torch_used_this_turn"):
						tex_rect.modulate = Color(0.3, 0.3, 0.3)
					elif art == "finger" and found.has_meta("finger_used_this_turn") and found.get_meta("finger_used_this_turn"):
						tex_rect.modulate = Color(0.3, 0.3, 0.3)
					else:
						tex_rect.modulate = Color.WHITE
				else:
					slot_node.set_meta("item_id", "")
					tex_rect.texture = null
					tex_rect.modulate = Color.WHITE
					
				var style_box = slot_node.get_theme_stylebox("panel").duplicate()
				if is_checker:
					slot_node.hide()
				else:
					slot_node.show()
					if is_mirror and (i == 0 or i == 2):
						style_box.bg_color = Color(0.4, 0.1, 0.1, 1.0)
						slot_node.modulate = Color(0.5, 0.5, 0.5, 0.7)
					else:
						style_box.bg_color = Color(0.2, 0.22, 0.28, 1.0)
						slot_node.modulate = Color.WHITE
					slot_node.add_theme_stylebox_override("panel", style_box)
		
		info_desc.text = desc
		info_tex.texture = found.texture
				
		overlay.queue_redraw()
	else:
		info_panel.hide()
		right_click_target = null
		if info_tex.has_node("InfoStackedChecker"):
			info_tex.get_node("InfoStackedChecker").queue_free()
		overlay.queue_redraw()

func check_win_condition():
	if game_over or state != GameState.PLAYING: return
	bot_pawns = bot_pawns.filter(func(p): return is_instance_valid(p) and p.current_hp > 0)
	player_pawns = player_pawns.filter(func(p): return is_instance_valid(p) and p.current_hp > 0)
	
	var king_alive = false
	for p in player_pawns:
		if p.piece_type == PieceType.KING and not p.has_meta("is_clone"): king_alive = true
		
	var real_bots_left = 0
	for b in bot_pawns:
		if is_instance_valid(b) and not b.has_meta("is_obstacle"):
			real_bots_left += 1
		
	if not king_alive or player_pawns.is_empty():
		status_label.text = "Game Over! You Lose!"
		status_label.set("theme_override_colors/font_color", Color.RED)
		game_over = true
		info_panel.hide()
	elif real_bots_left == 0:
		end_level()

func end_level():
	if state == GameState.MAP: return
	for p in player_pawns:
		if is_instance_valid(p) and p.piece_type == PieceType.BLOOD_QUEEN:
			if p.current_hp > 2:
				p.current_hp = 2
	info_panel.hide()
	coins += randi_range(15, 20)
	update_ui()
	
	var real_pawns = []
	for p in player_pawns:
		if p.has_meta("is_clone"):
			board.erase(p.grid_pos)
			p.queue_free()
		else:
			real_pawns.append(p)
	player_pawns = real_pawns
	clone_active = false
	force_clone_move = false
	
	for b in bot_pawns:
		if is_instance_valid(b):
			var g = b.grid_pos
			board.erase(g)
			b.queue_free()
	bot_pawns.clear()
	
	var obstacles = []
	for pos in board:
		if board[pos].has_meta("is_obstacle"): obstacles.append(pos)
	for pos in obstacles:
		board[pos].queue_free()
		board.erase(pos)
	
	for bp in blood_puddles:
		if is_instance_valid(bp["node"]): bp["node"].queue_free()
	blood_puddles.clear()
	
	update_ui_translation()
	
	if not player_pawns.is_empty():
		show_level_up_screen()
	else:
		start_map_mode()

func generate_shop():
	for child in shop_items_container.get_children():
		shop_items_container.remove_child(child)
		child.queue_free()
	
	var figure_pool = [PieceType.PAWN, PieceType.KNIGHT, PieceType.BISHOP, PieceType.ROOK, PieceType.QUEEN, PieceType.TELEPAWN, PieceType.CHECKER, PieceType.NIGHTMARE_PAWN, PieceType.BLOOD_QUEEN, PieceType.SPIKED_PAWN]
	var item_pool = ["knife", "bottle", "boots", "dark_mirror", "hand", "blood_knife", "torch", "finger", "shark_tooth", "hoof", "brain_jar"]
	
	var shelves = [
		{"type": "figure", "icon": "shelf1_shop.png", "cost": 8},
		{"type": "item", "icon": "shelf2_shop.png", "cost": 10},
		{"type": "random", "icon": "shelf1_shop.png", "cost_figure": 8, "cost_item": 10},
	]
	
	for s in shelves:
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 4)
		vbox.custom_minimum_size = Vector2(200, 300)
		shop_items_container.add_child(vbox)
		
		var shelf_tex = load("res://images/" + s["icon"])
		
		var shelf_panel = PanelContainer.new()
		shelf_panel.custom_minimum_size = Vector2(180, 200)
		shelf_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if shelf_tex:
			var style = StyleBoxTexture.new()
			style.texture = shelf_tex
			shelf_panel.add_theme_stylebox_override("panel", style)
		vbox.add_child(shelf_panel)
		
		var inner = VBoxContainer.new()
		inner.alignment = BoxContainer.ALIGNMENT_CENTER
		inner.add_theme_constant_override("separation", 6)
		shelf_panel.add_child(inner)
		
		var is_figure = s["type"] == "figure" or (s["type"] == "random" and randf() < 0.5)
		
		if is_figure:
			var ft = figure_pool[randi() % figure_pool.size()]
			var cost = s.get("cost", s.get("cost_figure", 8))
			var data = PieceData.registry.get(ft, PieceData.registry[PieceType.PAWN])
			var type_name = data.get("title", "Unknown")
			var tex = PieceData.get_piece_texture(ft, true)
			
			var icon = TextureRect.new()
			if tex:
				icon.texture = tex
			icon.custom_minimum_size = Vector2(64, 64)
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			inner.add_child(icon)
			
			var info = Label.new()
			info.text = type_name + "\n$" + str(cost)
			info.set("theme_override_colors/font_color", Color.WHITE)
			info.set("theme_override_font_sizes/font_size", 16)
			info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			inner.add_child(info)
			
			var btn = Button.new()
			btn.text = "Buy"
			btn.custom_minimum_size = Vector2(120, 36)
			btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			btn.pressed.connect(buy_item.bind(ft, cost, btn, false))
			btn.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
					inventory_manager.show_item_info(PieceType.keys()[ft], btn.global_position + Vector2(20,20))
			)
			vbox.add_child(btn)
		else:
			var it = item_pool[randi() % item_pool.size()]
			var cost = s.get("cost", s.get("cost_item", 10))
			
			var icon = TextureRect.new()
			icon.texture = inventory_manager.get_item_texture(it)
			icon.custom_minimum_size = Vector2(64, 64)
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			inner.add_child(icon)
			
			var info = Label.new()
			info.text = it.replace("_", " ").capitalize() + "\n$" + str(cost)
			info.set("theme_override_colors/font_color", Color.WHITE)
			info.set("theme_override_font_sizes/font_size", 16)
			info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			inner.add_child(info)
			
			var btn = Button.new()
			btn.text = "Buy"
			btn.custom_minimum_size = Vector2(120, 36)
			btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			btn.pressed.connect(buy_item.bind(it, cost, btn, true))
			btn.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
					inventory_manager.show_item_info(it, btn.global_position + Vector2(20,20))
			)
			vbox.add_child(btn)

func buy_item(type, cost, btn, is_item):
	if coins >= cost:
		if is_item:
			coins -= cost
			update_ui()
			btn.disabled = true
			btn.text = "Sold"
			unassigned_items.append(type)
		else:
			var empty_spots = []
			for x in range(COLS):
				for y in range(ROWS-2, ROWS):
					if not board.has(Vector2(x, y)):
						empty_spots.append(Vector2(x, y))
			if empty_spots.is_empty(): return
			coins -= cost
			update_ui()
			btn.disabled = true
			btn.text = "Sold"
			var spot = empty_spots[randi() % empty_spots.size()]
			EnemySpawner.spawn_piece(self, spot.x, spot.y, true, type)

func start_next_level(node_info):
	level = node_info.floor + 1
	turn_count = 1
	mirror_used_this_level = false
	for p in player_pawns:
		if is_instance_valid(p):
			p.bottle_used_this_level = false
			p.set_meta("hand_used_this_turn", false)
			p.set_meta("mirror_used_this_turn", false)
			p.set_meta("blood_knife_used_this_turn", false)
			p.set_meta("torch_used_this_turn", false)
			p.set_meta("finger_used_this_turn", false)
			p.set_meta("brain_used_this_turn", false)
	state = GameState.PLAYING
	shop_panel.hide()
	update_ui()
	
	clear_map_stuff()
	if is_instance_valid(map_king): map_king.hide()
	
	status_label.text = TranslationManager.translate("player_turn", [turn_count])
	for lbl in get_tree().get_nodes_in_group("grid_labels"): lbl.show()
	for p in player_pawns: if is_instance_valid(p): check_floor_hazards(p)
	current_turn = 0
	
	player_pawns = player_pawns.filter(func(p): return is_instance_valid(p))
	var p_pieces = player_pawns.duplicate()
	player_pawns.clear()
	
	# Fix "figures in figures" mid-combat reload
	for b in bot_pawns:
		if is_instance_valid(b): b.queue_free()
	bot_pawns.clear()
	
	board.clear()
	for h in hazards: if is_instance_valid(h): h.queue_free()
	hazards.clear()
	blood_hazards.clear()
	for p in p_pieces:
		if is_instance_valid(p):
			p.bleed_stacks = 0
			p.burn_stacks = 0
			p.is_poisoned = false
	for bp in blood_puddles:
		if is_instance_valid(bp["node"]): bp["node"].queue_free()
	blood_puddles.clear()
	
	var empty_player_spots = []
	for x in range(COLS):
		for y in range(ROWS-2, ROWS):
			empty_player_spots.append(Vector2(x, y))
			
	# Remove spots that are claimed by surviving pieces
	var claimed_spots = []
	for p in p_pieces:
		if p.has_meta("start_pos"):
			var sp = p.get_meta("start_pos")
			if sp.y >= ROWS - 2:
				claimed_spots.append(sp)
			else:
				# Invalid start pos (spawned mid combat), remove it so it gets a valid one
				p.remove_meta("start_pos")
				
	empty_player_spots = empty_player_spots.filter(func(s): return not s in claimed_spots)
	empty_player_spots.shuffle()
	
	for p in p_pieces:
		p.bottle_used_this_level = false
		var spot = Vector2.ZERO
		
		if p.has_meta("start_pos"):
			spot = p.get_meta("start_pos")
		else:
			if empty_player_spots.size() > 0:
				spot = empty_player_spots.pop_back()
				p.set_meta("start_pos", spot)
			else:
				p.queue_free()
				continue
				
		p.grid_pos = spot
		p.position = spot * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
		p.show()
		board[spot] = p
		player_pawns.append(p)
			
	var obstacle_spots = []
	for x in range(COLS):
		for y in range(3, 5):
			obstacle_spots.append(Vector2(x, y))
	obstacle_spots.shuffle()
	
	var num_rocks = randi_range(1, 2)
	var num_poops = randi_range(1, 2)
	var num_barrels = randi_range(0, 1)
	var num_bots = min(int(node_info.floor / 2.0) + 2, 8)
	
	if node_info.type == map_manager.NodeType.BOSS:
		num_rocks = 0; num_poops = 0; num_barrels = 0; num_bots = 0
		var boss_spot = obstacle_spots.pop_back()
		EnemySpawner.spawn_piece(self, boss_spot.x, boss_spot.y, false, PieceType.BOSS_DEADKING)
	elif node_info.type == map_manager.NodeType.ELITE:
		num_bots = min(num_bots + 1, 9)
		num_rocks = 3

	for i in range(num_rocks):
		if obstacle_spots.size() > 0:
			var spot = obstacle_spots.pop_back()
			EnemySpawner.spawn_piece(self, spot.x, spot.y, false, PieceType.ROCK)
			
	for i in range(num_poops):
		if obstacle_spots.size() > 0:
			var spot = obstacle_spots.pop_back()
			EnemySpawner.spawn_piece(self, spot.x, spot.y, false, PieceType.POOP)
			
	for i in range(num_barrels):
		if obstacle_spots.size() > 0:
			var spot = obstacle_spots.pop_back()
			EnemySpawner.spawn_piece(self, spot.x, spot.y, false, PieceType.BOMB_BARREL)
			
	var empty_bot_spots = []
	for x in range(COLS):
		for y in range(0, 3):
			if not board.has(Vector2(x, y)):
				empty_bot_spots.append(Vector2(x, y))
	empty_bot_spots.shuffle()
	
	for i in range(num_bots):
		if i >= empty_bot_spots.size(): break
		var spot = empty_bot_spots[i]
		var btype = PieceType.PAWN
		if node_info.floor > 1 and randf() < 0.2: btype = PieceType.KNIGHT
		if node_info.floor > 2 and randf() < 0.2: btype = PieceType.BISHOP
		if node_info.floor > 3 and randf() < 0.15: btype = PieceType.ROOK
		if node_info.floor > 4 and randf() < 0.1: btype = PieceType.QUEEN
		EnemySpawner.spawn_piece(self, spot.x, spot.y, false, btype)
		
	update_graveyard_ui()
	save_game_state()

func start_dark_mirror_targeting(_p, slot_ui = null):
	inv_panel.hide()
	state = GameState.TARGETING_DARK_MIRROR
	active_item_slot_ui = slot_ui
	if active_item_slot_ui:
		active_item_slot_ui.modulate = Color(0.2, 0.8, 1.0)
	if cancel_btn: cancel_btn.show()
	status_label.text = "Select adjacent empty tile for clone..."
	status_label.set("theme_override_colors/font_color", Color.CYAN)

func start_hand_targeting(_p, slot_ui = null):
	inv_panel.hide()
	state = GameState.TARGETING_HAND
	active_item_slot_ui = slot_ui
	if active_item_slot_ui:
		active_item_slot_ui.modulate = Color(1.0, 0.8, 0.2)
	if cancel_btn: cancel_btn.show()
	status_label.text = "Select enemy up to 2 cells orthogonally..."
	status_label.set("theme_override_colors/font_color", Color.ORANGE)

func start_blood_knife_targeting(_p, slot_ui = null):
	inv_panel.hide()
	state = GameState.TARGETING_BLOOD_KNIFE
	active_item_slot_ui = slot_ui
	if active_item_slot_ui:
		active_item_slot_ui.modulate = Color(0.2, 0.8, 1.0)
	if cancel_btn: cancel_btn.show()
	status_label.text = "Select target to bleed (range 3)..."
	status_label.set("theme_override_colors/font_color", Color.RED)

func start_torch_targeting(_p, slot_ui = null):
	inv_panel.hide()
	state = GameState.TARGETING_TORCH
	active_item_slot_ui = slot_ui
	if active_item_slot_ui:
		active_item_slot_ui.modulate = Color(0.2, 0.8, 1.0)
	if cancel_btn: cancel_btn.show()
	status_label.text = "Select target to burn (range 3)..."
	status_label.set("theme_override_colors/font_color", Color.ORANGE)

func start_finger_targeting(_p, slot_ui = null):
	inv_panel.hide()
	state = GameState.TARGETING_FINGER
	active_item_slot_ui = slot_ui
	if active_item_slot_ui: active_item_slot_ui.modulate = Color(1.0, 0.2, 0.8)
	if cancel_btn: cancel_btn.show()
	status_label.text = "Select an enemy to command..."
	status_label.set("theme_override_colors/font_color", Color.MAGENTA)

func spawn_clone_piece(original, target_pos):
	var clone = Entity.new()
	clone.piece_type = original.piece_type
	clone.is_player = true
	clone.texture = original.texture
	clone.scale = original.scale
	clone.z_index = 0
	
	clone.max_hp = original.max_hp
	clone.current_hp = original.current_hp
	clone.attack_damage = original.attack_damage
	
	clone.modulate = Color(0.5, 0.8, 1.0, 0.6)
	clone.set_meta("is_clone", true)
	
	clone.grid_pos = target_pos
	board[target_pos] = clone
	clone.position = target_pos * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
	
	player_pawns.append(clone)
	board_node.add_child(clone)
	
	clone_active = true
	active_clone_piece = clone
	
	vfx_manager.show_floating_text(target_pos, "CLONED!", Color.CYAN)

func check_nightmare_pawns_interaction(moved_piece):
	combat_manager.check_nightmare_pawns_interaction(moved_piece)



func clear_map_stuff():
	var to_del = []
	for c in board_node.get_children():
		if c.has_meta("is_map_stuff") and c != map_king:
			to_del.append(c)
	for c in to_del: c.queue_free()


func update_map_scroll():
	if state != GameState.MAP: return
	
	var current_floor = map_manager.current_floor
	# Map nodes go from y = MAP_ROWS - 2 (floor 0) to y = MAP_ROWS - 2 - MAX_FLOORS
	var current_y = MAP_ROWS - 2 - current_floor
	
	var screen_h = get_window().size.y
	# We want the current node to be centered roughly in the middle of the screen height.
	var target_y = (screen_h * 0.5) - BOARD_OFFSET.y - (current_y * CELL_SIZE_V.y)
	
	# Clamp scrolling so it doesn't reveal empty space outside the map bounds
	var max_y = 100.0 # Don't pull the top edge down too much
	var map_height = MAP_ROWS * CELL_SIZE_V.y
	var min_y = screen_h - BOARD_OFFSET.y - map_height - 100.0
	
	if min_y > max_y:
		# Screen is taller than the entire map. Center the map vertically.
		target_y = (screen_h - map_height) / 2.0 - BOARD_OFFSET.y
	else:
		target_y = clamp(target_y, min_y, max_y)
	
	target_y += 150
	var target_pos = Vector2(BOARD_OFFSET.x, target_y)
	
	if map_scroll_tween and map_scroll_tween.is_running():
		map_scroll_tween.kill()
	map_scroll_tween = create_tween()
	map_scroll_tween.tween_property(board_node, "position", target_pos, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _get_node_pos_map() -> Dictionary:
	var m = {}
	for f in range(map_manager.MAX_FLOORS):
		var y = MAP_ROWS - 2 - f
		for n in map_manager.map_data[f]:
			var x = int((MAP_COLS - map_manager.COLS) / 2.0) + n.col
			m[n.id] = Vector2(x, y)
	return m

func start_map_mode():
	state = GameState.MAP
	if graveyard_panel: graveyard_panel.hide()
	graveyard.clear()
	enemy_graveyard.clear()
	for lbl in get_tree().get_nodes_in_group("grid_labels"): lbl.hide()
	save_game_state()
	info_panel.hide()
	inv_panel.hide()
	shop_panel.hide()
	update_graveyard_ui()
	status_label.text = TranslationManager.translate("map_choose")
	board.clear()
	if map_manager.current_floor >= map_manager.MAX_FLOORS - 1:
			act += 1
			map_manager.generate_map()
			update_ui()
	
	clear_map_stuff()
	redraw_board_grid()
	
	for p in player_pawns:
		if is_instance_valid(p):
			p.hide()
			
	var node_pos_map = _get_node_pos_map()
	overlay.queue_redraw()
	for f in range(map_manager.MAX_FLOORS):
		for n in map_manager.map_data[f]:
			var p1 = node_pos_map[n.id] * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
			for cid in n.connections:
				var p2 = node_pos_map[cid] * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
				
	# Add lines from starting position if we are at start
	if map_manager.current_node_id == -1:
		var p_start = Vector2(2, 13) * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
		for n in map_manager.map_data[0]:
			var p2 = node_pos_map[n.id] * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
			var line = Line2D.new()
			line.add_point(p_start)
			line.add_point(p2)
			line.width = 5.0
			line.default_color = Color(1.0, 0.9, 0.5, 0.9)
			line.z_index = 0
			line.set_meta("is_map_stuff", true)
			board_node.add_child(line)
			
	for f in range(map_manager.MAX_FLOORS):
		for n in map_manager.map_data[f]:
			var p1 = node_pos_map[n.id] * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
			for cid in n.connections:
				var p2 = node_pos_map[cid] * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
				var line = Line2D.new()
				line.add_point(p1)
				line.add_point(p2)
				line.width = 5.0
				var active = map_manager.current_node_id == n.id or map_manager.can_visit(n.id)
				line.default_color = Color(1.0, 0.9, 0.5, 0.9) if active else Color(0.25, 0.25, 0.25, 0.6)
				line.z_index = -3
				line.set_meta("is_map_stuff", true)
				board_node.add_child(line)
	var tex_map = {
		map_manager.NodeType.BOSS: load("res://images/boss.svg"),
		map_manager.NodeType.TREASURE: load("res://images/treasury.png"),
		map_manager.NodeType.SHOP: load("res://images/shop.png"),
		map_manager.NodeType.COMBAT: load("res://images/enemy.png"),
		map_manager.NodeType.ELITE: load("res://images/enemy.png"),
		map_manager.NodeType.EVENT: load("res://images/event.png")
	}
	var type_labels = {
		map_manager.NodeType.COMBAT: TranslationManager.translate("battle"),
		map_manager.NodeType.ELITE: TranslationManager.translate("elite"),
		map_manager.NodeType.BOSS: TranslationManager.translate("boss"),
		map_manager.NodeType.SHOP: TranslationManager.translate("shop"),
		map_manager.NodeType.TREASURE: TranslationManager.translate("treasure"),
		map_manager.NodeType.EVENT: TranslationManager.translate("event")
	}
	for f in range(map_manager.MAX_FLOORS):
		for n in map_manager.map_data[f]:
			var gp = node_pos_map[n.id]
			var is_current = map_manager.current_node_id == n.id
			var can_visit = map_manager.can_visit(n.id)
			var spr = Sprite2D.new()
			spr.texture = tex_map.get(int(n.type), load("res://images/enemy.png"))
			spr.position = gp * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
			if spr.texture:
				var ts = spr.texture.get_size()
				if ts.x > 0 and ts.y > 0:
					var sf = min((CELL_SIZE_V.x * 0.62) / ts.x, (CELL_SIZE_V.y * 0.62) / ts.y)
					spr.scale = Vector2(sf, sf)
			spr.z_index = 2
			spr.modulate = Color(0.4, 1.0, 0.4) if is_current else (Color.WHITE if can_visit else Color(0.25, 0.25, 0.28))
			spr.set_meta("map_node", n)
			spr.set_meta("is_map_stuff", true)
			board_node.add_child(spr)
			var lbl = Label.new()
			lbl.text = type_labels.get(int(n.type), "?")
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.set("theme_override_font_sizes/font_size", 13)
			lbl.position = gp * CELL_SIZE_V + Vector2(0, CELL_SIZE_V.y * 0.67)
			lbl.custom_minimum_size = Vector2(CELL_SIZE_V.x, 20)
			if is_current: lbl.set("theme_override_colors/font_color", Color(0.4, 1.0, 0.4))
			elif can_visit: lbl.set("theme_override_colors/font_color", Color(1.0, 0.9, 0.5))
			else: lbl.set("theme_override_colors/font_color", Color(0.35, 0.35, 0.35))
			lbl.z_index = 3
			lbl.set_meta("is_map_stuff", true)
			lbl.set_meta("map_node_type", n.type)
			lbl.add_to_group("translateable")
			board_node.add_child(lbl)
	var k_tex = PieceData.get_piece_texture(PieceType.KING, true)
	if not map_king or not is_instance_valid(map_king):
		map_king = Sprite2D.new()
		map_king.texture = k_tex
		map_king.z_index = 5
		map_king.set_meta("is_map_stuff", true)
		board_node.add_child(map_king)
	else:
		map_king.texture = k_tex
	map_king.show()
	if k_tex:
		var ts = k_tex.get_size()
		if ts.x > 0:
			map_king.scale = Vector2.ONE * min((CELL_SIZE_V.x * 0.75) / ts.x, (CELL_SIZE_V.y * 0.75) / ts.y)
	var king_gp = Vector2(2, 13)
	if map_manager.current_node_id != -1 and node_pos_map.has(map_manager.current_node_id):
		king_gp = node_pos_map[map_manager.current_node_id]
	map_king.position = king_gp * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
	update_map_scroll()

func trigger_map_node(n):
	if not map_manager.can_visit(n.id): return
	map_manager.visit_node(n.id)
	var node_pos_map = _get_node_pos_map()
	overlay.queue_redraw()
	var target = node_pos_map[n.id] * CELL_SIZE_V + (CELL_SIZE_V / 2.0)
	var tween = create_tween()
	tween.tween_property(map_king, "position", target, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	update_map_scroll()
	tween.tween_callback(func(): start_map_node(n))

func start_map_node(node):
	level = node.floor + 1
	status_label.text = TranslationManager.translate("floor", [level])
	match int(node.type):
		map_manager.NodeType.SHOP:
			state = GameState.SHOP
			shop_rerolls_used = 0
			generate_shop()
			shop_panel.show()
			save_game_state()
		map_manager.NodeType.TREASURE:
			var bonus = randi_range(10, 20)
			coins += bonus
			vfx_manager.show_floating_text(Vector2(2, 4), "+%d Coins!" % bonus, Color.GOLD)
			update_ui()
			var t = create_tween()
			t.tween_interval(1.2)
			t.tween_callback(start_map_mode)
		map_manager.NodeType.EVENT:
			event_manager.trigger_random_event()
		_:
			start_next_level(node)
			redraw_board_grid()

func create_grid_labels():
	var columns = ["A", "B", "C", "D", "E"]
	for x in range(COLS):
		var lbl = Label.new()
		lbl.text = columns[x]
		lbl.add_to_group("grid_labels")
		lbl.set("theme_override_font_sizes/font_size", 30)
		lbl.set("theme_override_colors/font_color", Color(0.5, 0.5, 0.5))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.position = Vector2(x * CELL_SIZE_V.x, -50)
		lbl.custom_minimum_size = Vector2(CELL_SIZE_V.x, 40)
		board_node.add_child(lbl)
		
	for y in range(ROWS):
		var lbl = Label.new()
		lbl.add_to_group("grid_labels")
		lbl.text = str(ROWS - y)
		lbl.set("theme_override_font_sizes/font_size", 30)
		lbl.set("theme_override_colors/font_color", Color(0.5, 0.5, 0.5))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.position = Vector2(-65, y * CELL_SIZE_V.y)
		lbl.custom_minimum_size = Vector2(50, CELL_SIZE_V.y)
		board_node.add_child(lbl)

const LEVEL_UP_OPTIONS = {
	"hp": {"label": "+1 HP", "desc": "Increases max HP by 1\nand heals 1 HP."},
	"atk": {"label": "+1 ATK", "desc": "Increases attack\ndamage by 1."},
	"range": {"label": "+1 Range", "desc": "Increases attack\nrange by 1."},
}

const SPECIAL_UPGRADES = {
	PieceType.PAWN: {"label": "Promotion", "desc": "+1 ATK, +1 Range.\nGains queen-like power."},
	PieceType.KNIGHT: {"label": "Jumper", "desc": "+2 ATK. Critical\nhits deal double."},
	PieceType.BISHOP: {"label": "Narrow Escape", "desc": "Gains +1 Soul Heart.\nBlocks 1 damage."},
	PieceType.ROOK: {"label": "Fortress", "desc": "+2 max HP. Starts\nwith 1 Soul Heart."},
	PieceType.QUEEN: {"label": "Royal Blood", "desc": "Heals 1 HP on\nkill."},
	PieceType.KING: {"label": "Crown", "desc": "+1 Soul Heart.\n+1 ATK."},
	PieceType.BLOOD_QUEEN: {"label": "Bloodlust", "desc": "Attacks inflict\n1 Bleed stack."},
	PieceType.NIGHTMARE_PAWN: {"label": "Night Terror", "desc": "Nightmare attacks\ndeal +1 damage."},
	PieceType.TELEPAWN: {"label": "Wide Warp", "desc": "Teleports up to\n3 tiles away."},
	PieceType.SPIKED_PAWN: {"label": "Iron Spikes", "desc": "Retaliate for\n2 damage."},
	PieceType.CHECKER: {"label": "Double Stack", "desc": "Can stack 2\ncheckers deep."},
}

func show_level_up_screen():
	if is_levelup_active:
		return
	is_levelup_active = true
	
	var valid_pawns = []
	for p in player_pawns:
		if is_instance_valid(p):
			valid_pawns.append(p)
	if valid_pawns.is_empty():
		is_levelup_active = false
		start_map_mode()
		return
	var upgrade_piece = valid_pawns[randi() % valid_pawns.size()]
	
	var level_up = load("res://scripts/LevelUpScreen.gd").new()
	ui_layer.add_child(level_up)
	level_up.setup(upgrade_piece.piece_type, upgrade_piece.is_player, upgrade_piece.level)
	
	level_up.hp_upgraded.connect(func():
		apply_piece_upgrade(upgrade_piece, "hp")
		level_up.queue_free()
		is_levelup_active = false
		start_map_mode()
	)
	
	level_up.atk_upgraded.connect(func():
		apply_piece_upgrade(upgrade_piece, "atk")
		level_up.queue_free()
		is_levelup_active = false
		start_map_mode()
	)
	
	level_up.tree_exited.connect(func():
		is_levelup_active = false
	)

func apply_piece_upgrade(piece, upgrade_type):
	if not is_instance_valid(piece):
		return
	piece.level += 1
	match upgrade_type:
		"atk":
			piece.attack_damage += 1
			vfx_manager.show_floating_text(piece.grid_pos, "ATK+1!", Color.ORANGE)
		"hp":
			piece.max_hp += 1
			piece.current_hp = mini(piece.current_hp + 1, piece.max_hp)
			vfx_manager.show_floating_text(piece.grid_pos, "HP+1!", Color.GREEN)
		"special":
			apply_special_upgrade(piece)

func apply_special_upgrade(piece):
	var pt = piece.piece_type
	match pt:
		PieceType.PAWN:
			piece.attack_damage += 1
			piece.attack_range += 1
		PieceType.KNIGHT:
			piece.attack_damage += 2
		PieceType.BISHOP:
			piece.soul_hearts += 1
		PieceType.ROOK:
			piece.max_hp += 2
			piece.current_hp = mini(piece.current_hp + 2, piece.max_hp)
			piece.soul_hearts += 1
		PieceType.QUEEN:
			piece.set_meta("heal_on_kill", true)
		PieceType.KING:
			piece.soul_hearts += 1
			piece.attack_damage += 1
		PieceType.BLOOD_QUEEN:
			piece.set_meta("bleed_on_attack", true)
		PieceType.NIGHTMARE_PAWN:
			piece.set_meta("nightmare_bonus_dmg", 1)
		PieceType.TELEPAWN:
			piece.set_meta("warp_range", 3)
		PieceType.SPIKED_PAWN:
			piece.set_meta("spike_damage", 2)
		PieceType.CHECKER:
			piece.set_meta("max_checker_stack", 2)
		_:
			piece.attack_damage += 1
			piece.max_hp += 1
			piece.current_hp = mini(piece.current_hp + 1, piece.max_hp)
	vfx_manager.show_floating_text(piece.grid_pos, "SPECIAL UPGRADE!", Color.MAGENTA)

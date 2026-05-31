extends Node
class_name MapManager

enum NodeType { COMBAT, SHOP, TREASURE, BOSS, ELITE, EVENT }

const MAX_FLOORS = 12
const COLS = 5

var map_data = [] # Array of floors, each floor is an array of node dictionaries
var current_floor = -1
var current_node_id = -1
var selected_path = []

func generate_map():
	map_data.clear()
	current_floor = -1
	current_node_id = -1
	selected_path.clear()
	var next_node_id = 0
	
	var T0 = randi_range(2, 8)
	var T2 = randi_range(2, 8)
	var T4 = randi_range(2, 8)
	
	var valid_left_02 = []
	var valid_left_20 = []
	var valid_right_24 = []
	var valid_right_42 = []
	
	for f in range(2, 8):
		if (T0 < f and T2 <= f) or (T0 >= f and T2 > f): valid_left_02.append(f)
		if (T2 < f and T0 <= f) or (T2 >= f and T0 > f): valid_left_20.append(f)
		if (T2 < f and T4 <= f) or (T2 >= f and T4 > f): valid_right_24.append(f)
		if (T4 < f and T2 <= f) or (T4 >= f and T2 > f): valid_right_42.append(f)
		
	var left_connectors = []
	var left_goes_to = {} # f -> target_col
	
	# Pick 1 or 2 left connectors randomly from the valid sets
	var left_choices = []
	for f in valid_left_02: left_choices.append({"f": f, "target": 2})
	for f in valid_left_20: left_choices.append({"f": f, "target": 0})
	left_choices.shuffle()
	var left_count = randi_range(1, 2)
	for i in range(left_choices.size()):
		var choice = left_choices[i]
		var safe = true
		for ef in left_connectors:
			if abs(ef - choice.f) <= 1:
				safe = false
				break
		if safe:
			left_connectors.append(choice.f)
			left_goes_to[choice.f] = choice.target
			if left_connectors.size() >= left_count:
				break

	var right_connectors = []
	var right_goes_to = {}
	var right_choices = []
	for f in valid_right_24: right_choices.append({"f": f, "target": 4})
	for f in valid_right_42: right_choices.append({"f": f, "target": 2})
	right_choices.shuffle()
	var right_count = randi_range(1, 2)
	for i in range(right_choices.size()):
		var choice = right_choices[i]
		var safe = true
		for ef in right_connectors:
			if abs(ef - choice.f) <= 1:
				safe = false
				break
		if safe:
			right_connectors.append(choice.f)
			right_goes_to[choice.f] = choice.target
			if right_connectors.size() >= right_count:
				break

	for f in range(MAX_FLOORS):
		var floor_nodes = []
		var is_boss_floor = (f == MAX_FLOORS - 1)
		
		var chosen_cols = []
		if is_boss_floor:
			chosen_cols = [2]
		elif f == 10:
			chosen_cols = [1, 2, 3] # Merge to boss
		else:
			chosen_cols = [0, 2, 4]
			if f in left_connectors: chosen_cols.append(1)
			if f in right_connectors: chosen_cols.append(3)
			chosen_cols.sort()
		
		for c in chosen_cols:
			var n_type = NodeType.COMBAT
			if is_boss_floor:
				n_type = NodeType.BOSS
			elif (c == 0 and f == T0) or (c == 2 and f == T2) or (c == 4 and f == T4):
				n_type = NodeType.TREASURE
			elif f > 0 and f < 10:
				var is_shop_floor = (f == 3 or f == 6) and (c == 0 or c == 2)
				var is_event_floor = (f == 2 or f == 5 or f == 8) and (c == 2)
				
				if is_shop_floor:
					n_type = NodeType.SHOP
				elif is_event_floor:
					n_type = NodeType.EVENT
				else:
					var r = randf()
					if r < 0.15: n_type = NodeType.SHOP
					elif r < 0.35: n_type = NodeType.EVENT
					elif r < 0.60 and f > 2: n_type = NodeType.ELITE
			
			var node = {
				"id": next_node_id,
				"type": n_type,
				"floor": f,
				"col": c,
				"connections": []
			}
			if c == 1 and f in left_goes_to: node["goes_to"] = left_goes_to[f]
			if c == 3 and f in right_goes_to: node["goes_to"] = right_goes_to[f]
			
			floor_nodes.append(node)
			next_node_id += 1
		map_data.append(floor_nodes)
	
	# Connect nodes
	for f in range(MAX_FLOORS - 1):
		var current_floor_nodes = map_data[f]
		var next_floor_nodes = map_data[f + 1]
		
		if f == 9:
			for curr in current_floor_nodes:
				for nxt in next_floor_nodes:
					if curr.col == 0 and nxt.col == 1: curr.connections.append(nxt.id)
					if curr.col == 2 and nxt.col == 2: curr.connections.append(nxt.id)
					if curr.col == 4 and nxt.col == 3: curr.connections.append(nxt.id)
		elif f == 10:
			var boss_id = next_floor_nodes[0].id
			for curr in current_floor_nodes:
				curr.connections.append(boss_id)
		else:
			# 1. Connect straight lines
			for curr in current_floor_nodes:
				for nxt in next_floor_nodes:
					if curr.col == nxt.col:
						curr.connections.append(nxt.id)
			
			# 2. Connect incoming to connector nodes
			for nxt in next_floor_nodes:
				if nxt.col == 1 or nxt.col == 3:
					var target = nxt.get("goes_to")
					var origin = 0 if target == 2 and nxt.col == 1 else 2 if target == 0 and nxt.col == 1 else 2 if target == 4 and nxt.col == 3 else 4
					var n_orig = _get_node_by_col(current_floor_nodes, origin)
					if n_orig: n_orig.connections.append(nxt.id)
						
			# 3. Connect connector nodes to destination
			for curr in current_floor_nodes:
				if curr.col == 1 or curr.col == 3:
					var target_col = curr.get("goes_to")
					if target_col != null:
						var target_node = _get_node_by_col(next_floor_nodes, target_col)
						if target_node:
							curr.connections.append(target_node.id)

	# Post-process to prevent consecutive shops
	for f in range(MAX_FLOORS - 1):
		for curr in map_data[f]:
			if curr.type == NodeType.SHOP:
				for cid in curr.connections:
					for nxt in map_data[f+1]:
						if nxt.id == cid and nxt.type == NodeType.SHOP:
							nxt.type = NodeType.COMBAT

func _get_node_by_col(nodes_array, col):
	for n in nodes_array:
		if n.col == col: return n
	return null

func get_node_by_id(id):
	for f in map_data:
		for n in f:
			if n.id == id: return n
	return null

func get_available_next_nodes():
	if current_node_id == -1:
		return map_data[0]
	
	var curr = get_node_by_id(current_node_id)
	if not curr: return []
	
	var next_nodes = []
	for cid in curr.connections:
		var n = get_node_by_id(cid)
		if n: next_nodes.append(n)
	return next_nodes

func can_visit(node_id):
	if current_node_id == -1:
		for n in map_data[0]:
			if n.id == node_id: return true
		return false
	
	var curr = get_node_by_id(current_node_id)
	if not curr: return false
	return node_id in curr.connections

func visit_node(node_id):
	var n = get_node_by_id(node_id)
	if n:
		current_node_id = node_id
		current_floor = n.floor
		selected_path.append(node_id)
		return true
	return false

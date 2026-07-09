class_name SaveManager

static var settings_path = "user://settings.cfg"
static var save_dir = "user://saves"

static func init_system():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

static func save_settings(lang: String, fullscreen: bool, vol: float, resolution: int = 0):
	var config = ConfigFile.new()
	config.set_value("General", "language", lang)
	config.set_value("Graphics", "fullscreen", fullscreen)
	config.set_value("Audio", "volume", vol)
	config.set_value("Graphics", "resolution", resolution)
	config.save(settings_path)

static func load_settings() -> Dictionary:
	var config = ConfigFile.new()
	var err = config.load(settings_path)
	if err != OK:
		return {"language": "en", "fullscreen": false, "volume": 50.0, "gamma": 100.0, "contrast": 100.0, "saturation": 100.0, "time_speed": 10.0, "clouds": true, "shadows": true}
	return {
		"language": config.get_value("General", "language", "en"),
		"fullscreen": config.get_value("Graphics", "fullscreen", false),
		"volume": config.get_value("Audio", "volume", 50.0),
		"gamma": config.get_value("Graphics", "gamma", 100.0),
		"contrast": config.get_value("Graphics", "contrast", 100.0),
		"saturation": config.get_value("Graphics", "saturation", 100.0),
		"time_speed": config.get_value("Graphics", "time_speed", 10.0),
		"clouds": config.get_value("Graphics", "clouds", true),
		"shadows": config.get_value("Graphics", "shadows", true)
	}

static func save_visual_settings(gamma: float, contrast: float, sat: float, time_speed: float, clouds: bool, shadows: bool):
	var config = ConfigFile.new()
	config.load(settings_path)
	config.set_value("Graphics", "gamma", gamma)
	config.set_value("Graphics", "contrast", contrast)
	config.set_value("Graphics", "saturation", sat)
	config.set_value("Graphics", "time_speed", time_speed)
	config.set_value("Graphics", "clouds", clouds)
	config.set_value("Graphics", "shadows", shadows)
	config.save(settings_path)
	
	var main = Engine.get_main_loop().root.get_node_or_null("Main")
	if main and main.has_method("apply_visual_settings"):
		main.apply_visual_settings()

static func save_game(slot_id: int, data: Dictionary):
	init_system()
	var file = FileAccess.open(save_dir + "/save_" + str(slot_id) + ".json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

static func load_game(slot_id: int) -> Dictionary:
	var path = save_dir + "/save_" + str(slot_id) + ".json"
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var err = json.parse(file.get_as_text())
		if err == OK:
			return json.get_data()
	return {}

static func delete_game(slot_id: int):
	var path = save_dir + "/save_" + str(slot_id) + ".json"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
static func save_meta(data: Dictionary):
	init_system()
	var file = FileAccess.open(save_dir + "/meta_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

static func load_meta() -> Dictionary:
	var path = save_dir + "/meta_save.json"
	if not FileAccess.file_exists(path):
		return {"seen_pieces": [], "seen_items": []}
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var err = json.parse(file.get_as_text())
		if err == OK:
			var data = json.get_data()
			if not data.has("seen_pieces"): data["seen_pieces"] = []
			if not data.has("seen_items"): data["seen_items"] = []
			return data
	return {"seen_pieces": [], "seen_items": []}

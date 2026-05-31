extends CanvasLayer

var fps_label: Label
var nodes_label: Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 128
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_TOP_LEFT)
	vbox.position = Vector2(10, 10)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)
	
	fps_label = Label.new()
	fps_label.set("theme_override_colors/font_color", Color(0, 1, 0))
	fps_label.set("theme_override_colors/font_outline_color", Color.BLACK)
	fps_label.set("theme_override_constants/outline_size", 4)
	fps_label.set("theme_override_font_sizes/font_size", 24)
	vbox.add_child(fps_label)
	
	nodes_label = Label.new()
	nodes_label.set("theme_override_colors/font_color", Color(1, 1, 0))
	nodes_label.set("theme_override_colors/font_outline_color", Color.BLACK)
	nodes_label.set("theme_override_constants/outline_size", 4)
	nodes_label.set("theme_override_font_sizes/font_size", 24)
	vbox.add_child(nodes_label)

func _process(_delta):
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	nodes_label.text = "Nodes: %d" % get_tree().get_node_count()

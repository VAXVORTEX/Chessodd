extends Control
class_name MainMenu

signal start_run_pressed
signal collection_pressed

@onready var title = Label.new()
@onready var vbox = VBoxContainer.new()
@onready var start_btn = Button.new()
@onready var collection_btn = Button.new()
@onready var quit_btn = Button.new()

func _ready():
	setup_ui()

func setup_ui():
	# Layout setup
	title.text = "Isaac x Mewgenics x Chess"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set("theme_override_font_sizes/font_size", 48)
	
	start_btn.text = "Start Run"
	collection_btn.text = "Collection / Bestiary"
	quit_btn.text = "Quit Game"
	
	start_btn.pressed.connect(_on_start_pressed)
	collection_btn.pressed.connect(_on_collection_pressed)
	quit_btn.pressed.connect(func(): get_tree().quit())
	
	vbox.add_child(start_btn)
	vbox.add_child(collection_btn)
	vbox.add_child(quit_btn)
	
	vbox.set_anchors_preset(PRESET_CENTER)
	title.set_anchors_preset(PRESET_CENTER_TOP)
	title.position.y += 100
	
	add_child(title)
	add_child(vbox)

func _on_start_pressed():
	start_run_pressed.emit()
	# Transition logic to Main.tscn
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_collection_pressed():
	collection_pressed.emit()
	# Transition to Bestiary

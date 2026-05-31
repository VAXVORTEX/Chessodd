extends Node

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	var img = get_viewport().get_texture().get_image()
	img.save_png("res://screenshot.png")
	get_tree().quit()

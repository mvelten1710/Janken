extends Control

func _on_singleplayer_button_pressed():
	var singleplayer_menu = load("res://scenes/singleplayer_menu.tscn")
	get_tree().change_scene_to_packed(singleplayer_menu)


func _on_exit_button_pressed():
	get_tree().quit()

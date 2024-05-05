extends Control

@onready var team_option_button = $PanelContainer/Panel/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/TeamOptionsButton
@onready var team_member_count_scroll = $PanelContainer/Panel/VBoxContainer/CenterContainer/VBoxContainer/TeamMemberCountScroll
@onready var team_member_count_line_edit = $PanelContainer/Panel/VBoxContainer/CenterContainer/VBoxContainer/TeamMemberCountLineEdit

var team_options: Dictionary = {
	Globals.TEAMS.ROCK : "Rock",
	Globals.TEAMS.PAPER : "Paper",
	Globals.TEAMS.SCISSOR : "Scissor"
}


func _ready() -> void:
	for i in team_options.size():
		team_option_button.add_item(team_options[i])


func _on_back_button_pressed() -> void:
	var main_menu = load("res://scenes/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu)


func _on_start_button_pressed() -> void:
	var game_world: PackedScene = load("res://scenes/game_world.tscn")
	var world: Node = game_world.instantiate()
	get_tree().root.add_child(world)
	world.initialize_team_members(
		{
		"team_size" : int(team_member_count_line_edit.text)
		}
	)


func _on_team_member_count_line_edit_text_submitted(new_text):
	var new_value = int(new_text)
	if new_value != 0 and new_value > 0:
		if new_value <= 200:
			team_member_count_scroll.set_value_no_signal(new_value)
		else:
			team_member_count_line_edit.text = "200"
			team_member_count_scroll.set_value_no_signal(200)


func _on_team_member_count_scroll_value_changed(value):
	team_member_count_line_edit.text = str(value)

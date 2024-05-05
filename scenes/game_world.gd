extends Node

@onready var level: Node2D = $Level
@onready var loading_screen: Control = $LoadingScreen

var rng = RandomNumberGenerator.new()
var members: Array[Node2D] = []
var total_members: int = 0
var team_members: Dictionary = {
	0 : 0,
	1 : 0,
	2 : 0
}

func _ready() -> void:
	SignalBus.team_changed.connect(_on_team_changed)
	get_tree().root.get_node("/root/SingleplayerMenu").queue_free()
	loading_screen.show()
	get_tree().paused = true


func initialize_team_members(instructions: Dictionary) -> void:
	var team_size = instructions["team_size"]
	total_members = team_size * 3
	var member_scene: PackedScene = preload("res://scenes/team_member.tscn")
	for i in 3:
		for j in team_size:
			var member = member_scene.instantiate()
			var rng_pos: Vector2 = Vector2(rng.randf_range(20, 1900), rng.randf_range(20, 1060))
			# Get the first and only child of Level (the actual level)
			# Then get the first child of the actual level (the members node, holding all the members)
			# And lastly add the newly created child to the members
			level.get_child(0).get_child(0).add_child(member)
			member.load_member_sprite(i)
			member.position = rng_pos
	_set_starting_team_numbers()
	level.show()
	loading_screen.hide()


func _set_starting_team_numbers() -> void:
	level.get_child(0).get_child(0).get_children().any(
		func(node: Node):
			team_members[node.current_team] = team_members[node.current_team] + 1
	)
	

func _on_team_changed(node: Node2D, prev_team: Globals.TEAMS) -> void:
	team_members[prev_team] = team_members[prev_team] - 1
	team_members[node.current_team] = team_members[node.current_team] + 1
	for i in team_members.size():
		if team_members[i] == total_members:
			get_tree().paused = true

extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var members: Node2D = $"../../Members"

var rng = RandomNumberGenerator.new()

# Speed Range Test
const MAX_SPEED: float = 35.0
const MIN_SPEED: float = 30.5

const SPEED: float = 30.5

var current_team: Globals.TEAMS
var current_target: Node2D

func _ready() -> void:
	SignalBus.team_changed.connect(_on_team_changed)


func load_member_sprite(value: Globals.TEAMS) -> void:
	current_team = value
	_set_collision_layer(current_team)
	match value:
		Globals.TEAMS.ROCK: # Team Rock
			sprite.set_texture(load("res://images/1FAA8_color.png"))
		Globals.TEAMS.PAPER: # Team Paper
			sprite.set_texture(load("res://images/1F4C4_color.png"))
		Globals.TEAMS.SCISSOR: # Team Scissor
			sprite.set_texture(load("res://images/2702_color.png"))


func _physics_process(delta: float) -> void:
	# Get a new target if there is currently none or it changed in the process
	if current_target == null:
		current_target = _get_next_target(current_team)
	# Calculate velocity
	var vel: Vector2
	if current_target.position == Vector2(0, 0):
		vel = Vector2(0, 0)
	else:
		vel = (current_target.position - position).normalized() * rng.randf_range(MIN_SPEED, MAX_SPEED) * delta
	
	move_and_collide(vel)


# Gets all members in the game and filters to only get the enemy nodes
# Lastly with and array of possible targets it searches for the nearest on
# with the function _find_clostest_node(...)
func _get_next_target(current_team: Globals.TEAMS) -> Node2D:
	var new_target: Node2D = Node2D.new()
	var possible_targets: Array[Node2D]
	possible_targets.assign(members.get_children().filter(_only_enemies))
	return _find_random_node(possible_targets) #_find_closest_node(possible_targets)


# With the given array the function searches for the nearstest node to the current position of
# this member
# If there is no enemies left, they should stand still
func _find_closest_node(targets: Array[Node2D]) -> Node2D:
	var current_pos: Vector2 = get_position()
	if targets.size() > 0:
		var current_closest: Node2D = targets[0]
		for target in targets:
			if current_pos.distance_to(target.position) < current_pos.distance_to(current_closest.position):
				current_closest = target
		return current_closest
	else:
		var empty = Node2D.new()
		empty.position = Vector2(0, 0)
		return empty


func _find_random_node(targets: Array[Node2D]) -> Node2D:
	if targets.is_empty():
		var empty = Node2D.new()
		empty.position = Vector2(0, 0)
		return empty
	else:
		return targets.pick_random()
	


func _only_enemies(node: Node2D) -> bool:
	var enemy_team: Globals.TEAMS = current_team - 1
	if enemy_team == -1:
		enemy_team = 2
	return node.current_team == enemy_team


func _clamp_to_team(team: int) -> int:
	if team > 2:
		return 0
	else:
		return team


func _on_team_changed(node: Node2D, prev_team: Globals.TEAMS) -> void:
	if node != self and current_target == node:
		current_target = null


func _set_collision_layer(team: Globals.TEAMS) -> void:
	match team:
		Globals.TEAMS.ROCK:
			collision_layer = 0x1
			collision_mask = 0x6
		Globals.TEAMS.PAPER:
			collision_layer = 0x2
			collision_mask = 0x5
		Globals.TEAMS.SCISSOR:
			collision_layer = 0x4
			collision_mask = 0x3


func _on_body_entered(body: Node2D) -> void:
	if  body is RigidBody2D and body.current_team == _clamp_to_team(current_team + 1):
		var prev_team: Globals.TEAMS = current_team
		current_team = body.current_team
		load_member_sprite(current_team)
		current_target = null
		SignalBus.team_changed.emit(self, prev_team)

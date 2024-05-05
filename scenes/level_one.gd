extends Node2D

@onready var countdown_label: Label = $CountdownLabel
@onready var countdown_timer: Timer = $CountdownTimer
@onready var members: Node2D = $Members

func _ready() -> void:
	countdown_timer.start()

func _process(delta: float) -> void:
	if !countdown_timer.is_stopped():
		countdown_label.text = str(int(ceil(countdown_timer.time_left)))

func _on_countdown_timer_timeout():
	countdown_label.hide()
	get_tree().paused = false

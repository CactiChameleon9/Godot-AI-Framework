extends Node2D

@export var x_radius: float = 1152/2 * .9

@export var spike: PackedScene

@export var seed: int = 00274824

@onready var rand: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rand.seed = seed
	rand.state = 10

func _on_timer_timeout():
	var spike_node = spike.instantiate()
	add_child(spike_node)
	spike_node.position.x = rand.randf_range(-x_radius, x_radius)


func _kill_all(_best):
	rand.seed
	rand.state = 10
	for child in get_children():
		if child != $SpawnTimer:
			child.queue_free()

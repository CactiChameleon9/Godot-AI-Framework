extends Node2D

var time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(2).timeout
	print("network init started: ", time)
	var hello: Network = Network.new()
	print("network init finished: ", time)
	
	print("network compute started: ", time)
	hello.compute_network()
	print("network compute finished: ", time)

func _process(delta):
	time += delta

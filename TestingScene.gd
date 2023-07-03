extends Node2D


func _ready():
	
	var time_before = Time.get_ticks_usec()
	
	var hello: Network = Network.new(9, range(50, 59))
	hello.randomise_weights(1, 0)
	hello.set_inputs(range(5, 55))
	hello.compute_network()
	print(hello.get_outputs())
	
	print("time taken: ", Time.get_ticks_usec() - time_before)

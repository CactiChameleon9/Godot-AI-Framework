class_name Network

var layers: int
var nodes_per_layer: Array


var network


func _init(num_layers: int = 4, nodes_array: Array = [10, 20, 8, 1]):
	# Set the values from the constructor
	layers = num_layers
	nodes_per_layer = nodes_array
	
	# An extra zero should be added to indicate there are no
	# connections/weights from the output layer
	if layers == len(nodes_per_layer):
		nodes_per_layer.append(0)
	
	# Make sure the values given in the contructor have the correct number of
	# corresponding elements
	assert(layers + 1 == len(nodes_per_layer))
	
	# Generate the network
	_generate_network()


func _generate_network(fill = 0.0): #TODO Optimise
	# Initalise the empty array
	network = []
	
	# The first item in the network is the appropriate layers
	## network[0] is the input layer
	## network[-1] is the output layer
	network.resize(layers)
	
	# Each layer needs the correct number of nodes
	## network[x][0+] are the nodes for the current layer (x)
	for layer in layers:
		network[layer] = []
		network[layer].resize(nodes_per_layer[layer])
	
	# Each node needs to have: 
	## network[x][x][0] is the current value in that node
	## network[x][x][1] is the bias for that node
	## network[x][x][2+] are the weights connecting to the next layer (x+1)
	for layer in layers:
		for node in nodes_per_layer[layer]:
			network[layer][node] = []
			network[layer][node].resize(nodes_per_layer[layer + 1] + 2)
			network[layer][node].fill(fill)


func set_inputs(inputs: Array):
	assert(len(inputs) == nodes_per_layer[0])
	
	for input_i in len(inputs):
		network[0][input_i][0] = inputs[input_i]


func get_outputs() -> Array:
	var outputs = []
	for output_i in nodes_per_layer[-2]:
		outputs.append(network[-1][output_i][0])
	return outputs


func compute_network():
	# NL = Next Layer
	# CL = Current Layer
	#
	# For each layer of the network:
	## 1) NL node's values are reset to 0
	##
	## 2) For each node in the CL, the value times a weight is added
	## to the NL node's value of that respective weight
	##
	## 3) The bias for that NL node should then be added to it's value
	##
	## 4) A sigmoid function is to limit the NL node's value to between 0 and 1
	#
	# *(3) and (4) can be done on the CL before (2) (CL instead of NL)
	
	for layer in layers:
		
		# (1) except for the output layer (next layer does not exist)
		if layer + 1 < layers:
			for node in network[layer + 1]:
				node[0] = 0.0
		
		# (3), (4), (2)
		for node in network[layer]:
			node[0] += node[1]
			node[0] = sigmoid(node[0])
			
			for weight_i in nodes_per_layer[layer + 1]:
				network[layer + 1][weight_i][0] += node[weight_i + 2] * node[0]


func randomise_weights(rand_range: float = 1, preserve_percentage: float = 0.2):
	for layer in network:
		for node in layer:
			for weight in range(2, len(node)):
				if randf() < preserve_percentage: continue
				node[weight] = randf_range(-rand_range/2, rand_range/2)


func sigmoid(num: float):
	# https://en.wikipedia.org/wiki/Sigmoid_function
	# Using arctan
	return 2/PI * atan(num * PI/2)

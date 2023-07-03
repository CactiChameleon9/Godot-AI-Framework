class_name Network

var layers: int = 4
var nodes_per_layer: Array = [10, 20, 8, 1, 0]


var network


func _init():
	_generate_network()


func _generate_network(fill = 0): #TODO Optimise
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
				node[0] = 0
		
		# (3), (4), (2)
		for node in network[layer]:
			node[0] += node[1]
			node[0] = sigmoid(node[0])
			
			for weight_i in nodes_per_layer[layer + 1]:
				network[layer + 1][weight_i][0] += node[weight_i + 2] * node[0]


func sigmoid(num: float):
	# https://en.wikipedia.org/wiki/Sigmoid_function
	# Using arctan
	return atan(num)

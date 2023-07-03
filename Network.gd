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

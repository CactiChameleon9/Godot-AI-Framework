extends Network
class_name MergeableNetwork

func _init(neural_network1: Network, neural_network2: Network):
	assert(neural_network1.layers == neural_network2.layers)
	assert(neural_network1.nodes_per_layer == neural_network2.nodes_per_layer)
	
	super(neural_network1.layers, neural_network1.nodes_per_layer)
	
	var network1 = neural_network1.network
	var network2 = neural_network2.network
	
	for layer in layers:
		for node in nodes_per_layer[layer]:
			for weight in range(2, len(network[layer][node])):
				network[layer][node][weight] = (network1[layer][node][weight] +
												network2[layer][node][weight])/2

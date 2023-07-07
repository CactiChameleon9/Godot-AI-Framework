extends Node
class_name GeneticManager

# Signal for when a generation has finished - best evaluation emitted also
signal generation_finished(float)

# A subclass of CallableFunc that has its run() function overridden
# to calculate how well a variation performed (objective)
@export_file("*.gd") var objective_function_file: String
@export var larger_is_better: bool = true
@export var network_run_frame_frequency: int = 1

##########################################
@export_group("Node Settings")
########################################
# Signal emitted, with the argument of itself, by a variation when it
# has finished, and so needs evaluating
@export var node_finished_signal: String = "finished"

@export var node_scene: PackedScene
@export var node_input_properties: Array[String] = ["speed", "rotation:y", "wall_distance"]
@export var node_output_properties: Array[String] = ["move_direction:x", "move_direction:y"]

@export var node_scene_tree_root: NodePath = "./"

##########################################
@export_group("Network Properties")
########################################
@export var network_layers: Array[int] = [3, 20, 10, 2]

##########################################
@export_group("Genetic Properties")
########################################
@export_range(0, 200, 1, "or_greater") var population_number: int = 50

@export_range(0, 1) var preserve_top_percent: float = 0.1
@export_range(0, 1) var merge_mutate_percent: float = 0.6
@export_range(0, 1) var generate_new_percent: float = 0.3

@export_range(0, 1) var discard_worst_percent: float = 0.6
@export_range(0.1, 20, 0.1, "or_greater") var mutation_strength: float = 5
@export_range(0, 1 ) var mutation_percent: float = 0.4

var _objective_function: ObjectiveCallableFunc

var _frame_count: int = 0

var _nodes: Array[Node] = []

# Will contain [Network, Evaluation(float)]
var _networks: Array[Array] = []

var _evaluations_count: int = 0


func _ready():
	_objective_function = load(objective_function_file).new()
	_nodes.resize(population_number)
	
	_generate_nodes()
	_generate_fill_networks()


func _physics_process(delta):
	
	# Increase the frame_count
	_frame_count += 1
	_frame_count %= network_run_frame_frequency
	
	# Split the networks to compute based on _frame_count and frequency
	var min_node_i: int = (population_number * 
							_frame_count/network_run_frame_frequency)
	var max_node_i: int = (population_number * 
							(_frame_count + 1)/network_run_frame_frequency)
	
	# Run that respective group of node's network
	for i in range(min_node_i, max_node_i):
		
		# Don't run if node does not exist
		if not is_instance_valid(_nodes[i]):
			continue
		
		# Get the input data
		var input_data: Array[float] = []
		for property in node_input_properties:
			input_data.append(_nodes[i].get_indexed(property))
		
		# Enter the input data, compute through the network and get output
		_networks[i][0].set_inputs(input_data)
		_networks[i][0].compute_network()
		var output_data: Array[float] = _networks[i][0].get_outputs()
		
		# Set the output data
		for j in len(node_output_properties):
			_nodes[i].set_indexed(node_output_properties[j], output_data[j])


func _generate_nodes():
	var node_root: Node = get_node(node_scene_tree_root)
	# Make the correct number of nodes
	for i in population_number:
		# Instanciate the node and add it to the scene tree
		var node = node_scene.instantiate()
		_nodes[i] = node
		node_root.call_deferred("add_child", node)
		
		# Connect up the node_finished signal to the evaluation function
		node.connect(node_finished_signal, _evaluate_node)


func _generate_fill_networks():
	for _i in population_number - len(_networks):
		var new_network: Network = Network.new(network_layers.size(), network_layers.duplicate())
		new_network.randomise_weights(mutation_strength, 0)
		_networks.append([new_network, 0])


func _evaluate_node(node: Node):
	var evaluation: float = _objective_function.run(node)
	var node_index: int = _nodes.find(node)
	_networks[node_index][1] = evaluation
	_evaluations_count += 1
	
	# All ndoes finished
	if _evaluations_count == population_number:
		_generate_new_generation()
		_evaluations_count = 0


func _generate_new_generation():
	# Re-Scale the ratios of preserve/merge/generate so they total 1
	var total_percent: float = (preserve_top_percent + merge_mutate_percent
								+ generate_new_percent)
	preserve_top_percent /= total_percent
	merge_mutate_percent /= total_percent
	generate_new_percent /= total_percent
	
	# Find the top performing networks to keep (sort by evaluation)
	_networks.sort_custom(func(a, b):
		return a[1] > b[1] if larger_is_better else a[1] < b[1])
	
	# Emit the best evaluation + finished
	generation_finished.emit(_networks[0][1])
	
	# Remove the bottom percent
	for _i in int(population_number * discard_worst_percent):
		_networks.pop_back()
	
	var new_networks: Array[Array] = []
	
	# Append the top percent (unmodified)
	new_networks.append_array(
		_networks.slice(0, int(preserve_top_percent * population_number)))
	
	# Append the correct number of merge+mutated networks
	for _i in merge_mutate_percent * population_number:
		var network1 = _networks.pick_random()[0]
		var network2 = _networks.pick_random()[0]
		var new_network: Network = MergeableNetwork.new(network1, network2)
		new_network.randomise_weights(1, 1 - mutation_percent)
		new_networks.append([new_network, 0])
	
	_networks = new_networks
	
	# Append the rest of the networks
	_generate_fill_networks()
	
	# Generate new nodes because they are all finished
	_generate_nodes()

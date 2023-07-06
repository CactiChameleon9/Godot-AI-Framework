extends Node
class_name GeneticManager

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

@export_subgroup("Percents must total 1:")
@export_placeholder("") var __ = "" #Empty variable so that subgroup shows
@export_subgroup("")

@export_range(0, 1) var preserve_top_percent: float = 0.1
@export_range(0, 1) var merge_mutate_percent: float = 0.8
@export_range(0, 1) var generate_new_percent: float = 0.1

@export_range(0, 1) var discard_worst_percent: float = 0.6


var _objective_function: ObjectiveCallableFunc

var _nodes: Array[Node] = []

# Will contain [Network, Evaluation(float)]
var _networks: Array[Array] = []

var _evaluations_count: int = 0


func _ready():
	_objective_function = load(objective_function_file).new()
	_nodes.resize(population_number)
	
	_generate_nodes()
	_generate_fill_networks()


func _generate_nodes():
	# Make the correct number of nodes
	for i in population_number:
		# Instanciate the node and add it to the scene tree
		var node = node_scene.instantiate()
		_nodes[i] = node
		get_node(node_scene_tree_root).add_child(node)
		
		# Connect up the node_finished signal to the evaluation function
		node.connect(node_finished_signal, _evaluate_node)


func _generate_fill_networks():
	for _i in population_number - len(_networks):
		var new_network: Network = Network.new(network_layers.size(), network_layers.duplicate())
		new_network.randomise_weights(1, 0)
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
		return a[1] < b[1] if larger_is_better else a[1] > b[1])
	
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
		new_network.randomise_weights(1, 0.6)
		new_networks.append([new_network, 0])
	
	_networks = new_networks
	
	# Append the rest of the networks
	_generate_fill_networks()
	
	# Generate new nodes because they are all finished
	_generate_nodes()

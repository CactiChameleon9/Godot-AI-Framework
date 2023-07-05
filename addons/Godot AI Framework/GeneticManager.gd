extends Node
class_name GeneticManager

# A subclass of CallableFunc that has its run() function overridden
# to calculate how well a variation performed (objective)
@export_file("*.gd") var objective_function_file: String
@export var larger_is_better: bool = true

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

var _objective_function: ObjectiveCallableFunc

var _nodes: Array[Node] = []
var _networks: Array[Network] = []
var _node_evaluations: Array[float] = []

func _ready():
	_objective_function = load(objective_function_file).new()
	
	_nodes.resize(population_number)
	_networks.resize(population_number)
	_node_evaluations.resize(population_number)
	
	# Make the correct number of nodes
	for i in population_number:
		
		# Instanciate the node and add it to the scene tree
		var node = node_scene.instantiate()
		_nodes[i] = node
		get_node(node_scene_tree_root).add_child(node)
		
		# Connect up the node_finished signal to the evaluation function
		node.connect(node_finished_signal, _evaluate_node)
		
		# Make a network for each node
		_networks[i] = Network.new(network_layers.size(), network_layers)
		_networks[i].randomise_weights(1, 0)
		
		# Set the evaluation to a very small(or big) number
		_node_evaluations[i] = -INF if larger_is_better else INF


func _evaluate_node(node: Node):
	var evaluation: float = _objective_function.run(node)
	var node_index: int = _nodes.find(node)
	_node_evaluations[node_index] = evaluation



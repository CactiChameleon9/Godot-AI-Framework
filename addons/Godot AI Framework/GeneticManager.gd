extends Node
class_name GeneticManager

# A subclass of CallableFunc that has its run() function overridden
# to calculate how well a variation performed (objective)
@export var objective_function: CallableFunc

@export_group("Node Settings")
# Signal emitted, with the argument of itself, by a variation when it
# has finished, and so needs evaluating
@export var node_finished_signal: String = "finished"

@export var node_scene: PackedScene
@export var node_input_properties: Array[String] = ["velocity", "rotation", "wall_distance"]
@export var node_output_properties: Array[String] = ["velocity", "angular_velocity"]

@export var nodes_tree_root: NodePath = "./"

@export_group("Network Properties")
@export var network_layers: Array[int] = [3, 20, 10, 2]

@export_group("Genetic Properties")
@export_range(0, 1) var preserve_top_percent: float = 0.1
@export_range(0, 1) var merge_mutate_percent: float = 0.8
@export_range(0, 1) var generate_new_percent: float = 0.1
@export_range(0, 200, 1, "or_greater") var population_number: int = 50

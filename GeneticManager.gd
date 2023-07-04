extends Node
class_name GeneticManager

@export var objective_function: CallableFunc = null

@export_group("Network Properties")
@export var network_layers: Array[int] = [5, 20, 10, 4]

@export_group("Genetic Properties")
@export_range(0, 1) var preserve_top_percent: float = 0.1
@export_range(0, 1) var merge_mutate_percent: float = 0.8
@export_range(0, 1) var generate_new_percent: float = 0.1


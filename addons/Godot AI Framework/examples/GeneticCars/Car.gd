extends RigidBody2D

signal finished(Node)


var front_wheel_velocity: float = 0
var front_wheel_throttle: float = 0

var back_wheel_velocity: float = 0
var back_wheel_throttle: float = 0

var max_acceleration: float = 200.0


func _physics_process(delta):
	front_wheel_velocity += max_acceleration * front_wheel_throttle * delta
	back_wheel_velocity += max_acceleration * back_wheel_throttle * delta
	
	$FrontWheel.rotation_degrees += front_wheel_velocity * delta
	$BackWheel.rotation_degrees += front_wheel_velocity * delta

func _on_alive_timer_timeout():
	emit_signal("finished", self)
	queue_free()

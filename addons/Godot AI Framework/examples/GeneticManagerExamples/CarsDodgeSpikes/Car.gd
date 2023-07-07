extends RigidBody2D

signal finished(Node)

@export var human_controlled: bool = false

var wheel_throttle: float = 0

var max_acceleration: float = 100.0

var raycast1: float = 0
var raycast2: float = 0
var raycast3: float = 0
var raycast4: float = 0
var raycast5: float = 0
var raycast6: float = 0
var raycast7: float = 0
var raycast8: float = 0
var raycast9: float = 0
var raycast10: float = 0
var raycast11: float = 0
var raycast12: float = 0

func _ready():
	$BodyTexture.color = Color(randf(), randf(), randf(), 0.7)


func _physics_process(delta):
	
	if human_controlled:
		$AliveTimer.stop()
		wheel_throttle = Input.get_action_strength("ui_right")
		wheel_throttle -= Input.get_action_strength("ui_left")
	
	$FrontWheel.angular_velocity += max_acceleration * wheel_throttle * delta
	$BackWheel.angular_velocity += max_acceleration * wheel_throttle * delta
	
	raycast1 = 1.0 if $RayCasters/RayCast1.is_colliding() else 0.0
	raycast2 = 1.0 if $RayCasters/RayCast2.is_colliding() else 0.0
	raycast3 = 1.0 if $RayCasters/RayCast3.is_colliding() else 0.0
	raycast4 = 1.0 if $RayCasters/RayCast4.is_colliding() else 0.0
	raycast5 = 1.0 if $RayCasters/RayCast5.is_colliding() else 0.0
	raycast6 = 1.0 if $RayCasters/RayCast6.is_colliding() else 0.0
	raycast7 = 1.0 if $RayCasters/RayCast7.is_colliding() else 0.0
	raycast8 = 1.0 if $RayCasters/RayCast8.is_colliding() else 0.0
	raycast9 = 1.0 if $RayCasters/RayCast9.is_colliding() else 0.0
	raycast10 = 1.0 if $RayCasters/RayCast10.is_colliding() else 0.0
	raycast11 = 1.0 if $RayCasters/RayCast11.is_colliding() else 0.0
	raycast12 = 1.0 if $RayCasters/RayCast12.is_colliding() else 0.0

func die():
	emit_signal("finished", self)
	queue_free()


func get_time_left():
	return $AliveTimer.time_left

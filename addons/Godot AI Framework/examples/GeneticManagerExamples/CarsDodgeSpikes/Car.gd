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
	
	for i in range(1, 13):
		var caster: RayCast2D = get_node("RayCasters/RayCast%s" % i)
		set("raycast%s" % i, 1.0 if caster.is_colliding() else 0.0)


func die():
	emit_signal("finished", self)
	queue_free()


func get_time_left():
	return $AliveTimer.time_left

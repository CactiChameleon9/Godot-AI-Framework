extends Node2D


func _ready():
	var data = []
	for i in range(-9999999, 9999999):
		data.append(i/9263.1)
	
	var precalculated_sigmoid = []
	for i in range(-5000, 5000):
		precalculated_sigmoid.append(atan(i/1000.0))
	
	var time_before
	
	var atan_times = []
	var algebraic_times = []
	var precalculated_times = []
	print("hello")
	
	for _j in 20:
		time_before = Time.get_ticks_usec()
		for i in data:
			atan(i)
		
		atan_times.append(Time.get_ticks_usec() - time_before)
		
		
		time_before = Time.get_ticks_usec()
		for i in data:
			i / sqrt(1 + i**2)
		
		algebraic_times.append(Time.get_ticks_usec() - time_before)
		
		
		time_before = Time.get_ticks_usec()
		for i in data:
			precalculated_sigmoid[int(i)]
		
		precalculated_times.append(Time.get_ticks_usec() - time_before)
	
	print(sum(atan_times)/20)
	print(sum(algebraic_times)/20)
	print(sum(precalculated_times)/20)


func sum(array: Array) -> float:
	var total = 0.0
	for i in array:
		total += i
	return total

extends Spatial

signal mouse_clicked(collider_id)

var position = Vector3(0.0, 0.0, 0.0)
var alpha = 0
var total_y = 0
var angle
var t = 0
var previous_t = t
var y = 0
var previous_y = y
var a = 0
var previous_a = a
var mouse_hover

func _ready():
	var chip = $Stack2/Chip3
	print (chip.global_transform.origin)
	print(chip.global_transform.basis)
	$UI.connect('start_game', $Board, 'on_start_game')
	$Board.connect('game_over', self, 'on_game_over')

func on_game_over(winner_id):
	print('game over! winner: ', winner_id)

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		alpha += 10.0
		if t <= PI - 0.05:
			t += 0.05
	elif Input.is_action_pressed("ui_right"):
		alpha -= 10.0
		if t >= 0.05:
			t -= 0.05
	elif Input.is_action_pressed("ui_up"):
		position.y += 1.0
	elif Input.is_action_pressed("ui_down"):
		position.y -= 1.0
	#update_chip_position()
	update_chip_position2()
	#update_chip_position3()

func update_chip_position3():
	var chip = $Stack2/Chip3
	y = t
	if y != previous_y:
		print('t ', t)
		print('y ', y, ' ', y - previous_y)
		var a = t
		chip.rotate(Vector3(0.0, 0.0, 1.0), -(a - previous_a))
		chip.translate(Vector3(0.0, y - previous_y, 0.0))
		previous_a = a
		previous_t = t
		previous_y = y

func move_chip(t):
	return 1.0 - pow(t - 1.0, 2.0)

func rotate_chip(t):
	return (t / 2.0) * PI

func update_chip_position2():
	var chip = $Stack2/Chip3
	y = move_chip(t)
	if y != previous_y:
		print('t ', t)
		print('y ', y, ' ', y - previous_y)
		var a = rotate_chip(t)
		chip.rotate(Vector3(0.0, 0.0, 1.0), -(a - previous_a))
		chip.global_translate(Vector3(t - previous_t, y - previous_y, 0.0))
		previous_a = a
		previous_t = t
		previous_y = y
	

func update_chip_position():
	var chip = $Stack2/Chip3
	#var t = chip.get_transform()
	if alpha != 0:
		var b = deg2rad(alpha)
		chip.rotate(Vector3(0.0, 0.0, 1.0), b)
		angle = chip.get_rotation().z
		var a = 0.5
		var h = 0.125
		if angle < 0: 
			var y = a * sin(angle) - 2.0 * pow(sin(angle / 2.0), 2.0) * h
			print(angle, ' ', total_y, ' ', y)
			chip.global_translate(Vector3(0.0, total_y-y, 0.0))
			total_y = y
		else:
			var y = a * sin(angle) - 2.0 * pow(sin(angle / 2.0), 2.0) * h
			print(angle, ' ', total_y, ' ', y)
			chip.global_translate(Vector3(0.0, y-total_y, 0.0))
			total_y = y
	chip.translate(position)
	position.y = 0
	alpha = 0

var RAY_LENGTH = 50
func get_object_under_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	# casting rays in the form of (origin, normal)
	var ray_from = $Camera.project_ray_origin(mouse_pos) # Vector2
	var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * RAY_LENGTH # Vector2
	# Godot stores all the low level collision and physics information in a space
	# Accesing space:
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	# If the ray didn’t hit anything, the dictionary will be empty. 
	# If it did hit something, it will contain collision information
	return selection

func _physics_process(delta):
	var selection = get_object_under_mouse()
	if selection:
		mouse_hover = selection.collider_id
		#print(selection.collider_id)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && self.mouse_hover:
			#emit_signal('clicked', self.mouse_hover)
			$Board.select_chip(self.mouse_hover)

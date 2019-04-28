extends Spatial

signal moved(n_triggered, n_captured, captured_id)

var material = preload("res://resources/Chip.material").duplicate()
const chip_height = 0.5
const player_color = [
	Color("04fdff"),
	Color("febf56"),
	Color("f93c8c"),
	Color("fe9373")
]
var player_id
var stack
var collider_id
var from_stack
var from_origin
var to_stack
var to_origin
var t = null
var game_started = true

func _ready():
	collider_id = $Mesh/Body.get_instance_id()

func get_player_id():
	return self.player_id

func set_player_id(id):
	player_id = id
	material.albedo_color = player_color[id]
	$Mesh.set_surface_material(0, material)
	stack.set_player_id(id)

func set_stack(stack):
	self.stack = stack

func in_stack():
	return self.stack

func get_collider_id():
	return collider_id

func on_click():
	pass

func move(from_stack, to_stack):
	to_stack.push_moving_chip(self)
	self.from_stack = from_stack
	self.to_stack = to_stack
	from_origin = transform.origin
	to_origin = to_stack.transform.origin - from_stack.transform.origin
	to_origin.y = to_stack.get_future_size() * chip_height
	t = 0

func on_landed(from_stack, to_stack):
	t = null
	transform.origin = Vector3(0.0, 0.0, 0.0)
	from_stack.remove_child(self)
	
	var captured_id = to_stack.get_player_id()
	var n_captured = to_stack.get_size()
	to_stack.pop_moving_chip()
	to_stack.add_chip(self)
	if to_stack.get_player_id() == captured_id:
		captured_id = null
		n_captured = 0
	translate(Vector3(0, to_stack.get_size() * chip_height - self.translation.y, 0))
	set_owner(to_stack)
	if to_stack.full():
		finish_movement(to_stack.get_size(), n_captured, captured_id)
		if game_started:
			to_stack.explode()
		else:
			game_started = true
	else:
		finish_movement(0, n_captured, captured_id)

func finish_movement(n_triggered, n_captured, captured_id):
	emit_signal('moved', n_triggered, n_captured, captured_id)

func calc_new_origin(t):
	var ox = from_origin.x * (1-t) + to_origin.x * t
	var oy = from_origin.y * (1-t) + to_origin.y * t
	var oz = from_origin.z * (1-t) + to_origin.z * t
	return Vector3(ox, oy, oz)

func on_game_over():
	game_started = false

func _process(delta):
	if t == null:
		return
	transform.origin = calc_new_origin(t)
	if t >= 1.0:
		on_landed(from_stack, to_stack)
		return
	t += delta
	if t > 1.0:
		t = 1.0
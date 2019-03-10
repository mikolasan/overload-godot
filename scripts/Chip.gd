extends Spatial

signal clicked(player_id)
signal moved(n_triggered, n_captured, captured_id)

var material = preload("res://resources/Chip.material").duplicate()
const player_color = [
	Color.greenyellow,
	Color.maroon,
	Color.mediumpurple,
	Color.gold
]
var player_id
var stack
var collider_id

func on_input_event(camera, event, click_position, click_normal, shape_idx):
	print('input_event', event)

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

func _ready():
	collider_id = $Mesh/Body.get_instance_id()
	$Mesh/Body.connect('input_event', self, 'on_input_event')

func get_collider_id():
	return collider_id

func on_click():
	pass

func finish_movement(n_triggered, n_captured, captured_id):
	emit_signal('moved', n_triggered, n_captured, captured_id)
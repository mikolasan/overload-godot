extends Spatial

signal clicked(player_id, stack_x, stack_y)
var material = preload("res://resources/Chip.material").duplicate()

var player_id
var stack_x
var stack_y
var collider_id

var player_color = [
	Color.greenyellow,
	Color.maroon,
	Color.mediumpurple,
	Color.gold
]

func on_input_event(camera, event, click_position, click_normal, shape_idx):
	print('input_event', event)

func set_player_id(id):
	player_id = id
	material.albedo_color = player_color[id]
	$Mesh.set_surface_material(0, material)

func set_stack_position(x, y):
	stack_x = x
	stack_y = y

func _ready():
	collider_id = $Mesh/Body.get_instance_id()
	$Mesh/Body.connect('input_event', self, 'on_input_event')

func get_collider_id():
	return collider_id

func on_click():
	print('on_click ', player_id, ' ', stack_x, ' ', stack_y)


extends Spatial

const Chip = preload("res://scenes/Chip.tscn")
const Stack = preload("res://scripts/Stack.gd")

var game_started = false

func create_field(width, height):
	var matrix = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(Stack.new())
	return matrix
	
var side_size = 10
var field
var player_start_position = [
	[[0,1], [1,0]],
	[[side_size-1,side_size-2], [side_size-2,side_size-1]],
	[[side_size-1,1], [side_size-2,0]],
	[[0,side_size-2], [1,side_size-1]]
]
var n_players = 4
var start_stack_size = 2
var chip_width = 1.5
var chip_height = 0.5
var colliders = {}
var current_player

func create_chips(field):
	for player_id in range(n_players):
		var start_position = player_start_position[player_id]
		for stack_position in start_position:
			var x = stack_position[0]
			var y = stack_position[1]
			field[x][y] = start_stack_size
			var new_stack = Spatial.new()
			add_child(new_stack)
			new_stack.translate(Vector3(x * chip_width, 0, y * chip_width))
			for stack_id in range(start_stack_size):
				var new_chip = Chip.instance()
				new_stack.add_child(new_chip)
				new_chip.translate(Vector3(0, stack_id * chip_height, 0))
				new_chip.set_player_id(player_id)
				new_chip.set_stack_position(x, y)
				var id = new_chip.get_collider_id()
				print(id)
				colliders[id] = new_chip
				new_chip.connect("clicked", self, 'on_chip_clicked')

func on_chip_clicked(player_id, x, y):
	print(player_id, ' ', x, ' ', y)

func on_start_game():
	game_started = true
	current_player = 0

func next_player():
	current_player = (current_player + 1) % n_players

func _ready():
	field = create_field(side_size, side_size)
	create_chips(field)

func select_chip(collider_id):
	if !current_player:
		return
	if collider_id in colliders:
		var chip = colliders[collider_id]
		if chip.get_player_id() == current_player:
			chip.in_stack().explode()

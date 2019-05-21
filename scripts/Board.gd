extends Spatial

signal turn_finished
signal game_over(winner)

const side_size = 5
const start_configuration = [
	[[0,1,3], [1,0,3]],
	[[side_size-1,side_size-2,3], [side_size-2,side_size-1,3]],
	[[side_size-1,1,3], [side_size-2,0,3]],
	[[0,side_size-2,3], [1,side_size-1,3]]
]
const n_players = 4

var field
var logic_field
var colliders = {}
var current_player
var player_stat = []
var game_started = false
var exploding = 0

func get_logic_field():
	return field

func add_chip_to_field(x, y, field = null):
	pass

func create_field(node: Spatial, width: int, height: int) -> Array:
	var matrix = []
	for x in range(width):
		matrix.append([])
		for z in range(height):
			var stack = StackInstance.new()
			stack.set_field_pos(Vector2(x, z))
			node.add_child(stack)
			matrix[x].append(stack)
	return matrix

func create_start_chips(field, start_configuration):
	for player_id in range(start_configuration.size()):
		player_stat.append(0)
		var player_configuration = start_configuration[player_id]
		for stack_configuration in player_configuration:
			var x = stack_configuration[0]
			var y = stack_configuration[1]
			var size = stack_configuration[2]
			var stack = field[x][y]
			stack.set_player_id(player_id)
			stack.add_chips(size, 0)
			player_stat[player_id] += size

func set_links(field):
	for x in range(len(field)):
		for z in range(len(field[x])):
			var adjacent_stacks = []
			if x - 1 >= 0:
				adjacent_stacks.append(Vector2(x - 1, z))
			else:
				adjacent_stacks.append(null)
			
			if x + 1 < field.size():
				adjacent_stacks.append(Vector2(x + 1, z))
			else:
				adjacent_stacks.append(null)
			
			if z - 1 >= 0:
				adjacent_stacks.append(Vector2(x, z - 1))
			else:
				adjacent_stacks.append(null)
			
			if z + 1 < field[x].size():
				adjacent_stacks.append(Vector2(x, z + 1))
			else:
				adjacent_stacks.append(null)
			
			var stack = field[x][z]
			stack.set_adjacent_stacks(adjacent_stacks)

func on_chip_clicked(player_id, x, y):
	print(player_id, ' ', x, ' ', y)

func on_chip_moved(n_triggered, n_captured, captured_id):
	if captured_id != null:
		player_stat[captured_id] -= n_captured
		player_stat[current_player] += n_captured
	exploding = exploding - 1 + n_triggered
	if exploding == 0:
		on_turn_finished()
	else:
		var next_player = define_next_player()
		if next_player == null:
			game_started = false

func on_start_game():
	game_started = true
	current_player = 0

func next_player(skip = 0):
	return (current_player + 1 + skip) % n_players

func define_next_player():
	for i in range(n_players - 1):
		var next_player = next_player(i)
		if player_stat[next_player] > 0:
			return next_player
	return null

func _ready():
	field = create_field(self, side_size, side_size)
	create_start_chips(field)
	set_links(field)
	on_start_game()

func on_turn_finished():
	print('on_turn_finished')
	print(player_stat)
	var next_player = define_next_player()
	if next_player == null:
		emit_signal('game_over', current_player)
	else:
		current_player = next_player
		emit_signal('turn_finished')

func select_chip(collider_id):
	if current_player == null || exploding > 0:
		return
	if collider_id in colliders:
		var chip = colliders[collider_id]
		if chip.get_player_id() == current_player:
			var stack = chip.in_stack()
			stack.add_chip(stack.size())
			player_stat[current_player] += 1
			if stack.full():
				exploding = stack.get_size()
				stack.explode()
			else:
				on_turn_finished()

func calc_center_point():
	var x_max = field.size() + chip_width / 2.0
	var z_max = field[0].size() + chip_width / 2.0
	return Vector3(x_max / 2.0, 0.0, z_max / 2.0)

func estimate_turn(player_id, x, y):
	var score = estimate_player_score(player_id)
	var new_stat = estimate_future_field(player_id, x, y)
	var new_score = new_stat[player_id]
	return new_score - score

func estimate_player_score(player_id):
	return player_stat[player_id]

func estimate_future_field(player_id, x, y):
	var stat = player_stat.duplicate()
	stat[player_id] += 1
	var field = get_logic_field()
	var new_field = add_chip_to_field(x, y, field)

func create_logic_field(width, height) -> Array:
	var matrix = []
	for x in range(width):
		matrix.append([])
		for z in range(height):
			var stack = Stack.new()
			matrix[x].append(stack)
	return matrix


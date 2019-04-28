extends Spatial

signal turn_finished
signal game_over(winner)

var Chip = preload("res://scenes/Chip.tscn")
var Stack = load("res://scripts/Stack.gd")

const chip_width = 2.0
const chip_height = 0.5

const side_size = 5
const player_start_position = [
	[[0,1], [1,0]],
	[[side_size-1,side_size-2], [side_size-2,side_size-1]],
	[[side_size-1,1], [side_size-2,0]],
	[[0,side_size-2], [1,side_size-1]]
]
const n_players = 4
const start_stack_size = 3

var field
var colliders = {}
var current_player
var player_stat = []
var game_started = false
var exploding = 0

func create_field(width, height):
	var matrix = []
	for x in range(width):
		matrix.append([])
		for z in range(height):
			var stack = Stack.new()
			add_child(stack)
			stack.translate(Vector3(x * chip_width, 0, z * chip_width))
			matrix[x].append(stack)
	return matrix

func add_chip(stack):
	var new_chip = Chip.instance()
	stack.add_chip(new_chip)
	new_chip.translate(Vector3(0, stack.get_size() * chip_height, 0))
	var id = new_chip.get_collider_id()
	colliders[id] = new_chip
	#new_chip.connect('clicked', self, 'on_chip_clicked')
	#new_chip.connect('moved', self, 'on_chip_moved')
	#connect('game_over', new_chip, 'on_game_over')
	return new_chip

func create_start_chips(field):
	for player_id in range(n_players):
		player_stat.append(0)
		var start_position = player_start_position[player_id]
		for stack_position in start_position:
			var x = stack_position[0]
			var y = stack_position[1]
			var stack = field[x][y]
			stack.set_player_id(player_id) # initial player id
			for stack_id in range(start_stack_size):
				add_chip(stack)
				player_stat[player_id] += 1

func set_links(field):
	for x in range(len(field)):
		for z in range(len(field[x])):
			var stack = field[x][z]
			var x_size = field.size()
			if x - 1 >= 0:
				stack.left = field[x - 1][z]
			if x + 1 < x_size:
				stack.right = field[x + 1][z]
			var z_size = field[x].size()
			if z - 1 >= 0:
				stack.up = field[x][z - 1]
			if z + 1 < z_size:
				stack.down = field[x][z + 1]

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
			emit_signal('game_over', current_player)

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
	field = create_field(side_size, side_size)
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
			add_chip(stack)
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

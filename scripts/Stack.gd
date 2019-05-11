class_name Stack

var player_id: int setget set_player_id, get_player_id
var id: int
var chips: Array = []
var left: int
var right: int
var up: int
var down: int

func set_player_id(id: int):
	player_id = id

func get_player_id():
	return player_id

func get_size():
	return self.chips.size()

func full():
	return get_size() >= 4

func add_chip(chip: Chip):
	chip.set_stack_id(id)
	if chip.get_player_id() == null:
		chip.set_player_id(player_id)
	elif chip.get_player_id() != player_id:
		player_id = chip.get_player_id()
		for chip in chips:
			chip.set_player_id(player_id)
	self.chips.append(chip)

func move_chips(to_stack: int, chips: Array) -> Array:
	if stack:
		for chip in chips:
			chip.move(id, to_stack)
		return []
	return chips

func explode() -> void:
	var flying_chips = self.chips.duplicate()
	self.chips.clear()
	var chips: Array = [flying_chips[3]]
	chips = move_chips(self.left, chips)
	chips.append(flying_chips[2])
	chips = move_chips(self.right, chips)
	if chips.size() == 1 && self.left:
		chips = move_chips(self.left, chips)
	chips.append(flying_chips[1])
	chips = move_chips(self.up, chips)
	chips.append(flying_chips[0])
	chips = move_chips(self.down, chips)
	if chips.size() == 1 && self.up:
		move_chips(self.up, chips)

static func create_logic_field(width, height) -> Array:
	var matrix = []
	for x in range(width):
		matrix.append([])
		for z in range(height):
			var stack = Stack.new()
			matrix[x].append(stack)
	return matrix


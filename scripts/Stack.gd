class_name Stack

var player_id: int setget set_player_id, get_player_id
var id: Vector2 setget set_id, get_id
var chips: Array = []
var adjacent_stacks: Array = []

func set_player_id(id: int):
	player_id = id
	for chip in chips:
		chip.set_player_id(id)

func get_player_id():
	return player_id

func set_id(id):
	self.id = id

func get_id():
	return id

func set_adjacent_stacks(stacks: Array) -> void:
	adjacent_stacks = stacks

func get_size():
	return self.chips.size()

func full():
	return get_size() >= 4

func add_chip(chip: Chip) -> void:
	chip.set_stack_id(id)
	var p = chip.get_player_id()
	if not p:
		chip.set_player_id(get_player_id())
	elif p != get_player_id():
		set_player_id(p)
	chips.append(chip)

func move_chips(to_stack: Vector2, chips: Array) -> void:
	for chip in chips:
		chip.move(id, to_stack)

func explode() -> void:
	var flying_chips = self.chips.duplicate()
	self.chips.clear()
	var adj_stacks = self.adjacent_stacks.duplicate()
	var chips: Array = []
	for i in range(2):
		var first_stack = adj_stacks.front()
		for j in range(2):
			chips.append(flying_chips.pop_back())
			var stack = adj_stacks.pop_front()
			if stack is Vector2:
				move_chips(stack, chips)
				chips = []
		if chips.size() == 1 && first_stack:
			move_chips(first_stack, chips)
			chips = []

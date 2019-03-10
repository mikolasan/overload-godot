extends Spatial

class_name Stack

const chip_height = 0.5
var chips = []
var left
var right
var up
var down
var player_id setget set_player_id

func set_player_id(id):
	player_id = id
func get_player_id():
	return player_id
	
func add_chip(chip):
	chip.set_stack(self)
	if chip.player_id == null:
		chip.set_player_id(player_id)
	elif chip.player_id != player_id:
		player_id = chip.player_id
		for chip in chips:
			chip.set_player_id(player_id)
	self.chips.append(chip)
	self.add_child(chip)

func add_chips(chips):
	for chip in chips:
		add_chip(chip)

func move_chips(stack, chips):
	if stack:
		for chip in chips:
			remove_child(chip)
			var captured_id = stack.get_player_id()
			var n_captured = stack.get_size()
			stack.add_chip(chip)
			if stack.get_player_id() == captured_id:
				captured_id = null
				n_captured = 0
			chip.translate(Vector3(0, stack.get_size() * chip_height - chip.translation.y, 0))
			chip.set_owner(stack)
			if stack.full():
				chip.finish_movement(stack.get_size(), n_captured, captured_id)
				stack.explode()
			else:
				chip.finish_movement(0, n_captured, captured_id)
		return []
	return chips

func get_size():
	return self.chips.size()

func full():
	return get_size() >= 4

func explode():
	var flying_chips = self.chips.duplicate()
	self.chips.clear()
	var chips = [flying_chips[0]]
	chips = move_chips(self.left, chips)
	chips.append(flying_chips[1])
	chips = move_chips(self.right, chips)
	if chips.size() == 1 && self.left:
		chips = move_chips(self.left, chips)
	chips.append(flying_chips[2])
	chips = move_chips(self.up, chips)
	chips.append(flying_chips[3])
	chips = move_chips(self.down, chips)
	if chips.size() == 1 && self.up:
		move_chips(self.up, chips)

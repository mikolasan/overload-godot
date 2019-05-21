extends Spatial
class_name StackInstance

const ChipInstance = preload("res://scenes/Chip.tscn")

const CHIP_WIDTH = 2.0

var field_pos: Vector2 setget set_field_pos, get_field_pos
var moving_chips: Array = []

func _ready():
	pass

func set_player_id(id):
	pass

func set_field_pos(pos):
	self.field_pos = pos
	translate(Vector3(pos.x * CHIP_WIDTH, 0, pos.y * CHIP_WIDTH))

func get_field_pos():
	return field_pos

func add_chips(n: int, start_pos: int):
	for i in range(n):
		add_chip(start_pos + i + 1)

func add_chip(stack_position: int) -> int:
	var new_chip = ChipInstance.instance()
	add_child(new_chip)
	new_chip.connect('moved', self, 'on_chip_moved')
	new_chip.set_stack_position(stack_position)
	return new_chip.get_collider_id()

func push_moving_chip(chip):
	moving_chips.append(chip)

func pop_moving_chip():
	moving_chips.pop_front()

func get_future_size():
	return moving_chips.size()

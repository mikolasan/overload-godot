extends Spatial
class_name StackInstance

var stack: Stack
var moving_chips: Array = []

func _ready():
	stack = Stack.new()

func get_logic_object() -> Stack:
	return stack

func add_chip(chip: ChipInstance):
	stack.add_chip(chip.get_logic_object())
	add_child(chip)

func add_chips(chips):
	for chip in chips:
		add_chip(chip)

func push_moving_chip(chip: ChipInstance):
	moving_chips.append(chip)

func pop_moving_chip():
	moving_chips.pop_front()

func get_future_size():
	return stack.get_future_size() + self.moving_chips.size()
class_name Chip

var player_id: int setget set_player_id, get_player_id
var stack_id: Vector2 setget set_stack_id, get_stack_id

func get_player_id() -> int:
	return player_id

func set_player_id(id: int):
	player_id = id

func set_stack_id(id: Vector2):
	stack_id = id

func get_stack_id() -> Vector2:
	return stack_id

func move(from_stack: Vector2, to_stack: Vector2) -> void:
	set_stack_id(to_stack)
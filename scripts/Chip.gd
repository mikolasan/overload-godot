class_name Chip

var player_id: int setget set_player_id, get_player_id
var stack_id: int setget set_stack_id, get_stack_id

func get_player_id():
	return player_id

func set_player_id(id: int):
	player_id = id
	on_player_id_changed(id)

func on_player_id_changed(id: int) -> void:
	pass

func set_stack_id(id: int):
	stack_id = id

func get_stack_id():
	return stack_id

func move(from_stack: int, to_stack: int) -> void:
	pass
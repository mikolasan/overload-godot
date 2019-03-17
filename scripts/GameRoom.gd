extends Spatial

const RAY_LENGTH = 50
var mouse_hover

func _ready():
	$UI.connect('start_game', $Board, 'on_start_game')
	$Board.connect('game_over', self, 'on_game_over')

func on_game_over(winner_id):
	print('game over! winner: ', winner_id)

func get_object_under_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	# casting rays in the form of (origin, normal)
	var ray_from = $Camera.project_ray_origin(mouse_pos) # Vector2
	var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * RAY_LENGTH # Vector2
	# Godot stores all the low level collision and physics information in a space
	# Accesing space:
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	# If the ray didn’t hit anything, the dictionary will be empty. 
	# If it did hit something, it will contain collision information
	return selection

func _physics_process(delta):
	var selection = get_object_under_mouse()
	if selection:
		mouse_hover = selection.collider_id

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && self.mouse_hover:
			$Board.select_chip(self.mouse_hover)

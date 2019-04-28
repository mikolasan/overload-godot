extends Spatial

const CAMERA_DISTANSE = 10
const RAY_LENGTH = 50
var mouse_hover
var mouse_position
var center_point = Vector3(0.0, 0.0, 0.0)
var camera_angle = 0

func _ready():
	#$UI.connect('start_game', $Board, 'on_start_game')
	$Board.connect('game_over', self, 'on_game_over')
	center_point = $Board.calc_center_point()
	rotate_camera(camera_angle)
	set_process_input(true)

func rotate_camera(angle):
	var position = $Camera.translation
	position.x = sin(angle) * CAMERA_DISTANSE + center_point.x
	position.z = cos(angle) * CAMERA_DISTANSE + center_point.z
	$Camera.look_at_from_position(position, center_point, Vector3.UP)

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
	pass
	
	var selection = get_object_under_mouse()
	if selection:
		mouse_hover = selection.collider_id

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed && self.mouse_hover:
				$Board.select_chip(self.mouse_hover)
		elif event.button_index == BUTTON_RIGHT:
			if event.pressed:
				mouse_position = event.position
			else:
				mouse_position = null
	elif event is InputEventMouseMotion:
		if mouse_position != null:
			camera_angle += deg2rad(event.relative.x)
			rotate_camera(camera_angle)

extends Spatial

const RAY_LENGTH = 50
var mouse_hover
var mouse_position
var center_point = Vector3(0.0, 0.0, 0.0)
var camera_distanse = 10
var horizontal_angle = 0
var vertical_angle = 0

func _ready():
	#$UI.connect('start_game', $Board, 'on_start_game')
	$Board.connect('game_over', self, 'on_game_over')
	center_point = $Board.calc_center_point()
	rotate_camera(horizontal_angle, vertical_angle)
	set_process_input(true)

func rotate_camera(horizontal_angle, vertical_angle):
	var position = $Camera.translation
	position.x = sin(horizontal_angle) * camera_distanse + center_point.x
	position.z = cos(horizontal_angle) * camera_distanse + center_point.z
	if (position.y < 12 && vertical_angle > 0
			|| position.y > 2 && vertical_angle < 0):
		position.y += vertical_angle
	vertical_angle = 0
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
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if camera_distanse < 18:
				camera_distanse += 1
			rotate_camera(horizontal_angle, vertical_angle)
		elif event.button_index == BUTTON_WHEEL_UP:
			if camera_distanse > 6:
				camera_distanse -= 1
			rotate_camera(horizontal_angle, vertical_angle)
			
	elif event is InputEventMouseMotion:
		if mouse_position != null:
			horizontal_angle += deg2rad(-event.relative.x)
			vertical_angle = deg2rad(event.relative.y)
			rotate_camera(horizontal_angle, vertical_angle)

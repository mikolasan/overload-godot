extends Control

signal start_game

func on_start_game():
	emit_signal('start_game')

func _ready():
	pass
	#$Container/Start.connect('pressed', self, 'on_start_game')
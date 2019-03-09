extends Node

class_name Stack

var chips = []

func add_chip(chip):
	chips.append(chip)

func explode():
	chips[0].up()
	chips[1].down()
	chips[2].left()
	chips[3].right()
	chips.clear()
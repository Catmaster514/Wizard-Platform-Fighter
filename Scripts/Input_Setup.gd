extends Node
#actions are buttons, axis is triggers and sticks

const actionNames = ["Jump", "Short_Jump", "Attack", "Special"]
const axisNames = ["Up", "Down", "Left", "Right"]
const eventAxis = [JOY_AXIS_LEFT_Y, JOY_AXIS_LEFT_Y, JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_X]
const eventButtonIndexes = [JOY_BUTTON_Y, JOY_BUTTON_X, JOY_BUTTON_B, JOY_BUTTON_A]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Input.get_connected_joypads().has(1): 
		setAllInputs(0, 1)
		setAllInputs(1, 2)
	else:
		setAllInputs(0, 2)
	

func add_button_event(actionName:StringName, eventButton:int, controller:int = 0) -> void:
	var event = InputEventJoypadButton.new()
	event.button_index = eventButton
	InputMap.action_add_event(actionName, event)
func add_axis_event(actionName:StringName, eventAxis:int, axisValue:float, controller:int = 0) -> void:
	var event = InputEventJoypadMotion.new()
	event.axis = eventAxis
	event.axis_value = axisValue
	InputMap.action_add_event(actionName, event)

func setAllInputs(controller, player):
	var axisValue = -1
	for i in actionNames.size():
		add_button_event(("Player_" + str(player) + "_" + actionNames[i]), eventButtonIndexes[i], controller)
	for i in axisNames.size():
		add_axis_event(("Player_" + str(player) + "_" + axisNames[i]), eventAxis[i], axisValue, controller)
		axisValue *= -1
	add_axis_event(("Player_" + str(player) + "_" + "Dash"), JOY_AXIS_TRIGGER_LEFT, 1, controller)
	add_axis_event(("Player_" + str(player) + "_" + "Dash"), JOY_AXIS_TRIGGER_RIGHT, 1, controller)

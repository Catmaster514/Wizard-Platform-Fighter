class_name Buffer
extends Node

@onready var character_body_2d: CharacterBody2D = $".."


const maxBufferSize: int = 5
#var extendedInputSize
var PlayerInput:PlayerControls


var inputBuffer = []
var currentFramesInputs = []


func _ready() -> void:
	PlayerInput = character_body_2d.PlayerInput

func _physics_process(delta: float) -> void: 
	checkInputs()
	inputBuffer.append(currentFramesInputs)
	currentFramesInputs = []
	if(inputBuffer.size() > maxBufferSize): inputBuffer.remove_at(0)
	

func addToBuffer(inputName:String):
	currentFramesInputs.append(inputName)

func checkInputs():
	
	if Input.is_action_just_pressed(PlayerInput.attack): addToBuffer("ATTACK")
	if Input.is_action_just_pressed(PlayerInput.dash): addToBuffer("DASH")
	if Input.is_action_just_pressed(PlayerInput.jump) || Input.is_action_just_pressed(PlayerInput.short_jump): addToBuffer("JUMP")
	if Input.is_action_just_pressed(PlayerInput.special) : addToBuffer("SPECIAL")
	elif currentFramesInputs == []: addToBuffer("NeutralInput")

func clear():
	inputBuffer =[]

func hasInput(value:String) -> bool:
	for i in inputBuffer:
		if i is Array:
			if i.has(value): return true
		elif value == i: return true
	return false

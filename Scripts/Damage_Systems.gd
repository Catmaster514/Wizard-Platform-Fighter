extends Node
@onready var player: CharacterBody2D = $".."
@onready var animator: AnimatedSprite2D = $"../PlayerAnimatedSprite"
const playerSpawnPositions = [1, 1, -1]

var percent:int = 0

var playerNumber:int = 1
var playerDirection:int = 1

func _ready() -> void:
	playerNumber = player.get_meta("Player")
	playerDirection = playerSpawnPositions[playerNumber]

func respawn(position:Vector2):
	player.resetPlayer()
	
	player.position = position * Vector2(playerDirection, 1)
	player.pointDirection(playerDirection)
	percent = 0

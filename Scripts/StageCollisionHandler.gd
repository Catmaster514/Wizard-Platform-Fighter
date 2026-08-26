extends StaticBody2D

@onready var platforms: StaticBody2D = $Platforms
@onready var platform_l: CollisionShape2D = $Platforms/PlatformL

@onready var player_1: CharacterBody2D = %Player1
@onready var player_2: CharacterBody2D = %Player2


var player1BasePosition:int
var player2BasePosition:int

func _ready() -> void:
	player1BasePosition = player_1.get_meta("feetOffSet")
	player2BasePosition = player_2.get_meta("feetOffSet")
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	platforms.set_collision_layer_value(1, (player_1.position.y + player1BasePosition) < platform_l.position.y)
	platforms.set_collision_layer_value(2, (player_2.position.y + player2BasePosition) < platform_l.position.y)

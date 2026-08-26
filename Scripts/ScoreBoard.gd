extends Node
const playerSpawn:Vector2 = Vector2(-111, -90)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func Player_Dies(body: Node2D) -> void:
	if(body.has_meta("IsPlayer")):
		body.find_child("PlayerDamage").respawn(playerSpawn)
		print("respawn")

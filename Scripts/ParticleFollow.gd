extends Node2D

var isFollowing = false
var target


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isFollowing: position = target.position

func followTarget(Target:NodePath):
	isFollowing = true
	target = get_node(Target)

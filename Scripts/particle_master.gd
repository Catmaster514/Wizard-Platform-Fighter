extends Node

var ParticleLibrary = preload("uid://d4gccwg2v7eqd").new()


func spawnParticle(particleName: String, position:Vector2, target = null):
	var particle = ParticleLibrary.getParticle(particleName).instantiate()
	add_child(particle)
	particle.position = position
	particle.find_child("AnimationPlayer").play(particleName)
	if target != null: particle.followTarget(target)

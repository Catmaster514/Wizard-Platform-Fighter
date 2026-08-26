extends Node

const JUMP_PARTICLES = preload("uid://cu7sn0phftj1v")
const AIR_JUMP_PARTICLES = preload("uid://qq1oe7g53i2u")
const FAST_FALL_PARTICLES = preload("uid://boru3icrjxl38")


var particleList = {"JumpParticles":JUMP_PARTICLES, "AirJumpParticles":AIR_JUMP_PARTICLES, "FastFallParticles":FAST_FALL_PARTICLES}

func getParticle(name:String):
	return particleList.get(name)

extends CharacterBody2D
const AnimationQue = preload("uid://bvk6nllheef7a")

@export var PlayerInput:PlayerControls = null

@onready var buffer: Buffer = $buffer
@onready var animatedSprite: AnimatedSprite2D = $PlayerAnimatedSprite
@onready var particle_master: Node = %ParticleMaster
@onready var edge_detector: Area2D = $EdgeDetection


#Acceleration is used as a value that is a fraction equal to x / max speed
# if you look at x as a number over 60 than it can measure the amount of frames that it would take for it to move the speed from 0 -> max speed or max speed -> 0
# x = 1/60 means that the player will accelerate from 0 to max speed in one second linearly
# after more systems have been implemented I want to use quadratic equations for some of the acceleartion curves to make smoother movement
const GROUND_ACCELERATION = 50.0/60
const GROUND_DECCELERATION = 8.0/60
const AIR_ACCELERATION = 4.0/60
#const AIR_DECCELERATION = 1.0/120
const JUMP_ACCELERATION = 1

const SPEED = 260.0
const JUMP_VELOCITY = -370.0
const SHORT_JUMP_VELOCITY = -270.0
const AIR_JUMP_VELOCITY = -300.0
const DASH_VELOCITY = 350.0
const DASH_ATTACK_VELOCITY = 300

const airJumps = 1

const stickFlickDeadZone:float = 0.3

var forcedMovement:bool = true
var forcedMovementDuration:int = 0
var forcedMovementSpeed:Vector2 = Vector2.ZERO
var stopAtLedge:bool = false

var direction:float = 0
var spriteDirection:int = 1
var jumpCount = 0
var hasAirDash = true
var fallSpeedMult = 1

var canMove = true
var physicsOn = true
var startedJumpOnGround = false
var shortJump = false
var jumping = false
var landed = false

var downLastInputStrength:float = 0.0
var stickFlick:bool = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	direction = Input.get_axis(PlayerInput.left, PlayerInput.right)
	stickFlick = slammedStickDown()
	
	if direction > 0.0: spriteDirection = 1
	elif direction < 0.0: spriteDirection = -1
	
	if forcedMovement:
		forcedMovementDuration -= 1
		velocity = forcedMovementSpeed
		if forcedMovementDuration <= 0: 
			forcedMovement = false
		#print("velocity: " + str(velocity.x) + " stopatledge: " + str(stopAtLedge) + "not on edge: " + str(edge_detector.has_overlapping_bodies()))
		move_and_stop()
	else:
		if is_on_floor(): 
			if !landed:
				resetPlayer()
			if physicsOn:
				if direction && canMove:
					changeSpeed(GROUND_ACCELERATION)
					pointDirection(spriteDirection)
				else: 
					changeSpeed(GROUND_DECCELERATION, 0, true)
		elif !is_on_floor():
			landed = false
			if physicsOn:
				velocity += get_gravity() * delta * fallSpeedMult
				if direction && canMove: changeSpeed(AIR_ACCELERATION)
		if canMove: actionStateMachine()
		setAnimationState()
		move_and_stop()

func actionStateMachine():
	jumping = buffer.hasInput("JUMP")
	if(jumping):
		jumpFunc()
	elif Input.get_action_strength(PlayerInput.down)  >  0.5 && stickFlick && fallSpeedMult != 2: 
		fallSpeedMult = 2
		particle_master.spawnParticle("FastFallParticles", position, get_path())
	if buffer.hasInput("ATTACK"):
		attackFunc(jumping)
	elif buffer.hasInput("DASH"):
		dashFunc()

func cancel(state:String ):
	if buffer.hasInput("ATTACK") && state != "ATTACK":
		animatedSprite.cancelAnimation()
		attackFunc(state == "JUMP")
	if buffer.hasInput("JUMP") && state != "JUMP":
		animatedSprite.cancelAnimation()
		if state == "ATTACK": attackFunc(true)
	if buffer.hasInput("DASH") && state != "DASH":
		animatedSprite.cancelAnimation()
		dashFunc()

func setAnimationState():
	if !is_on_floor(): animatedSprite.queAnimation(AnimationQue.FALL, false)
	elif direction: animatedSprite.queAnimation(AnimationQue.RUN, false)
	else: animatedSprite.queAnimation(AnimationQue.IDLE, false)

func jump():
	if startedJumpOnGround:
		if shortJump: velocity.y = SHORT_JUMP_VELOCITY
		else: velocity.y = JUMP_VELOCITY
		if(direction): changeSpeed(JUMP_ACCELERATION)
	else:
		velocity.y = AIR_JUMP_VELOCITY
		jumpCount += 1
		changeSpeed(JUMP_ACCELERATION)

#if you run it with no args it will make it so you cant move 
#if you input false it will unlock movement
func setLockMovement(moveState: bool = true, physicsState: bool = true):
	canMove = moveState
	physicsOn = physicsState
#Multipliers should be less or equal to one because any number higher then one is treated the same as one
#Negative numbers will accellerate backwards which is bad because it will also ascend into infinity
func changeSpeed(multiplier: float, DIRECTION:float = direction, StopAtLedge:bool = false):
	if(physicsOn):
		stopAtLedge = StopAtLedge
		velocity.x = move_toward(velocity.x, DIRECTION * SPEED, SPEED * multiplier)
func movePlayer(duration:int, speed:Vector2, StopAtLedge:bool = false):
	stopAtLedge = StopAtLedge
	forcedMovement = true
	forcedMovementDuration = duration
	forcedMovementSpeed = speed
func pointDirection(direction:int):
	transform.x = Vector2(direction, 0.0)
func resetPlayer():
	fallSpeedMult = 1
	jumpCount = 0
	hasAirDash = true
	landed = true
	canMove = true
	animatedSprite.cancelAnimation()

#Move and slide method except it will stop at a ledge when the stopatledge variable is true, like on dash attacks, and slowing down
func move_and_stop():
	if stopAtLedge && !edge_detector.has_overlapping_bodies(): velocity.x = 0
	move_and_slide()
func slammedStickDown() -> bool:
	var inputStrength = Input.get_action_strength(PlayerInput.down)
	var movedDistance = (inputStrength - downLastInputStrength) > stickFlickDeadZone
	downLastInputStrength = inputStrength
	return movedDistance
#After this point these are all of the action functions, all actions are functions to clean up the code for the state machine
func jumpFunc(jumpAction:bool = false):
	buffer.clear()
	if is_on_floor():
		shortJump = Input.is_action_just_pressed(PlayerInput.short_jump)
		startedJumpOnGround = true
		if jumpAction: jump()
		else:
			particle_master.spawnParticle("JumpParticles", position)
			animatedSprite.queAnimation(AnimationQue.JUMP, true)
	elif jumpCount < airJumps:
		particle_master.spawnParticle("AirJumpParticles", position)
		startedJumpOnGround = false
		fallSpeedMult = 1
		velocity.y = 0
		if jumpAction: jump()
		else: animatedSprite.queAnimation(AnimationQue.JUMP, true)
func attackFunc(jumping:bool):
	buffer.clear()
	pointDirection(spriteDirection)
	if is_on_floor(): 
		if direction:
			animatedSprite.queAnimation(AnimationQue.DASHATTACK, true)
			movePlayer(20, Vector2(DASH_ATTACK_VELOCITY*direction, 0), true)
			return
		elif !jumping:
			changeSpeed(.7)
	if jumping: 
		jumpFunc(true)
	animatedSprite.queAnimation(AnimationQue.GROUNDATTACK, true)
func dashFunc():
	buffer.clear()
	if hasAirDash && !is_on_floor():
			transform.x = Vector2(spriteDirection, 0.0)
			fallSpeedMult = 1
			velocity = Vector2(DASH_VELOCITY * spriteDirection, 0)
			animatedSprite.queAnimation(AnimationQue.DASH, true)
			movePlayer(11, Vector2(DASH_VELOCITY*spriteDirection,0))
			hasAirDash = false

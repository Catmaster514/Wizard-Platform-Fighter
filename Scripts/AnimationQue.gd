extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var attackAnimatedSprite: AnimatedSprite2D = $"../Attack/AttackAnimatedSprite"


enum {IDLE, RUN, FALL, JUMP, DASH, GROUNDATTACK, DASHATTACK}

var AnimationList = ["IDLE", "RUN", "FALL", "JUMP", "DASH","GROUNDATTACK", "DASHATTACK"]

var animationLock = false
var AnimationQue = {}
var currentAnimation = 0
var hasAttackEffect = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	currentAnimation = readQue()
	if !animationLock:
		play(currentAnimation)
		if hasAttackEffect: 
			attackAnimatedSprite.visible = true
			attackAnimatedSprite.play(currentAnimation)
		else: attackAnimatedSprite.visible = false
		if animation_player.has_animation(currentAnimation):
			animation_player.play(currentAnimation)

#outside classes will call this method whenever an animation needs to be played 
#and the information of if that animation can not be interupted is also present with the animation lock variable
func queAnimation(type, AnimationLock:bool = false):
	AnimationQue[AnimationLock] = type

func setAnimationLock(lock:bool = true):
	animationLock = lock

func cancelAnimation():
	stop()
	animation_player.stop()
	offset = Vector2(0,0)
	animationLock = false
	

#The read que function goes through the que of animations set outside of the script and sets the current animation to be played
#To the highest prioty one with the prioty being set by the location in the enum(it works because they are just names for numbers)
#It clears the que and if it wants the animation to be played for its duration it adds it to the que if the animation lock variable
#Is set to true, the Animation lock variable is set in a animation played using the AnimationPlayer Object
func readQue():
	var desiredAnimation = 0

	for i in AnimationQue:
		if AnimationQue[i] > desiredAnimation:
			desiredAnimation = AnimationQue[i]
	AnimationQue = {}
	
	if(animationLock):
		queAnimation(desiredAnimation)
	hasAttackEffect = desiredAnimation > 4
	return AnimationList[desiredAnimation] 

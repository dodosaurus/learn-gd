class_name Player
extends CharacterBody2D

var direction_x := 0.0
@export var speed := 150
@onready var cd_timer = $Timers/CooldownTimer

var can_shoot := true
var facing_right := true
var has_gun := false

signal shoot(pos: Vector2, facing_right: bool)

func _process(delta):
	get_input()
	apply_gravity()
	get_facing_direction()
	get_animation()
	
	velocity.x = direction_x
	
	move_and_slide()
	
func get_input():
	direction_x = Input.get_axis("left", "right") * speed
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y -= 200
		
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		print("shoot")
		shoot.emit(global_position, facing_right)
		cd_timer.start()
	
func apply_gravity():
	velocity.y += 20
	
func get_facing_direction():
	if direction_x != 0:
		facing_right = direction_x >= 0
	
func get_animation():
	var animation = "idle"
	if not is_on_floor():
		animation = "jump"
	elif direction_x != 0:
		animation = "walk"
		
	if has_gun:
		animation += "_gun"
		
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.flip_h = not facing_right
	
func _on_cooldown_timer_timeout():
	can_shoot = true

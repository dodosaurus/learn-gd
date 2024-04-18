class_name Player
extends CharacterBody2D

var direction_x := 0.0
@export var speed := 150

@onready var cd_timer = $Timers/CooldownTimer
@onready var fire_timer = $Timers/FireTimer
@onready var invi_timer = $Timers/InvincibilityTimer

var can_shoot := true
var facing_right := true
var has_gun := false
var vulnerable := true

var health := 10

signal shoot(pos: Vector2, facing_right: bool)

func _process(_delta):
	get_input()
	apply_gravity()
	get_facing_direction()
	get_animation()
	
	velocity.x = direction_x
	
	#automatically using delta
	move_and_slide()
	
func get_input():
	direction_x = Input.get_axis("left", "right") * speed
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y -= 200
		
	if Input.is_action_just_pressed("shoot") and can_shoot and has_gun:
		can_shoot = false
		print("shoot")
		$Fire.get_child(facing_right).show()
		shoot.emit(global_position, facing_right)
		fire_timer.start()
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

func _on_fire_timer_timeout():
	for child in $Fire.get_children():
		child.hide()
		
func get_damage(amount):
	if vulnerable: 
		health -= amount
		vulnerable = false
		invi_timer.start()
		print("player was damaged")
		var tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)

func _on_invincibility_timer_timeout():
	vulnerable = true

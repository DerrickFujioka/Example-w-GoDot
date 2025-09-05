extends CharacterBody2D

### Preload fireball and maker ###
@onready var fireball = preload("res://fireball.tscn")
@onready var fireballspawn = $fireball_spawn_marker
######################################################

@export var speed = 60
@export var jump_speed = -200
@export var gravity = 400
@export var roll_speed = 300 # A higher speed for the roll
@export var roll_duration = 0.3 # How long the roll lasts

var is_rolling = false
var roll_timer = 0.0
var score = 0


func _physics_process(delta):
		#####################Shooting Function#################################
	if Input.is_action_just_pressed("shoot"):
		$"../Launch".play()
		### Instantiate the fireball and add it to the scene
		var new_fireball = fireball.instantiate()
		get_parent().add_child(new_fireball)
		#Set the fireball's initial postition to the spawn marker's global positon
		new_fireball.global_position = fireballspawn.global_position
		#Set the intiital momentum for the fireball. You can adjust this value
		var shoot_momentum = 500
		# Determine the direction and apply a linear velocity directly
		if $AnimatedSprite2D.scale.x < 0:
			# Player is facing left
			new_fireball.linear_velocity = Vector2(-shoot_momentum, 0)
		else:
			# Player is facing right
			new_fireball.linear_velocity = Vector2(shoot_momentum, 0)

	
	
	$CanvasLayer/Label.text = "SCORE :" + str(Globalvariables.score)
	$CanvasLayer2/Label2.text = "LIVES :" + str(Globalvariables.lives)
	# Add gravity every frame
	velocity.y += gravity * delta
	
	# Check for roll input first
	if Input.is_action_pressed("roll") and is_on_floor() and not is_rolling:
		$"../Rolling".play()
		is_rolling = true
		roll_timer = roll_duration
		# Get the facing direction from the sprite's scale and apply roll speed
		var roll_direction = $AnimatedSprite2D.scale.x
		velocity.x = roll_direction * roll_speed
		# Play the roll animation
		$AnimatedSprite2D.play("roll")
		return
		
	# Handle the roll timer
	if is_rolling:
		roll_timer -= delta
		# Stop rolling when the timer is up
		if roll_timer <= 0:
			is_rolling = false
			
	# If not rolling, handle regular movement and animations
	if not is_rolling:
		# Input affects x axis only
		var direction = Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * speed
		
		# Flip the sprite based on the horizontal direction using scale
		if direction > 0:
			$AnimatedSprite2D.scale.x = 1
		elif direction < 0:
			$AnimatedSprite2D.scale.x = -1
		
		# Play the appropriate animation
		if direction != 0:
			# Player is moving, play the "run" or "walk" animation
			$AnimatedSprite2D.play("default")
		else:
			# Player is not moving, play the "idle" animation
			$AnimatedSprite2D.play("idle")
			
		# Only allow jumping when on the ground and not rolling
		if Input.is_action_pressed("jump") and is_on_floor():
			$"../Jump".play()
			velocity.y = jump_speed

	move_and_slide()

#####HANDLE_BORDER#######


func _on_area_2d_area_entered(area: Area2D) -> void:
	if Globalvariables.lives > 0:
		if area.is_in_group("border"):
			gravity = 2000
			await get_tree().create_timer(0.5).timeout
			Globalvariables.lives -=1
			get_tree().reload_current_scene()
			
		if area.is_in_group("coin"):
			Globalvariables.score += 1
			$CanvasLayer/Label.text = "SCORE :" + str(Globalvariables.score)
			$"../Coin".play()
	else:
		get_tree().change_scene_to_file("res://endscene.tscn")


func _on_waterdeath_area_entered(area: Area2D)-> void:
	$"../Die".play()
	_handle_death()
func _on_fall_damage_area_entered(area: Area2D) -> void:
	$"../Die".play()
	_fell_too_much()


func _on_exit_area_entered(area: Area2D) -> void:
		if area.is_in_group("player"):
			get_tree().change_scene_to_file("res://world_2.tscn")

#move_and_slime()
#score
#$CanvasLayer/Label.text =  "score: " + str(score)

func _handle_death():
	if Globalvariables.lives > 0:
		#make gravity = 40
		gravity = 40
		jump_speed = 0
		await get_tree().create_timer(1.5).timeout
		Globalvariables.lives -=1
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://endscene.tscn")

func _fell_too_much():
	if Globalvariables.lives > 0:
		#make gravity = 40
		gravity = 40
		jump_speed = 0
		await get_tree().create_timer(0.2).timeout
		Globalvariables.lives -=1
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://endscene.tscn")

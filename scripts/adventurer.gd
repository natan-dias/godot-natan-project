extends KinematicBody2D

#variáveis novas
onready var rayD = get_node("rayD") #variável raycast para detectar o chão
onready var rayE = get_node("rayE") #Apontados na variável no_chao
onready var sprite_adv = get_node("sprite_adv")
onready var col_shape = get_node("col-shape-adv")
var vivo = true #Variável de vida
var fim = false #Variável do final da fase
onready var camera = get_node("camera")

#controls
var left
var right
var up
var attack


var shake_amount = 1.0 #Variável para tremer a câmera
var double_jump = 1 #Variável para o pulo duplo

#Sinais
signal morrer
signal fim
#signal porta01

#------------------------------------------------------#

# Member variables
const GRAVITY = 1900.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 10
var WALK_FORCE = 1200
var WALK_MIN_SPEED = 100
var WALK_MAX_SPEED = 300
const STOP_FORCE = 3000
var JUMP_SPEED = 700
const JUMP_MAX_AIRBORNE_TIME = 0.1

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false

#------------------------------------------------------#

func _physics_process(delta):
	
	if Global.sprite == 2:
		JUMP_SPEED = 1000
		WALK_FORCE = 2000
		WALK_MIN_SPEED = 100
		WALK_MAX_SPEED = 500
		$camera.set_offset(Vector2( \
		rand_range(-10.0, 10.0) * shake_amount, \
		rand_range(-10.0, 10.0) * shake_amount \
		))
	
	if Global.sprite == 1:
		JUMP_SPEED = 700
		WALK_FORCE = 1200
		WALK_MIN_SPEED = 100
		WALK_MAX_SPEED = 300
		
	if Global.sprite == 3:
		JUMP_SPEED = 700
		WALK_FORCE = 1200
		WALK_MIN_SPEED = 100
		WALK_MAX_SPEED = 300
	
	##### GIT CODE #####
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	var walk_left = (Input.is_action_pressed("move_left") or left) and vivo
	var walk_right = (Input.is_action_pressed("move_right") or right) and vivo
	var jump = (Input.is_action_just_pressed("jump") or up) and vivo
	var hit = (Input.is_action_pressed("hit") or attack) and vivo
	
	var stop = true
	
	var no_chao = rayE.is_colliding() or rayD.is_colliding() and vivo
	
	# Desabilitar ataque fora do chão
	if not no_chao:
		hit = false
	
	if walk_left and not hit:
		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
			force.x -= WALK_FORCE
			stop = false
	elif walk_right and not hit:
		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
			force.x += WALK_FORCE
			stop = false
	
	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		velocity.x = vlen * vsign
		
	
	# Integrate forces to velocity
	velocity += force * delta
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		on_air_time = 0
		velocity.y += GRAVITY * delta * 10
		double_jump = 1 # Resetar o valor do pulo duplo quando chegar ao chão
		
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
		
		$"control-timer".start(2)
		
	
	# Condição para o pulo duplo fucionar
	if jump and velocity.y > 0 and Global.sprite == 3 and double_jump < 3:
		velocity.y = -JUMP_SPEED
		double_jump += 1
		print(double_jump)
		#jumping = true
		
	
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	##### Fim do GIT CODE #####
	
	##### Código de alterações no Sprite do personagem #####
	
	
	if walk_right:
		sprite_adv.set_flip_h(false)
		#Global.global_right = true
		#Global.global_left = false
	
	if walk_left:
		sprite_adv.set_flip_h(true)
		#Global.global_right = false
		#Global.global_left = true
	
	if (walk_right or walk_left) and no_chao and vivo and not hit:
		sprite_adv.set_animation("default")
		
	elif (no_chao) and vivo and hit:
		sprite_adv.set_animation("attack")
		
	elif (not no_chao) and vivo:
		sprite_adv.set_animation("jump")
		
	elif (not no_chao) and (walk_right or walk_left) and vivo:
		sprite_adv.set_animation("jump")
			
	elif vivo:
		sprite_adv.set_animation("stop")

#--- Função para exibir toda a animação de ataque ---#
func attacking():
	if rayE.is_colliding() and rayD.is_colliding():
		attack = true

func stop_attacking():
	$"control-timer".start(0.7)
	
#--- Função para exibir toda a animação de ataque ---#

func morrer():
	vivo = false
	$sprite_adv.set_animation("dead")
	emit_signal("morrer")
	Global.sprite = 1

func reviver():
	if Global.vidas == 0:
		print("end-game")
		get_tree().quit()
	else:
		velocity = Vector2(0, 0)
		sprite_adv.set_flip_h(false)
		get_node("camera").make_current()
		vivo = true
		fim = false
		get_tree().reload_current_scene()


##### Código do FIM #####

func _on_fim_body_entered(body):
	print("fim")
	fim = true
	emit_signal("fim")
	right = true

##### PORTA 1 #####

func _on_openPorta1_body_entered(body):
	emit_signal("porta01")

##### FIM PORTA #####

func _on_Area2D_body_entered(body):
	print("enemy")
	print("morrer")

##### CONTROLS ######

func _on_left_pressed():
	left = true

func _on_left_released():
	left = false

func _on_right_pressed():
	right = true

func _on_right_released():
	right = false

func _on_jump_pressed():
	up = true

func _on_jump_released():
	up = false

func _on_attack_pressed():
	attacking()

func _on_attack_released():
	stop_attacking()
	
func _on_controltimer_timeout():
	attack = false

extends CharacterBody2D

const SPEED = 50.0
const GRAVIDADE = 1000.0

var direction = -1
var morto = false

@onready var batevolta: RayCast2D = $batevolta
@onready var detectarChao: RayCast2D = $detectarChao
@onready var animacao = $animacao

func _physics_process(delta: float) -> void:
	if morto:
		return

	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	detectarChao.force_raycast_update()
	batevolta.force_raycast_update()

	# Virar se não houver chão à frente
	if is_on_floor() and not detectarChao.is_colliding():
		direction *= -1

		# Mover o detector para o outro lado
		detectarChao.position.x = abs(detectarChao.position.x) * direction

		# Virar o inimigo
		animacao.scale.x = abs(animacao.scale.x) * direction

	# Virar se encontrar uma parede
	elif batevolta.is_colliding():
		direction *= -1
		batevolta.scale.x *= -1
		animacao.scale.x = abs(animacao.scale.x) * direction

	velocity.x = direction * SPEED
	move_and_slide()

func morrer() -> void:
	if morto:
		return

	morto = true
	queue_free()

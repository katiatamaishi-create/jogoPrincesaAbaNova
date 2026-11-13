extends CharacterBody2D

const VELOCIDADE = 200.0
const PULO = -400.0
const GRAVIDADE = 1000.0

var posicao_inicial: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Guarda a posição inicial do personagem
	posicao_inicial = global_position


func _physics_process(delta: float) -> void:
	# Aplica a gravidade
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	else:
		velocity.y = 0.0

	# Pulo usando a tecla Espaço
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = PULO

	# Movimentação para a esquerda e direita
	var direcao = Input.get_axis("ui_left", "ui_right")
	velocity.x = direcao * VELOCIDADE

	# Controla as animações
	if not is_on_floor():
		if animated_sprite.sprite_frames.has_animation("pulando"):
			animated_sprite.play("pulando")

	elif direcao != 0:
		if animated_sprite.sprite_frames.has_animation("correndo"):
			animated_sprite.play("correndo")

	else:
		if animated_sprite.sprite_frames.has_animation("parado"):
			animated_sprite.play("parado")

	# Move o personagem
	move_and_slide()


# Faz o Player 1 voltar à posição inicial
# quando o Player 2 chega primeiro ao portal
func voltar_ao_inicio() -> void:
	global_position = posicao_inicial
	velocity = Vector2.ZERO

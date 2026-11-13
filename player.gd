
extends CharacterBody2D

const VELOCIDADE = 200.0
const FORCA_PULO = -400.0
const GRAVIDADE = 1000.0

# Ative somente na fase dos caminhos
@export var fase_do_caminho: bool = false

# Caminhos configurados no Inspetor
@export var caminho_inicial: Path2D
@export var caminho_esquerdo: Path2D
@export var caminho_direito: Path2D

var estava_pulando: bool = false
var esta_morrendo: bool = false

# Pontos da rota atual
var pontos: PackedVector2Array = PackedVector2Array()
var indice_ponto: int = 0

# Movimento por pontos
var movendo_para_ponto: bool = false
var rota_atual: Path2D = null

# Escolha e retorno
var esperando_escolha: bool = false
var caminho_escolhido: bool = false
var direcao_escolhida: int = 0

# Guarda os caminhos percorridos para permitir voltar
var historico_rotas: Array[Path2D] = []
var historico_indices: Array[int] = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector_chao: RayCast2D = get_node_or_null("detectarChao")


func _ready() -> void:
	if fase_do_caminho:
		if caminho_inicial != null:
			carregar_caminho(caminho_inicial)


func _physics_process(delta: float) -> void:
	if esta_morrendo:
		return

	if fase_do_caminho:
		movimentar_por_pontos()
	else:
		movimentar_plataforma(delta)

	move_and_slide()

	if not fase_do_caminho:
		verificar_inimigos()


# ==========================================
# FASES ANTIGAS: PLATAFORMAS
# ==========================================

func movimentar_plataforma(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	else:
		estava_pulando = false

	if Input.is_key_pressed(KEY_W) and is_on_floor() and not estava_pulando:
		velocity.y = FORCA_PULO
		estava_pulando = true

	var direcao := 0.0

	if Input.is_key_pressed(KEY_A):
		direcao = -1.0
	elif Input.is_key_pressed(KEY_D):
		direcao = 1.0

	velocity.x = direcao * VELOCIDADE

	if direcao != 0:
		animated_sprite.flip_h = direcao < 0

	if not is_on_floor():
		tocar_animacao("pulando")
	elif direcao != 0:
		tocar_animacao("correndo")
	else:
		tocar_animacao("parada")


# ==========================================
# FASE DE CAMINHOS
# ==========================================

func movimentar_por_pontos() -> void:

	if not movendo_para_ponto:

		velocity = Vector2.ZERO

		if not caminho_escolhido:

			if Input.is_action_just_pressed("ui_up"):
				iniciar_proximo_ponto()

			elif Input.is_action_just_pressed("ui_left"):
				if esperando_escolha:
					escolher_rota(caminho_esquerdo)
				else:
					voltar_ponto()

			elif Input.is_action_just_pressed("ui_right"):
				if esperando_escolha:
					escolher_rota(caminho_direito)

			elif Input.is_action_just_pressed("ui_down"):
				voltar_ponto()

		else:

			if direcao_escolhida == -1:
				if Input.is_action_just_pressed("ui_left"):
					iniciar_proximo_ponto()
				elif Input.is_action_just_pressed("ui_down"):
					voltar_ponto()

			elif direcao_escolhida == 1:
				if Input.is_action_just_pressed("ui_right"):
					iniciar_proximo_ponto()
				elif Input.is_action_just_pressed("ui_down"):
					voltar_ponto()

		if not movendo_para_ponto:
			tocar_animacao("parada")
			return

	if indice_ponto < pontos.size():

		var destino: Vector2 = pontos[indice_ponto]
		var direcao: Vector2 = destino - global_position

		if direcao.length() > 4.0:

			velocity = direcao.normalized() * VELOCIDADE

			if direcao.x != 0:
				animated_sprite.flip_h = direcao.x < 0

			tocar_animacao("correndo")

		else:

			global_position = destino
			velocity = Vector2.ZERO
			movendo_para_ponto = false

			historico_rotas.append(rota_atual)
			historico_indices.append(indice_ponto)

			indice_ponto += 1

			tocar_animacao("parada")

			if rota_atual == caminho_inicial:
				if indice_ponto >= pontos.size():
					esperando_escolha = true


# ==========================================
# INICIAR MOVIMENTO PARA O PRÓXIMO PONTO
# ==========================================

func iniciar_proximo_ponto() -> void:

	if indice_ponto < pontos.size():
		movendo_para_ponto = true


# ==========================================
# CARREGAR PONTOS DA CURVA
# ==========================================

func carregar_caminho(caminho: Path2D) -> void:

	if caminho == null:
		return

	rota_atual = caminho

	var curva: Curve2D = caminho.curve

	if curva == null:
		return

	pontos.clear()

	for i in range(curva.get_point_count()):

		var ponto_local: Vector2 = curva.get_point_position(i)
		var ponto_global: Vector2 = caminho.to_global(ponto_local)

		pontos.append(ponto_global)

	indice_ponto = 0


# ==========================================
# ESCOLHER A ROTA
# ==========================================

func escolher_rota(caminho: Path2D) -> void:

	if caminho == null:
		push_warning("Configure os caminhos no Inspetor.")
		return

	var posicao_atual: Vector2 = global_position

	carregar_caminho(caminho)

	if pontos.size() > 0:
		if posicao_atual.distance_to(pontos[0]) < 20.0:
			indice_ponto = 1

	esperando_escolha = false
	caminho_escolhido = true
	movendo_para_ponto = false

	if caminho == caminho_esquerdo:
		direcao_escolhida = -1
	else:
		direcao_escolhida = 1

	velocity = Vector2.ZERO
	tocar_animacao("parada")


# ==========================================
# VOLTAR UM PONTO
# ==========================================

func voltar_ponto() -> void:

	if movendo_para_ponto:
		return

	if not caminho_escolhido:

		if indice_ponto > 1:
			indice_ponto -= 2
			movendo_para_ponto = true
			esperando_escolha = false

		return

	if indice_ponto > 1:

		indice_ponto -= 2
		movendo_para_ponto = true

	else:

		if rota_atual == caminho_esquerdo or rota_atual == caminho_direito:

			global_position = pontos[0]
			velocity = Vector2.ZERO

			caminho_escolhido = false
			direcao_escolhida = 0
			esperando_escolha = true

			carregar_caminho(caminho_inicial)

			indice_ponto = pontos.size()

			tocar_animacao("parada")


# ==========================================
# ANIMAÇÕES
# ==========================================

func tocar_animacao(nome: String) -> void:

	if animated_sprite.sprite_frames == null:
		return

	if animated_sprite.sprite_frames.has_animation(nome):

		if animated_sprite.animation != nome:
			animated_sprite.play(nome)


# ==========================================
# DERROTAR INIMIGOS NAS FASES ANTIGAS
# ==========================================

func verificar_inimigos() -> void:

	for i in range(get_slide_collision_count()):

		var colisao = get_slide_collision(i)
		var objeto = colisao.get_collider()

		if objeto is Node2D and objeto.is_in_group("inimigo"):

			if velocity.y > 0 and colisao.get_normal().y < -0.5:

				if objeto.has_method("morrer"):
					objeto.morrer()

				velocity.y = FORCA_PULO * 0.75
				estava_pulando = true


# ==========================================
# MORTE DA PRINCESA
# ==========================================

func morrer() -> void:

	if esta_morrendo:
		return

	esta_morrendo = true

	print("Princesa morreu!")

	# Retira somente as moedas da fase atual
	Pontuacao.morreu_na_fase()

	# Reinicia a fase atual
	get_tree().call_deferred("reload_current_scene")

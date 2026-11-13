extends CharacterBody2D

const SPEED = 80.0
const JUMP_VELOCITY = -450.0
const FLOOR_Y = 700.0
const DISTANCIA_X = 25.0

@onready var animated_sprite = $AnimatedSprite2D

var detector_chao: RayCast2D = null
var detector_obstaculo: RayCast2D = null
var portal: Area2D = null

var posicao_inicial: Vector2
var iniciou_corrida = false
var indice_ponto = 0
var pontos_rota: Array[Marker2D] = []
var aguardando_aterrissagem = false
var reiniciando = false


func _ready() -> void:
	posicao_inicial = global_position

	# Diagnóstico da colisão do Player 2
	var colisao = get_node_or_null("CollisionShape2D")

	if colisao != null:
		print("=== DIAGNÓSTICO DO PLAYER 2 ===")
		print("Camada: ", collision_layer)
		print("Máscara: ", collision_mask)
		print("Forma: ", colisao.shape)
		print("Colisão desativada: ", colisao.disabled)
	else:
		push_error("Player 2: CollisionShape2D não encontrado!")

	# Encontrar os detectores
	for filho in get_children():
		if filho is RayCast2D:
			var nome = filho.name.to_lower()

			if "chao" in nome or "chão" in nome:
				detector_chao = filho
			elif "obstaculo" in nome or "obstáculo" in nome:
				detector_obstaculo = filho

	if detector_chao == null:
		push_error("Detector de chão não encontrado.")

	if detector_obstaculo == null:
		push_error("Detector de obstáculo não encontrado.")

	# Encontrar a rota do Player 2
	var rota = get_node_or_null("../RotasPlayer2/Caminho1")

	if rota == null:
		push_error("Não encontrei RotasPlayer2/Caminho1.")
		return

	# Organizar os pontos da rota
	for nome_ponto in ["ponto4", "ponto3", "ponto2", "ponto1"]:
		var ponto = rota.get_node_or_null(nome_ponto)

		if ponto is Marker2D:
			pontos_rota.append(ponto)
		else:
			push_error("Não encontrei o ponto: " + nome_ponto)

	# Encontrar o portal
	portal = get_node_or_null("../portal")

	if portal == null:
		push_error("Portal não encontrado em ../portal.")
	else:
		print("Portal encontrado: ", portal.name)


func _physics_process(delta: float) -> void:

	# Parar completamente enquanto espera no portal
	if reiniciando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Reiniciar se cair para fora da fase
	if global_position.y > FLOOR_Y:
		voltar_ao_inicio()
		return

	# Queda inicial até o primeiro bloco
	if not iniciou_corrida:
		velocity.x = 0.0

		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		else:
			velocity.y = 0.0
			iniciou_corrida = true

		move_and_slide()
		return

	# Aplicar gravidade
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Atualizar os detectores
	if detector_chao != null:
		detector_chao.force_raycast_update()

	if detector_obstaculo != null:
		detector_obstaculo.force_raycast_update()

	# Seguir os pontos da rota
	if indice_ponto < pontos_rota.size():

		var destino = pontos_rota[indice_ponto].global_position
		var diferenca = destino - global_position

		velocity.x = sign(diferenca.x) * SPEED
		animated_sprite.flip_h = diferenca.x < 0

		# Verificar se não há chão
		var sem_chao = (
			detector_chao != null
			and not detector_chao.is_colliding()
		)

		# Verificar obstáculos
		var tem_obstaculo = (
			detector_obstaculo != null
			and detector_obstaculo.is_colliding()
		)

		# Pular ao detectar uma borda ou obstáculo
		if is_on_floor() and not aguardando_aterrissagem:
			if sem_chao or tem_obstaculo:
				velocity.y = JUMP_VELOCITY
				aguardando_aterrissagem = true

		# Avançar o ponto depois de aterrissar
		if aguardando_aterrissagem and is_on_floor():
			if abs(global_position.x - destino.x) <= DISTANCIA_X:
				indice_ponto += 1
				aguardando_aterrissagem = false

	# Depois do último ponto, continuar em direção ao portal
	else:
		velocity.x = SPEED
		animated_sprite.flip_h = false

	# Controlar animação
	if is_on_floor():
		animated_sprite.play("correndo")
	else:
		animated_sprite.play("pulando")

	move_and_slide()


# Função chamada pelo portal
func reiniciar_depois_do_portal() -> void:

	if reiniciando:
		return

	# Parar o personagem imediatamente
	reiniciando = true
	velocity = Vector2.ZERO

	print("Player 2 chegou ao portal!")
	print("Esperando 2 segundos...")

	# Esperar 2 segundos
	await get_tree().create_timer(2.0).timeout

	# Voltar à posição inicial
	global_position = posicao_inicial
	velocity = Vector2.ZERO

	# Reiniciar a rota
	indice_ponto = 0
	aguardando_aterrissagem = false
	iniciou_corrida = false

	print("Player 2 voltou ao início!")

	# Liberar a movimentação
	reiniciando = false

	animated_sprite.play("correndo")


# Reiniciar se cair da fase
func voltar_ao_inicio() -> void:

	global_position = posicao_inicial
	velocity = Vector2.ZERO

	indice_ponto = 0
	aguardando_aterrissagem = false
	iniciou_corrida = false

	animated_sprite.play("correndo")

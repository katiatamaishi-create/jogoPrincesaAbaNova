extends Area2D

var portal_ativado: bool = false


func _ready() -> void:
	print("Portal pronto: ", name)


func _on_body_entered(body: Node2D) -> void:

	print("Um objeto entrou no portal: ", body.name)

	if portal_ativado:
		return

	# Verifica se entrou um dos jogadores
	if body.name != "player1" and body.name != "player2":
		return

	portal_ativado = true

	# Se o Player 2 entrar, reinicia a cena
	if body.name == "player2":
		print("Player 2 entrou! Reiniciando a cena...")
		get_tree().call_deferred("reload_current_scene")
		return

	# Verifica em qual fase o jogador está
	var fase_atual: String = get_tree().current_scene.scene_file_path

	# Define a próxima fase
	var proxima_fase: String = ""

	match fase_atual:

		# Fase 1 vai para a fase 3
		"res://fase_1.tscn":
			proxima_fase = "res://fase_3.tscn"

		# Fase 3: jogador venceu!
		"res://fase_3.tscn":
			print("Parabéns! Você venceu o jogo!")

			Pontuacao.concluir_fase()

			# Mostra a tela de vitória
			get_tree().current_scene.get_node("CanvasLayer").mostrar_vitoria()
			return

		_:
			print("Fase não cadastrada: ", fase_atual)
			portal_ativado = false
			return

	# Verifica se a próxima fase existe
	if not ResourceLoader.exists(proxima_fase):
		print("ERRO: arquivo não encontrado: ", proxima_fase)
		portal_ativado = false
		return

	# Salva as moedas da fase concluída
	Pontuacao.concluir_fase()

	print("Avançando para: ", proxima_fase)

	get_tree().call_deferred("change_scene_to_file", proxima_fase)

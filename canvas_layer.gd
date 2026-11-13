extends CanvasLayer

@onready var label_moedas: Label = $LabelMoedas
@onready var tela_vitoria: TextureRect = $TelaVitoria


func _ready() -> void:

	# Garante que o contador esteja visível
	visible = true
	label_moedas.visible = true

	# Esconde a tela de vitória no início
	tela_vitoria.visible = false

	# Posiciona o contador no canto superior esquerdo
	label_moedas.position = Vector2(20, 20)

	# Configura a aparência do texto
	label_moedas.add_theme_color_override("font_color", Color.WHITE)
	label_moedas.add_theme_color_override("font_outline_color", Color.BLACK)
	label_moedas.add_theme_constant_override("outline_size", 5)
	label_moedas.add_theme_font_size_override("font_size", 24)

	# Conecta ao sistema de pontuação
	Pontuacao.pontuacao_alterada.connect(atualizar_contador)

	# Atualiza os valores iniciais
	atualizar_contador(Pontuacao.moedas, Pontuacao.pontos)


func atualizar_contador(moedas: int, pontos: int) -> void:

	label_moedas.text = "Moedas: %d | Pontos: %d" % [moedas, pontos]

	print("Contador atualizado na tela!")


func mostrar_vitoria() -> void:

	print("Jogador venceu o jogo!")

	tela_vitoria.visible = true

	# Esconde o contador
	label_moedas.visible = false

	# Pausa o jogo
	get_tree().paused = true

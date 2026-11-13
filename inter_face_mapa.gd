extends Control

@onready var botao_mapa: Button = $BotaoMapa
@onready var painel_mapa: ColorRect = $PainelMapa
@onready var botao_fechar: Button = $PainelMapa/FecharMapa


func _ready() -> void:
	# O mapa começa escondido.
	painel_mapa.hide()

	# Conecta os botões.
	botao_mapa.pressed.connect(abrir_mapa)
	botao_fechar.pressed.connect(fechar_mapa)


func abrir_mapa() -> void:
	# Mostra o mapa.
	painel_mapa.show()

	# Pausa o jogo enquanto o jogador consulta o mapa.
	get_tree().paused = true


func fechar_mapa() -> void:
	# Esconde o mapa.
	painel_mapa.hide()

	# Continua o jogo.
	get_tree().paused = false

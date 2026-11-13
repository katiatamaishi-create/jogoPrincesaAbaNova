extends Node

signal pontuacao_alterada(moedas: int, pontos: int)

var moedas: int = 0
var pontos: int = 0

# Moedas e pontos coletados somente na fase atual
var moedas_fase: int = 0
var pontos_fase: int = 0


func adicionar_moeda() -> void:
	moedas += 1
	pontos += 10

	moedas_fase += 1
	pontos_fase += 10

	print("Moedas totais: ", moedas)
	print("Pontos totais: ", pontos)

	pontuacao_alterada.emit(moedas, pontos)


# Quando a princesa morrer
func morreu_na_fase() -> void:

	# Retira somente o que foi coletado na fase atual
	moedas -= moedas_fase
	pontos -= pontos_fase

	# Zera o controle da fase atual
	moedas_fase = 0
	pontos_fase = 0

	print("Princesa morreu!")
	print("Moedas restantes: ", moedas)
	print("Pontos restantes: ", pontos)

	pontuacao_alterada.emit(moedas, pontos)


# Quando a princesa avançar para outra fase
func concluir_fase() -> void:

	# Mantém os pontos conquistados
	moedas_fase = 0
	pontos_fase = 0

	print("Fase concluída!")

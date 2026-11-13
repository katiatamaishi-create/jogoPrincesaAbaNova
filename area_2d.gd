extends Area2D

var coletada: bool = false

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	# Somente o player1 pode coletar moedas
	if body.name != "player1":
		return

	if coletada:
		return

	coletada = true

	Pontuacao.adicionar_moeda()

	$animacao.play("pegar")

func _on_animation_finished() -> void:
	queue_free()

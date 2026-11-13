extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verifica se foi a princesa que caiu
	if body.name == "player1":
		print("A princesa caiu no buraco!")

		# Chama a função que desconta as moedas e os pontos
		body.morrer()

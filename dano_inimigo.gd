extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player1":
		# Fazer a princesa pular ao atingir o inimigo por cima
		body.velocity.y = -400.0

		# Encontrar o inimigo e derrotá-lo
		var inimigo = get_parent()

		if inimigo.has_method("morrer"):
			inimigo.morrer()

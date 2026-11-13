extends Area2D


func _ready() ->void:
	
	
	pass


func _process(delta: float) -> void:
	pass
	

func _on_body_entered(body: Node2D) -> void:
	var cena = get_tree().current_scene
	print(cena.name)
	print(body.name)
	if cena.name == "fase1" and body.name == "player":
		get_tree().change_scene_to_file("res://fase_2.tscn")
	elif cena.name == "fase2" and body.name == "player":
		get_tree().change_scene_to_file("res://fase_1.tscn")

	# =========================
	# GRAVIDADE
	# =========================
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## =========================
	## PULO
	## =========================
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#animated_sprite.play("Jump")
#
	## =========================
	## MOVIMENTO
	## =========================
	#var direction := Input.get_axis("ui_left", "ui_right")
#
	#if direction != 0:
		#velocity.x = direction * SPEED

		# Animação

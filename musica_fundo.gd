extends Node

var musica: AudioStreamPlayer

func _ready() -> void:
	musica = AudioStreamPlayer.new()
	musica.name = "MusicaFundo"
	musica.stream = load("res://musicas/musica_fundo.mp3")
	musica.volume_db = -15
	musica.finished.connect(repetir_musica)
	add_child(musica)
	musica.play()

func repetir_musica() -> void:
	musica.play()

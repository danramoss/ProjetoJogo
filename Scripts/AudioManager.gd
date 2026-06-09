extends Node
## AudioManager (Autoload / Singleton)
##
## Toca os efeitos sonoros do jogo.
##
## IMPORTANTE: O projeto NAO inclui os arquivos de som (sao opcionais).
## Este sistema ja esta pronto para recebe-los: basta colocar os arquivos
## .wav em "res://Assets/Audio/" com os nomes esperados abaixo. Se um arquivo
## nao existir, o som simplesmente e ignorado (sem erro), mantendo o jogo
## funcionando normalmente.

# Mapa "nome do efeito" -> "caminho do arquivo".
const SOUNDS: Dictionary = {
	"coleta":     "res://Assets/Audio/som_coleta.wav",
	"dourada":    "res://Assets/Audio/som_dourada.wav",
	"congelante": "res://Assets/Audio/som_congelante.wav",
	"podre":      "res://Assets/Audio/som_podre.wav",
	"gameover":   "res://Assets/Audio/som_gameover.wav",
}

# Player reutilizado para tocar os sons.
var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)


## Toca o som correspondente ao nome (ex: "coleta", "podre").
## Se o arquivo nao existir, nao faz nada.
func play(sound_name: String) -> void:
	if not SOUNDS.has(sound_name):
		return

	var path: String = SOUNDS[sound_name]
	if not ResourceLoader.exists(path):
		return  # arquivo de audio ainda nao foi adicionado — ignora

	var stream: AudioStream = load(path)
	if stream != null:
		_player.stream = stream
		_player.play()

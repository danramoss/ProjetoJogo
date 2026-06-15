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

# Caminho da musica de fundo (toca em loop continuo durante todo o jogo).
const MUSIC_PATH: String = "res://Assets/Audio/musica_fundo.wav"

# Volume da musica de fundo, em decibeis (negativo = mais baixo que os efeitos).
const MUSIC_VOLUME_DB: float = -9.0

# Player reutilizado para tocar os efeitos sonoros.
var _player: AudioStreamPlayer

# Player exclusivo para a musica de fundo.
var _music_player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = MUSIC_VOLUME_DB
	add_child(_music_player)

	# Como o AudioManager e um Autoload, a musica continua tocando mesmo
	# ao trocar de cena (menu -> jogo -> game over).
	_start_music()


## Inicia a musica de fundo em loop. Se o arquivo nao existir, nao faz nada.
func _start_music() -> void:
	if not ResourceLoader.exists(MUSIC_PATH):
		return

	var stream: AudioStream = load(MUSIC_PATH)
	# Configura o loop do arquivo .wav para repetir sem parar.
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)

	_music_player.stream = stream
	_music_player.play()


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

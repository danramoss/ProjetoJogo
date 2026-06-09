extends Node
## SaveManager (Autoload / Singleton)
##
## Responsavel por carregar e salvar o RECORDE (highscore) em disco,
## usando um arquivo JSON simples.
##
## OBS academica: usamos "res://Data/savegame.json" porque o projeto roda
## pelo editor da Godot, onde a pasta res:// e gravavel. Em um jogo EXPORTADO
## a pasta res:// fica somente-leitura; nesse caso o ideal seria trocar por
## "user://savegame.json" (a Godot cria automaticamente). A logica abaixo ja
## esta pronta — basta mudar a constante SAVE_PATH.

const SAVE_PATH: String = "res://Data/savegame.json"

# Mantem o recorde em memoria enquanto o jogo roda.
var highscore: int = 0

# Guarda a pontuacao da ULTIMA partida para a tela de Game Over ler.
# (Autoload mantem este valor vivo durante a troca de cenas.)
var last_score: int = 0
var last_is_new_record: bool = false


func _ready() -> void:
	load_highscore()


## Le o arquivo JSON e carrega o recorde. Se nao existir, cria com valor 0.
func load_highscore() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		highscore = 0
		save_highscore(highscore)  # cria o arquivo pela primeira vez
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		highscore = 0
		return

	var content := file.get_as_text()
	file.close()

	# Converte o texto JSON em dados utilizaveis.
	var data: Variant = JSON.parse_string(content)
	if typeof(data) == TYPE_DICTIONARY and data.has("highscore"):
		highscore = int(data["highscore"])
	else:
		highscore = 0


## Grava um novo recorde no arquivo JSON.
func save_highscore(value: int) -> void:
	highscore = value
	var data := { "highscore": highscore }

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: nao foi possivel gravar o recorde.")
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()


## Verifica se 'score' e um novo recorde. Se for, salva e retorna true.
func try_update_highscore(score: int) -> bool:
	if score > highscore:
		save_highscore(score)
		return true
	return false

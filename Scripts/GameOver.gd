extends Control
## GameOver.gd — TELA DE FIM DE JOGO.
##
## Mostra a pontuacao final e o recorde, e oferece dois botoes:
## Jogar Novamente e Voltar ao Menu.

@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var highscore_label: Label = $Panel/VBox/HighscoreLabel
@onready var record_label: Label = $Panel/VBox/RecordLabel


func _ready() -> void:
	# Le os dados da ultima partida (guardados no SaveManager).
	score_label.text = "Pontuacao Final: %d" % SaveManager.last_score
	highscore_label.text = "Recorde: %d" % SaveManager.highscore

	# Mensagem especial se o jogador bateu o recorde.
	if SaveManager.last_is_new_record:
		record_label.text = "NOVO RECORDE!"
		record_label.visible = true
	else:
		record_label.visible = false

	# Conecta os botoes.
	$Panel/VBox/PlayAgainButton.pressed.connect(_on_play_again_pressed)
	$Panel/VBox/MenuButton.pressed.connect(_on_menu_pressed)


## Botao JOGAR NOVAMENTE -> recarrega a cena do jogo.
func _on_play_again_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Game.tscn")


## Botao VOLTAR AO MENU -> volta para o menu principal.
func _on_menu_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu.tscn")

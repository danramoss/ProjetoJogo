extends Control
## MainMenu.gd — logica do MENU PRINCIPAL.
##
## Controla os tres botoes (Jogar, Instrucoes, Sair) e o painel de
## instrucoes (que aparece/some por cima do menu).

# Painel de instrucoes (comeca invisivel).
@onready var instructions_panel: Panel = $InstructionsPanel


func _ready() -> void:
	instructions_panel.visible = false

	# Conecta os botoes as suas funcoes.
	$MenuButtons/PlayButton.pressed.connect(_on_play_pressed)
	$MenuButtons/InstructionsButton.pressed.connect(_on_instructions_pressed)
	$MenuButtons/QuitButton.pressed.connect(_on_quit_pressed)
	$InstructionsPanel/CloseButton.pressed.connect(_on_close_instructions_pressed)


## Botao JOGAR -> vai para a cena do jogo (com transicao).
func _on_play_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Game.tscn")


## Botao INSTRUCOES -> mostra o painel de instrucoes.
func _on_instructions_pressed() -> void:
	instructions_panel.visible = true


## Botao FECHAR (dentro das instrucoes) -> esconde o painel.
func _on_close_instructions_pressed() -> void:
	instructions_panel.visible = false


## Botao SAIR -> encerra o jogo.
func _on_quit_pressed() -> void:
	get_tree().quit()

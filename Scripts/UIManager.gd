extends CanvasLayer
## UIManager.gd — controla a INTERFACE (HUD) durante o jogo.
##
## Mostra a pontuacao, o tempo e o nivel de dificuldade, e cria os
## "textos flutuantes" (ex: +10, -20, +5 segundos) que aparecem e somem
## quando o jogador coleta uma fruta.
##
## Este script fica no no HUD (um CanvasLayer) da cena Game.

# Referencias aos Labels da HUD (definidos na cena Game.tscn).
@onready var score_label: Label = $ScoreLabel
@onready var time_label: Label = $TimeLabel
@onready var level_label: Label = $LevelLabel


## Atualiza o texto da pontuacao.
func update_score(score: int) -> void:
	score_label.text = "Pontos: %d" % score


## Atualiza o texto do tempo restante.
func update_time(seconds: int) -> void:
	time_label.text = "Tempo: %d" % seconds
	# Deixa o tempo vermelho nos ultimos 10 segundos (alerta visual).
	if seconds <= 10:
		time_label.add_theme_color_override("font_color", Color("#e74c3c"))
	else:
		time_label.add_theme_color_override("font_color", Color.WHITE)


## Atualiza o texto do nivel de dificuldade.
func update_level(level: int) -> void:
	level_label.text = "Nivel: %d" % level


## Cria um texto flutuante na posicao indicada (em coordenadas de tela).
## Ele sobe um pouco e some (fade out), depois se autodestroi.
func show_floating_text(text: String, world_position: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", color)
	# Contorno preto para o texto ficar legivel sobre qualquer fundo.
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.position = world_position
	label.z_index = 50
	add_child(label)

	# Animacao: sobe 60px e some em 0.8s; depois remove o label.
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", world_position.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)

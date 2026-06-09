extends CanvasLayer
## SceneTransition (Autoload / Singleton)
##
## Faz uma transicao suave (fade preto) ao trocar de cena.
## Como e um Autoload do tipo CanvasLayer, ele fica SEMPRE por cima de
## qualquer cena, desenhando um retangulo preto que aparece e some.
##
## Uso:  SceneTransition.change_scene("res://Scenes/Game.tscn")

var _rect: ColorRect
const FADE_TIME: float = 0.35


func _ready() -> void:
	# Garante que a transicao fique acima de tudo.
	layer = 100

	# Cria o retangulo preto que cobre a tela inteira.
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)  # comeca transparente
	_rect.anchor_right = 1.0
	_rect.anchor_bottom = 1.0
	# Nao bloqueia cliques quando esta invisivel.
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


## Escurece a tela, troca de cena e clareia novamente.
func change_scene(path: String) -> void:
	# 1) Fade para preto.
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 1.0, FADE_TIME)
	await tween.finished

	# 2) Troca a cena de fato.
	get_tree().change_scene_to_file(path)

	# 3) Fade de volta (clareia).
	var tween2 := create_tween()
	tween2.tween_property(_rect, "color:a", 0.0, FADE_TIME)

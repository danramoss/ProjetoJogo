extends Node2D
## GameManager.gd — o CEREBRO da partida.
##
## Fica na raiz da cena Game.tscn e coordena tudo:
##   - guarda a pontuacao (score) e o tempo restante (time_left);
##   - reage quando uma fruta e coletada (aplica o efeito de cada tipo);
##   - controla o cronometro e a dificuldade progressiva;
##   - encerra a partida quando o tempo acaba e abre a tela de Game Over.

# Referencias aos nos filhos da cena Game.
@onready var player: Area2D = $Player
@onready var spawner: Node = $Spawner
@onready var hud: CanvasLayer = $HUD

# Estado da partida.
var score: int = 0
var time_left: int = GameConfig.START_TIME

# Cronometro de 1 segundo (criado por codigo).
var _game_timer: Timer


func _ready() -> void:
	# Quando o jogador pega uma fruta, _on_fruit_caught e chamado.
	player.fruit_caught.connect(_on_fruit_caught)

	# Cria o cronometro que conta o tempo da partida.
	_game_timer = Timer.new()
	_game_timer.wait_time = 1.0
	_game_timer.one_shot = false
	_game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(_game_timer)

	# Mostra os valores iniciais na HUD.
	hud.update_score(score)
	hud.update_time(time_left)
	hud.update_level(GameConfig.get_level_for_score(score))

	# Define a velocidade inicial das frutas e inicia o jogo.
	_update_difficulty()
	spawner.start_spawning()
	_game_timer.start()


## Chamado quando uma fruta toca a cesta. Aplica o efeito conforme o tipo.
func _on_fruit_caught(fruit: Fruit) -> void:
	# Tenta coletar UMA UNICA VEZ. Se esta fruta ja foi coletada (a colisao
	# pode disparar mais de uma vez), try_catch() retorna false e saimos —
	# garantindo que o valor seja contado apenas uma vez.
	if not fruit.try_catch():
		return

	match fruit.fruit_type:
		GameConfig.FruitType.GOLDEN:
			_add_score(GameConfig.POINTS_GOLDEN)
			hud.show_floating_text("+%d" % GameConfig.POINTS_GOLDEN, fruit.position, GameConfig.COLOR_GOLDEN)
			AudioManager.play("dourada")

		GameConfig.FruitType.FREEZE:
			_add_time(GameConfig.FREEZE_BONUS_SECONDS)
			hud.show_floating_text("+%d segundos" % GameConfig.FREEZE_BONUS_SECONDS, fruit.position, GameConfig.COLOR_FREEZE)
			AudioManager.play("congelante")

		GameConfig.FruitType.ROTTEN:
			_add_score(-GameConfig.POINTS_ROTTEN_PENALTY)
			hud.show_floating_text("-%d" % GameConfig.POINTS_ROTTEN_PENALTY, fruit.position, Color("#c0392b"))
			AudioManager.play("podre")

		_:  # qualquer fruta normal (maca, banana, laranja, morango)
			_add_score(fruit.points)
			hud.show_floating_text("+%d" % fruit.points, fruit.position, Color.WHITE)
			AudioManager.play("coleta")

	# Anima a fruta sumindo e atualiza a HUD.
	fruit.play_collect_animation()
	hud.update_score(score)
	hud.update_level(GameConfig.get_level_for_score(score))


## Soma (ou subtrai) pontos. A pontuacao NUNCA fica negativa.
func _add_score(amount: int) -> void:
	score = max(0, score + amount)
	_update_difficulty()


## Adiciona segundos ao cronometro (fruta congelante).
func _add_time(seconds: int) -> void:
	time_left += seconds
	hud.update_time(time_left)


## Ajusta a velocidade de queda das frutas conforme a pontuacao atual.
func _update_difficulty() -> void:
	var speed := GameConfig.get_fall_speed_for_score(score)
	spawner.set_fall_speed(speed)


## Chamado a cada 1 segundo: diminui o tempo e verifica o fim de jogo.
func _on_game_timer_timeout() -> void:
	time_left -= 1
	hud.update_time(time_left)

	if time_left <= 0:
		_end_game()


## Encerra a partida: para tudo, salva o recorde e abre o Game Over.
func _end_game() -> void:
	_game_timer.stop()
	spawner.stop_spawning()

	# Guarda a pontuacao final e verifica se e um novo recorde.
	SaveManager.last_score = score
	SaveManager.last_is_new_record = SaveManager.try_update_highscore(score)

	AudioManager.play("gameover")

	# Pequena espera para o som/feedback antes de trocar de cena.
	await get_tree().create_timer(0.6).timeout
	SceneTransition.change_scene("res://Scenes/GameOver.tscn")

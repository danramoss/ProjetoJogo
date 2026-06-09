extends Node
## Spawner.gd — cria as frutas que caem do topo da tela.
##
## Usa um Timer (criado por codigo) que dispara a cada 1 segundo.
## A cada disparo, sorteia QUAL fruta criar usando as probabilidades:
##   - Frutas normais: 80%
##   - Fruta dourada:   5%
##   - Fruta congelante:5%
##   - Fruta podre:     10%

# Cenas das frutas, carregadas uma vez (preload e mais eficiente).
# As frutas normais sao 4 cenas distintas (cada uma com sua imagem).
const APPLE_SCENE := preload("res://Scenes/Apple.tscn")
const BANANA_SCENE := preload("res://Scenes/Banana.tscn")
const ORANGE_SCENE := preload("res://Scenes/Orange.tscn")
const STRAWBERRY_SCENE := preload("res://Scenes/Strawberry.tscn")
const GOLDEN_SCENE := preload("res://Scenes/GoldenFruit.tscn")
const FREEZE_SCENE := preload("res://Scenes/FreezeFruit.tscn")
const ROTTEN_SCENE := preload("res://Scenes/RottenFruit.tscn")

# Lista das frutas normais para sorteio.
var _normal_scenes: Array = [APPLE_SCENE, BANANA_SCENE, ORANGE_SCENE, STRAWBERRY_SCENE]

# Margem nas laterais para a fruta nao nascer colada na borda.
const SPAWN_MARGIN: float = 40.0

# Velocidade de queda atual (atualizada pelo GameManager conforme a
# dificuldade aumenta).
var current_fall_speed: float = GameConfig.SPEED_LEVEL_1

# Timer que controla o ritmo de criacao das frutas.
var _timer: Timer


func _ready() -> void:
	# Cria o Timer por codigo e o configura.
	_timer = Timer.new()
	_timer.wait_time = GameConfig.SPAWN_INTERVAL
	_timer.one_shot = false  # repete em loop
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)


## Define a velocidade de queda das proximas frutas (chamado pelo GameManager).
func set_fall_speed(speed: float) -> void:
	current_fall_speed = speed


## Comeca a criar frutas.
func start_spawning() -> void:
	_timer.start()


## Para de criar frutas (usado no fim de partida).
func stop_spawning() -> void:
	_timer.stop()


## Chamado a cada 1 segundo: sorteia e cria uma fruta.
func _on_timer_timeout() -> void:
	var fruit: Fruit = _create_random_fruit()

	# Posicao X aleatoria dentro da tela; Y acima do topo.
	var min_x := SPAWN_MARGIN
	var max_x := GameConfig.SCREEN_WIDTH - SPAWN_MARGIN
	fruit.position = Vector2(randf_range(min_x, max_x), -40.0)
	fruit.fall_speed = current_fall_speed

	# Adiciona a fruta na cena (como filha da cena principal do jogo).
	get_parent().add_child(fruit)


## Sorteia um numero de 1 a 100 e decide qual fruta criar.
func _create_random_fruit() -> Fruit:
	var sorteio := randi_range(1, 100)

	if sorteio <= GameConfig.PROB_NORMAL:
		# 1..80  -> fruta normal (sorteia uma das 4: maca, banana, laranja, morango)
		var cena: PackedScene = _normal_scenes[randi() % _normal_scenes.size()]
		return cena.instantiate()
	elif sorteio <= GameConfig.PROB_NORMAL + GameConfig.PROB_GOLDEN:
		# 81..85 -> dourada
		return GOLDEN_SCENE.instantiate()
	elif sorteio <= GameConfig.PROB_NORMAL + GameConfig.PROB_GOLDEN + GameConfig.PROB_FREEZE:
		# 86..90 -> congelante
		return FREEZE_SCENE.instantiate()
	else:
		# 91..100 -> podre
		return ROTTEN_SCENE.instantiate()

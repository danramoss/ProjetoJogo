extends Area2D
class_name Fruit
## Fruit.gd — CLASSE BASE de todas as frutas.
##
## Toda fruta do jogo herda deste script (GoldenFruit, FreezeFruit e
## RottenFruit usam "extends Fruit"). Aqui fica o comportamento comum:
##   - cair de cima para baixo;
##   - ser removida ao sair da tela;
##   - guardar quantos pontos vale e qual o seu tipo.
##
## A APARENCIA (imagem) NAO fica neste codigo: cada cena de fruta tem um
## no Sprite2D com a sua imagem (em Assets/Sprites/). O tipo e a pontuacao
## sao definidos na propria cena (no Inspector), atraves das variaveis
## exportadas abaixo.
##
## A colisao com a cesta e detectada pelo PLAYER, que entao chama o
## GameManager para aplicar o efeito desta fruta.

# Tipo da fruta (ver enum em GameConfig.FruitType). Definido na cena.
@export var fruit_type: int = GameConfig.FruitType.APPLE

# Quantos pontos esta fruta vale ao ser coletada. Definido na cena.
@export var points: int = GameConfig.POINTS_APPLE

# Velocidade de queda (pixels por segundo). O Spawner define este valor
# de acordo com a dificuldade atual.
var fall_speed: float = GameConfig.SPEED_LEVEL_1

# Trava de seguranca: fica "true" assim que a fruta e coletada, garantindo
# que o efeito (pontos/tempo) seja aplicado UMA UNICA VEZ, mesmo que a
# colisao dispare mais de um quadro.
var collected: bool = false


func _ready() -> void:
	# Coloca a fruta no grupo "fruits" para que o jogo possa limpa-las
	# todas de uma vez no fim de partida.
	add_to_group("fruits")


func _process(delta: float) -> void:
	# Movimento de queda: desce no eixo Y.
	position.y += fall_speed * delta

	# Se passou do fundo da tela, remove a fruta (economia de memoria).
	if position.y - 40.0 > GameConfig.SCREEN_HEIGHT:
		queue_free()


## Tenta coletar a fruta UMA UNICA VEZ.
## Retorna true apenas na primeira chamada; nas seguintes retorna false.
## Tambem desliga a colisao na hora, para a fruta nao ser detectada de novo.
func try_catch() -> bool:
	if collected:
		return false
	collected = true
	# Usamos set_deferred porque nao se pode alterar a colisao durante o
	# processamento da fisica (quando este metodo e chamado).
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	return true


## Chamado pelo GameManager logo antes de remover a fruta:
## faz uma animacao rapida (cresce e some) para dar feedback visual.
## Isto anima a IMAGEM (Sprite2D), nao desenha nada.
func play_collect_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.chain().tween_callback(queue_free)

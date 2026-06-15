extends Node
## GameConfig (Autoload / Singleton)
##
## Centraliza TODAS as constantes do jogo num lugar so.
## Assim a banca consegue ajustar pontos, velocidades, tempos e cores
## sem precisar caçar numeros espalhados pelo codigo.

# ---------------------------------------------------------------------------
# TELA
# ---------------------------------------------------------------------------
const SCREEN_WIDTH: int = 1280
const SCREEN_HEIGHT: int = 720

# ---------------------------------------------------------------------------
# TEMPO
# ---------------------------------------------------------------------------
const START_TIME: int = 60          # segundos iniciais do cronometro
const FREEZE_BONUS_SECONDS: int = 5 # segundos que a fruta congelante adiciona

# ---------------------------------------------------------------------------
# PONTUACAO DAS FRUTAS
# ---------------------------------------------------------------------------
const POINTS_APPLE: int = 10
const POINTS_BANANA: int = 15
const POINTS_ORANGE: int = 20
const POINTS_STRAWBERRY: int = 30
const POINTS_GOLDEN: int = 100
const POINTS_ROTTEN_PENALTY: int = 100  # quanto a fruta podre SUBTRAI

# ---------------------------------------------------------------------------
# TIPOS DE FRUTA (usado para identificar cada fruta no codigo)
# ---------------------------------------------------------------------------
enum FruitType { APPLE, BANANA, ORANGE, STRAWBERRY, GOLDEN, FREEZE, ROTTEN }

# ---------------------------------------------------------------------------
# CORES PROCEDURAIS
# Como nao usamos imagens, cada fruta e desenhada com estas cores.
# ---------------------------------------------------------------------------
const COLOR_APPLE: Color = Color("#e74c3c")       # vermelho
const COLOR_BANANA: Color = Color("#f1c40f")      # amarelo
const COLOR_ORANGE: Color = Color("#e67e22")      # laranja
const COLOR_STRAWBERRY: Color = Color("#ff4d6d")  # rosa/vermelho
const COLOR_GOLDEN: Color = Color("#ffd700")      # dourado
const COLOR_FREEZE: Color = Color("#5dade2")      # azul gelo
const COLOR_ROTTEN: Color = Color("#4d3b2a")      # marrom escuro (estragada)

# ---------------------------------------------------------------------------
# PROBABILIDADES DE SPAWN (devem somar 100)
# ---------------------------------------------------------------------------
const PROB_NORMAL: int = 80   # qualquer fruta normal
const PROB_GOLDEN: int = 5
const PROB_FREEZE: int = 5
const PROB_ROTTEN: int = 10

# Intervalo (em segundos) entre cada spawn de fruta.
const SPAWN_INTERVAL: float = 1.0

# ---------------------------------------------------------------------------
# DIFICULDADE PROGRESSIVA
# A velocidade de queda aumenta conforme a pontuacao do jogador.
# ---------------------------------------------------------------------------
const SPEED_LEVEL_1: float = 400.0   # score 0   a 99
const SPEED_LEVEL_2: float = 600.0   # score 100 a 299
const SPEED_LEVEL_3: float = 800.0   # score 300 a 499
const SPEED_LEVEL_4: float = 1000.0  # score 500 ou mais


## Retorna a velocidade de queda atual de acordo com a pontuacao.
func get_fall_speed_for_score(score: int) -> float:
	if score >= 500:
		return SPEED_LEVEL_4
	elif score >= 300:
		return SPEED_LEVEL_3
	elif score >= 100:
		return SPEED_LEVEL_2
	else:
		return SPEED_LEVEL_1


## Retorna o numero do nivel de dificuldade atual (1 a 4) — util para a HUD.
func get_level_for_score(score: int) -> int:
	if score >= 500:
		return 4
	elif score >= 300:
		return 3
	elif score >= 100:
		return 2
	else:
		return 1

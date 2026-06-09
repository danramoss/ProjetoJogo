extends Area2D
## Player.gd — a CESTA controlada pelo jogador.
##
## Move-se apenas na horizontal (esquerda/direita), sem sair da tela.
## Detecta a colisao com as frutas e avisa o GameManager pelo sinal
## "fruit_caught".

# Velocidade de movimento da cesta (pixels por segundo).
const SPEED: float = 500.0

# Meia-largura da cesta, usada para travar nas bordas da tela.
const HALF_WIDTH: float = 60.0

# Emitido quando uma fruta toca a cesta. Envia a propria fruta.
signal fruit_caught(fruit: Fruit)


func _ready() -> void:
	# Quando uma area (fruta) entra na cesta, chama _on_area_entered.
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	# Le a entrada do teclado (setas ou A/D, definidas no project.godot).
	var direction := Input.get_axis("move_left", "move_right")
	position.x += direction * SPEED * delta

	# Impede a cesta de sair da tela usando clamp().
	position.x = clamp(position.x, HALF_WIDTH, GameConfig.SCREEN_WIDTH - HALF_WIDTH)


## Chamado quando qualquer Area2D (uma fruta) encosta na cesta.
func _on_area_entered(area: Area2D) -> void:
	if area is Fruit:
		# Repassa a fruta para o GameManager decidir o efeito.
		fruit_caught.emit(area)

# A aparencia da cesta vem da imagem (basket.svg) no no Sprite2D da cena
# Player.tscn — nao ha desenho por codigo aqui.

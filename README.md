# 🍎 FRUIT CATCHER

Jogo 2D casual feito em **Godot 4 / GDScript** para fins acadêmicos.

Você controla uma **cesta** na parte de baixo da tela e precisa capturar as
frutas que caem do topo. Colete frutas boas para ganhar pontos, evite as podres
e use as frutas especiais a seu favor. Faça a maior pontuação possível antes que
o tempo acabe!

> A arte usa **arquivos de imagem** (SVG) em `Assets/Sprites/`. Cada fruta e a
> cesta têm sua própria imagem, exibida por um nó `Sprite2D` — nenhum desenho é
> feito por código.

---

## 1. Estrutura de Pastas

```
ProjetoJogo/
├── project.godot          # Configuração do projeto (autoloads, teclas, janela)
├── icon.svg               # Ícone do jogo
├── README.md              # Esta documentação
│
├── Scenes/                # Todas as cenas (.tscn)
│   ├── MainMenu.tscn      # Menu principal
│   ├── Game.tscn          # Tela de jogo
│   ├── GameOver.tscn      # Tela de fim de jogo
│   ├── Player.tscn        # A cesta
│   ├── Apple.tscn         # Maca (10 pontos)
│   ├── Banana.tscn        # Banana (15 pontos)
│   ├── Orange.tscn        # Laranja (20 pontos)
│   ├── Strawberry.tscn    # Morango (30 pontos)
│   ├── GoldenFruit.tscn   # Fruta dourada
│   ├── FreezeFruit.tscn   # Fruta congelante
│   └── RottenFruit.tscn   # Fruta podre
│
├── Scripts/               # Todos os scripts (.gd)
│   ├── GameConfig.gd      # (Autoload) Constantes do jogo
│   ├── SaveManager.gd     # (Autoload) Salva/carrega o recorde
│   ├── AudioManager.gd    # (Autoload) Toca os sons
│   ├── SceneTransition.gd # (Autoload) Transição (fade) entre cenas
│   ├── Player.gd          # Movimento da cesta
│   ├── Fruit.gd           # Comportamento base das frutas
│   ├── GoldenFruit.gd     # Fruta dourada (herda de Fruit)
│   ├── FreezeFruit.gd     # Fruta congelante (herda de Fruit)
│   ├── RottenFruit.gd     # Fruta podre (herda de Fruit)
│   ├── Spawner.gd         # Cria as frutas aleatoriamente
│   ├── GameManager.gd     # Cérebro da partida
│   ├── UIManager.gd       # Controla a interface (HUD)
│   ├── MainMenu.gd        # Lógica do menu
│   └── GameOver.gd        # Lógica do fim de jogo
│
├── Assets/
│   ├── Sprites/           # Imagens (SVG): frutas + cesta
│   │   ├── apple.svg  banana.svg  orange.svg  strawberry.svg
│   │   ├── golden.svg  freeze.svg  rotten.svg
│   │   └── basket.svg
│   ├── Audio/             # (vazio) reservado para os .wav
│   └── UI/                # (vazio) reservado para recursos de interface
│
└── Data/
    └── savegame.json      # Arquivo do recorde { "highscore": 0 }
```

---

## 2. Estrutura das Cenas

| Cena | Nó raiz | Filhos principais |
|------|---------|-------------------|
| **MainMenu** | `Control` | Título, botões (Jogar/Instruções/Sair), painel de instruções |
| **Game** | `Node2D` | Chão, Player, Spawner, HUD (CanvasLayer com os Labels) |
| **GameOver** | `Control` | Painel com pontuação, recorde e botões |
| **Player** | `Area2D` | Sprite2D (basket.svg) + CollisionShape2D |
| **Apple / Banana / Orange / Strawberry / Golden / Freeze / Rotten** | `Area2D` | Sprite2D (imagem da fruta) + CollisionShape2D (círculo) |

---

## 3. Explicação de Cada Cena

- **MainMenu.tscn** — Primeira tela. Mostra o título "FRUIT CATCHER" e três
  botões. O painel de instruções fica oculto e aparece sobre o menu quando o
  jogador clica em "Instruções".
- **Game.tscn** — Onde o jogo acontece. O `Node2D` raiz tem o script
  `GameManager.gd`. Contém a cesta (Player), o Spawner (que cria frutas) e o HUD
  (um `CanvasLayer` com os textos de Pontos, Tempo e Nível).
- **GameOver.tscn** — Aparece quando o tempo zera. Mostra a pontuação final, o
  recorde e os botões "Jogar Novamente" e "Voltar ao Menu".
- **Player.tscn** — A cesta. É uma `Area2D` com um `Sprite2D` (basket.svg) que
  detecta o toque das frutas.
- **Apple / Banana / Orange / Strawberry.tscn** — As quatro frutas normais. Cada
  uma é uma `Area2D` com sua imagem (`Sprite2D`) e um círculo de colisão; todas
  usam o script base `Fruit.gd` e definem tipo/pontos no Inspector.
- **GoldenFruit / FreezeFruit / RottenFruit.tscn** — As frutas especiais, também
  `Area2D` com imagem própria, usando seus scripts (que herdam de `Fruit`).

---

## 4. Explicação de Cada Script

### Autoloads (singletons globais)
- **GameConfig.gd** — Guarda todas as constantes (pontos, velocidades, cores,
  probabilidades, tempo). Centralizar os números facilita ajustes. Também calcula
  a velocidade e o nível de dificuldade a partir da pontuação.
- **SaveManager.gd** — Lê e grava o recorde no `Data/savegame.json`. Mantém
  também a pontuação da última partida para a tela de Game Over.
- **AudioManager.gd** — Toca os efeitos sonoros. Se o arquivo `.wav` não existir,
  ignora silenciosamente (sistema pronto para receber os sons).
- **SceneTransition.gd** — Faz um *fade* preto ao trocar de cena.

### Scripts de jogo
- **Player.gd** — Move a cesta na horizontal (`speed = 500`), trava nas bordas
  com `clamp()` e emite o sinal `fruit_caught` quando uma fruta encosta.
- **Fruit.gd** — Classe **base** de todas as frutas. Faz a fruta cair, remove-a
  ao sair da tela e guarda o tipo e os pontos (definidos na cena, no Inspector).
  A imagem fica num nó `Sprite2D` da cena — o código não desenha nada.
- **GoldenFruit.gd / FreezeFruit.gd / RottenFruit.gd** — Herdam de `Fruit`. Cada
  uma tem sua imagem e seu efeito: dourada (+100), congelante (+5s), podre (-100).
  O Spawner sorteia, entre as normais, uma das 4 cenas (maçã/banana/laranja/morango).
- **Spawner.gd** — A cada 1 segundo, sorteia e cria uma fruta usando as
  probabilidades (Normal 80% / Dourada 5% / Congelante 5% / Podre 10%).
- **GameManager.gd** — O **cérebro**: guarda pontuação e tempo, aplica o efeito de
  cada fruta, controla o cronômetro e a dificuldade, e encerra a partida.
- **UIManager.gd** — Atualiza os textos da HUD e cria os textos flutuantes
  (`+10`, `-100`, `+5 segundos`) com animação de subir e sumir.
- **MainMenu.gd / GameOver.gd** — Controlam os botões de cada tela.

---

## 5. Fluxo de Funcionamento

```
MainMenu  ──(Jogar)──►  Game  ──► frutas caem ──► jogador coleta
   ▲                                                     │
   │                                              pontos sobem,
   │                                              tempo desce
   │                                                     │
   └──(Voltar ao Menu)── GameOver ◄── tempo chega a zero ┘
                            │
                            └──(Jogar Novamente)──► Game
```

1. O jogo abre no **Menu Principal**.
2. "Jogar" carrega a **tela de jogo** (com transição de fade).
3. O **Spawner** cria frutas a cada segundo; elas caem.
4. Ao tocar a cesta, a fruta aplica seu efeito e a HUD é atualizada.
5. O **cronômetro** diminui 1 por segundo. A **dificuldade** aumenta conforme a
   pontuação (frutas caem mais rápido).
6. Quando o tempo chega a zero, a partida termina, o **recorde** é salvo (se for
   o caso) e a tela de **Game Over** aparece.

### Pontuação e Dificuldade
| Fruta | Efeito |  | Nível | Pontuação | Velocidade |
|-------|--------|--|-------|-----------|-----------|
| Maçã | +10 |  | 1 | 0–99 | 200 |
| Banana | +15 |  | 2 | 100–299 | 300 |
| Laranja | +20 |  | 3 | 300–499 | 400 |
| Morango | +30 |  | 4 | 500+ | 500 |
| Dourada | +100 |  | | | |
| Congelante | +5 segundos |  | | | |
| Podre | -100 (nunca fica negativo) |  | | | |

---

## 6. Como Executar na Godot 4

1. Baixe a **Godot 4.x** em <https://godotengine.org/download> (versão *Standard*,
   não a .NET). Este projeto foi testado na **Godot 4.3**.
2. Abra a Godot. Na tela de projetos, clique em **Importar**.
3. Selecione o arquivo **`project.godot`** dentro da pasta `ProjetoJogo`.
4. Clique em **Importar e Editar**.
5. Pressione **F5** (ou o botão ▶ no canto superior direito) para rodar.
6. O jogo abre no Menu Principal. Use **A / D** ou as **setas ←/→** para mover a
   cesta.

> 💡 **Trocar a arte:** as imagens ficam em `Assets/Sprites/`. Para mudar o visual,
> substitua o arquivo (ex.: `apple.svg`) por outra imagem com o mesmo nome, ou
> troque a textura do `Sprite2D` direto no editor. Nenhuma mudança de código é
> necessária.
>
> 💡 **Sons (opcional):** coloque arquivos `.wav` em `Assets/Audio/` com os nomes
> `som_coleta`, `som_dourada`, `som_congelante`, `som_podre`, `som_gameover` para
> ativar os efeitos sonoros — não é preciso mexer no código.

---

## 7. Possíveis Melhorias Futuras

- Trocar as imagens SVG por **sprites desenhados/animados** (PNG, spritesheets).
- Adicionar **música de fundo** e os efeitos sonoros.
- Criar um sistema de **vidas** ou **combos** (multiplicador de pontos).
- Adicionar **partículas** ao coletar frutas.
- Incluir um **menu de pausa** (tecla ESC).
- Criar **mais tipos de frutas** e power-ups (ímã, escudo, câmera lenta).
- Adicionar **ranking** com vários recordes e nome do jogador.
- Suporte a **gamepad** e a telas de tamanhos diferentes.
- Tela de **configurações** (volume, dificuldade inicial).

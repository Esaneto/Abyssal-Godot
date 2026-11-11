# Transicao visual 3D do Abyssal (Godot 4.7.2)

## Implementacao
- `scripts/visuals3d/shapes.gd`: materiais PBR e construcao de malhas 3D em runtime, incluindo rochas irregulares.
- `scripts/visuals3d/diver.gd`: personagem humanoide 3D configuravel e animado, compartilhado entre cabine e oceano.
- `scripts/visuals3d/fauna.gd`: 11 tipos de fauna do catalogo: manta, raia-pintada, tartaruga, medusa, peixe-remo, peixe-vibora, lula-vampira, tamboril, isopode, enguia-pelicano e porco-do-mar.
- `scripts/visuals3d/ocean_renderer.gd`: SubViewport 3D com camera ortografica, luz por profundidade, animacao de particulas, streaming geologico por setores e sincronismo com dados biologicos/posicoes da simulacao 2D.
- `scripts/visuals3d/cabin_renderer.gd`: cabine com poltrona, personagem sentado, instrumentos, peixes, geologia e iluminacao em movimento.
- `shaders/underwater_volume.gdshader`: refração visual suave e causticas procedurais animadas.

## Regra arquitetural
A renderizacao 3D e apenas a camada de apresentacao. Personagem `CharacterBody2D`, `Camera2D`, colisoes, fisica, oxigenio, pressao, coleta, inventario, diarios e progresso continuaram na versao 2D durante esta etapa. Assim, o jogador preserva suas funcionalidades e o desempenho pode ser comparado com V.

## Comandos
- `Enter` ou escolha Mar Aberto: entrar na expedicao.
- `WASD`: movimentacao fisica, renderizada por personagem 3D.
- `V`: alternar 3D / desenho legado 2D no Mar Aberto.
- `Esc`: retornar a cabine 3D.
- Os comandos de inventario, observacao, laboratorio e cosmeticos sao os mesmos da versao anterior.

## Verificacao
`.github/workflows/godot-native-smoke.yml` executa importacao e testes de sistemas em Godot 4.7.2, alem de capturas do proprio jogo via Xvfb (nenhum mockup). Consulte o artefato `abyssal-godot-captures` de cada execucao.

## Limites tecnicos
Este e um primeiro passe em malhas proceduralmente modeladas. Ainda nao sao personagens fotorealistas de nivel AAA, nem um mundo de navegacao livre 3D. Para isso, sera necessario rigging humanoide completo, modelagem anatomica de alta qualidade, LOD, revisao de habitats/obstaculos e validacao de desempenho em Android. Nao afirmar que o render nativo foi testado em hardware movel apenas porque o CI desktop passou.

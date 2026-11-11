# Abyssal Godot (projeto independente)

# Abyssal | Exploracao Oceanica em Godot 4

Projeto Godot independente do Abyssal web. A apresentacao padrao agora utiliza cenarios e personagens 3D renderizados em tempo real, com fisica e progressao local ainda em 2D (arquitetura 2.5D). O codigo web permanece no repositorio separado.

## Abrir no Godot 4.7.2 (Windows)
1. Baixe a versao atualizada da branch `main` (ou a branch de desenvolvimento que deseja testar).
2. Importe `project.godot` na raiz deste repositorio no Gerenciador de Projetos.
3. Pressione **F5**.

## Visuais anime 2.5D e equipamentos
- Estilo principal: ilustracao 2.5D com contornos, paleta oceano escuro, particulas, causticas e vegetacao animada.
- A cabine continua um cenario 3D vivo com acabamento industrial anime sobreposto, sem fundo de imagem estatica.
- Fisica de natacao com aceleracao, arrasto, correnteza, flutuabilidade e rotacao do personagem por vetor 360 graus (para cima, baixo, diagonais e horizontal).
- Inventario inicial: 1 Picareta, 2 Cilindro de amostra, 3 Hidrojato de propulsao.
- Segure **Shift** com o hidrojato equipado para impulsionar o mergulhador. A bateria descarrega enquanto ativa e recarrega ao soltar.
- Efeito de bolhas do propulsor animado tanto no modo 2D quanto no visual 3D alternativo.
- Laboratorio: sete pesquisas, incluindo melhorias de bateria, impulso e recarga do Hidrojato.
- **V**: alternar ilustracao anime 2D e renderizador 3D de comparacao no Mar Aberto. 3D fica suspenso quando nao esta em uso.

## Direcao de arte: Abyssal anime sombrio
- As texturas de alta resolucao de mergulhador(a) fazem parte do proprio repositorio em `assets/art/character/abyssal_diver_*_animated_art.webp`, com malha deformavel e animacao do nado, cabelo e nadadeiras.
- A cabine possui arte **propria e distinta** do personagem ereto no comando: `assets/art/character/abyssal_pilot_cabin_*.webp`, animada por `scripts/anime_cabin_pilot.gd` e `shaders/animated_cabin_pilot.gdshader`. Nao depende da antiga combinacao `cabin_layer_*` nem do recorte incorreto do personagem nadando.
- As artes WebP sao imagens-base fixas; **o personagem nunca e exibido sem movimento**: malhas de vertices e efeitos atualizam a cada quadro. Rigging esquelético completo dos membros ainda nao esta finalizado.

A cabine utiliza o personagem vetorial anime em camadas SVG com movimento de cabelo e respiracao, composto sobre o oceano tridimensional. O Mar Aberto agora utiliza o mergulhador dinamico de `scripts/anime_swimmer_ink.gd`, com bracos, pernas, nadadeiras, rosto, equipamentos e cabelo em ilustracao procedural. Raias curvas e animadas substituem os antigos poligonos angulares. A nova iluminacao reduz a saturacao e a luminosidade excessiva, e o HUD foi reduzido a instrumentos de sobrevivencia + tres ferramentas; os minerios permanecem acessiveis pelo inventario `I`.

Isso e uma etapa de direcao de arte, nao um pacote de ilustracoes finais AAA. A fisica aquatica, motor, mapa e salvamento permanecem intocados.

## Nova apresentacao 3D
- Cabine inteira construida em `scripts/visuals3d/cabin_renderer.gd`, com janelas, relevo submarino, luzes, poltrona e mergulhador(a) 3D.
- Mar Aberto renderizado por `scripts/visuals3d/ocean_renderer.gd`. Criaturas 3D animadas correspondem ao catalogo e aos encontros reais da simulacao 2D.
- Modelo humanoide compartilhado por ambos os modos em `scripts/visuals3d/diver.gd`, com respiracao, cabelo, bracos e pernas articulados.
- `shaders/underwater_volume.gdshader`: agua e causticas animadas, nao uma captura de tela.
- A fisica, oxigenio, colisoes, inventario, coletaveis e observacoes permanecem funcionais na simulacao anterior.
- A tecla **V** alterna os visuais 3D e 2D **apenas no Mar Aberto**, para comparacao e compatibilidade.
- Nao e um modelo 3D de qualidade AAA; a anatomia e a fauna sao modelos proceduralmente criados como primeira iteracao de arte 3D. Para hiper-realismo sao necessarios modelos autorais de alta fidelidade e rigging adicional.

## Controles da Cabine
- **Enter**: entrar/retomar a expedicao
- **C** ou botao **PERSONAGEM**: abrir/fechar o guarda-roupa do mergulhador ou mergulhadora
- **Setas cima/baixo**: escolher categoria do guarda-roupa
- **Setas esquerda/direita**: alternar cabelo, rosto/corpo, traje, viseira e ferramentas cosmeticas
- **1-6** (com guarda-roupa aberto): selecionar uma das seis categorias; clique nas setas do painel para alterar
- **Esc / X**: fechar o guarda-roupa e salvar a aparencia escolhida
- **L**: abrir/fechar o laboratorio de pesquisas
- **1-7** (com laboratorio aberto): selecionar a tecnologia
- **R**: pesquisar a tecnologia selecionada, se tiver os recursos
- **Esc**: fechar o laboratorio

## Controles do Mar Aberto
- **WASD/setas**: nadar, com arrasto, inercia, corrente e flutuabilidade
- **1**: equipar picareta | **2**: cilindro reutilizavel | **3**: hidrojato de propulsao
- **Shift**: acionar hidrojato equipado, com energia e rastro de bolhas
- **Segurar G**: minerar/coletar em depositos proximos (1,9s para minerios, 2,6s para amostras)
- **I**: inventario de exploracao
- **M**: carta de navegacao e setores explorados
- **F**: registrar a fauna mais proxima
- **Tab**: diario de campo, com todas as especies ja registradas recuperadas do save
- **J / K** (diario aberto): consultar o registro anterior / seguinte e seus habitats
- **Esc**: voltar ao submarino e salvar ponto atual
- **V**: alternar entre o novo visual anime 2.5D e o comparativo 3D

## Paridade implementada nesta etapa
- Fundo e rochas colidiveis em um Mar Aberto de 24.000 x 21.000 unidades
- Sete arcos de pedra navegaveis com geometria visual/colisao/sonar coincidente
- Ciclo de dia/noite, luz dependente de profundidade, sedimentos e algas animadas
- Materiais nativos texturizados por ruido procedural, estratos em rochas/arcos e distancia atmosferica em camadas
- Cabine panoramica 3D com metal, iluminacao PBR, poltrona e mergulhador(a) articulado
- Mergulhador/a com traje segmentado, nadadeiras articuladas, cabelo animado e ferramenta visual trocavel; HUD reposicionado sem sobreposicao de atalhos
- Fauna inspirada em animais reais com escala minima de 40% do mergulhador
- Inventario de minerios, amostras, picareta e cilindro, com coleta validada localmente
- Pesquisas nativas para oxigenio, traje de pressao, lampada, salvamento, amostrador e sonar
- Persistencia **offline do Godot** em `user://abyssal_native_exploration_v1.json` para itens, tecnologias, fauna, mapa, posicao, hora do dia e seis cosmeticos (saves antigos preservados)
- Sonar e carta com terreno e exploracao de setores

**Nao e uma migracao de contas nem do multiplayer.** Os dados do Godot sao locais e NAO sao creditados ao servidor Render. Shooter, Fossas, lojas antigas e PvP permanecem fora deste cliente por decisao de escopo.

## Validacao
O workflow `.github/workflows/godot-native-smoke.yml` usa Godot 4.7.2. Ele valida cena, fisica, ferramentas, extracao temporizada, projetos do laboratorio, dados salvos, carta e colisoes dos arcos. Imagens reais sao capturadas sob Xvfb e salvas como artefatos do GitHub Actions.

Veja [paridade funcional e itens pendentes](docs/PARIDADE_FUNCIONAL.md) e [direcao artistica](docs/DIRECAO_ARTISTICA.md).

## Nova direcao visual em codigo nativo
A referencia de Mar Aberto foi convertida em elementos autonomos, nao uma imagem colada sobre o jogo:
- Agua e relevo distante em camadas dinamicas, com cor e luz dependentes da profundidade e do horario.
- Recifes de plataforma continental com poligonos fisicos iguais aos contornos desenhados, corais e cristais.
- Vegetacao, peixes, tartarugas e raias com movimento independente; luz direcional acompanha o mergulhador.
- HUD com estado real do jogador e nove itens do inventario local; somente 1 (picareta) e 2 (cilindro) sao equipaveis.
- Ponte de comando 3D com ambiente e criaturas animadas, painel funcional sobreposto e seis areas clicaveis.
- Loja e Fossas aparecem como destinos da versao web, sem funcoes falsas no Godot. Mar Aberto e Laboratorio operam.
- Os screenshots do teste automatizado sao capturas do proprio Godot, nao mockups estaticos.

Arquivos centrais: scripts/native_cabin_art.gd, scripts/native_reef_art.gd, scripts/native_ocean_hud.gd, scripts/ui_art_primitives.gd, scripts/diver_appearance.gd, scripts/diver_paper_doll.gd, scripts/wardrobe_ui.gd e assets/art/character/*.svg. Veja [pipeline de cosmeticos](docs/CUSTOMIZACAO_PERSONAGEM.md).

A jogabilidade permanece 2.5D, mas a renderizacao padrao da cabine e da exploracao e 3D. Ainda e necessario aprimorar a modelagem dos personagens e validar FPS em dispositivos finais.

## Personagens anime-realistas com animação em malha

O **modo 2D legado** suporta os **PNGs originais gerados e aprovados**
para o mergulhador e a mergulhadora. A aparência masculina/feminina é lida do
mesmo perfil local. No modo 2D alternativo, a arte é renderizada sobre uma malha deformável,
com animação sutil de nadadeiras, cabelo e respiração, mantendo todas as
regras físicas anteriores.

**Importante:** os PNGs nao sao necessarios no novo modo 3D. Para o modo 2D legado, os binarios podem ser instalados por pacote
separado em `assets/art/characters/`. Se não estiverem instalados, o modo 2D
continua exibindo a arte procedural antiga, por compatibilidade.

Veja [instalação dos PNGs e limites de cosméticos](docs/ANIME_REALISTA_ASSETS.md).

### Renderizacao nativa de personagens (Godot)
O mergulhador/a do **modo 2D legado**, com o pacote PNG anime-realista instalado, usa uma arvore de nos:
`CharacterBody2D > AnimeCharacterRig > CharacterMesh (MeshInstance2D)`,
`CharacterAnimations (AnimationPlayer)` e `RegulatorBubbles (CPUParticles2D)`.
A animacao `float` controla a flutuacao e `swim` controla o impulso
enquanto o shader de malha aplica deformacoes localizadas; colisao, inventario
e progressao continuam independentes do renderizador. Sem os PNGs locais,
o jogo mostra a arte vetorial anterior, de forma intencional.

Para ativar **somente no visual 2D legado**, instale `anime_diver_female.png` e `anime_diver_male.png`
em `res://assets/art/characters/`. Essas imagens de alta resolucao **nao
estao no repositorio GitHub**. O pacote separado continua sendo necessario.
A textura de cada personagem ainda contem corpo e roupas ja compostos: a
personalizacao livre de partes exigira recortes independentes, nao filtros
de cor sobre o sprite inteiro.


> Este repositório contém somente o projeto Godot. O Abyssal web permanece em `Esaneto/Abyssal`.

# Fase 1 — MVP: biblioteca, fichas e registro de sessão

## Contexto

App de treinos de calistenia (Flutter, offline, só Android — ver plano geral do
projeto). A Fase 0 entregou o esqueleto: Material 3 escuro, banco Drift com todas as
tabelas do modelo, Riverpod, go_router, e ambiente de dev com emulador + hot reload.

Esta fase entrega o **MVP utilizável**: cadastrar exercícios, montar fichas e registrar
treinos com histórico. Ao fim da Fase 1, dá para planejar e executar/registrar um treino
real de ponta a ponta.

## Decisões (definidas com o usuário)

- **Navegação:** barra inferior com 3 abas — Fichas, Exercícios, Histórico.
- **Biblioteca inicial:** app já vem com ~25 exercícios comuns de calistenia (seed).
- **Registro:** modo treino guiado, com timer de descanso visual.
- **Detalhe por série:** completo — reps feitas + carga/RPE por série.

## Funcionalidades

### 1. Exercícios (biblioteca)
- Listar exercícios; adicionar (+), editar (toque), excluir (com confirmação).
- Campos: nome, tipo (`reps` | `tempo` | `ponderado`), grupo muscular (opcional), notas.
- **Seed** no `onCreate` do banco: ~25 exercícios de calistenia (flexão, pull-up, dips,
  agachamento, prancha, remada australiana, elevação de pernas, afundo, pike push-up etc.).

### 2. Fichas
- Listar fichas; criar/editar (nome, descrição); excluir com confirmação.
- Dentro da ficha: **dias** (ex.: Push/Pull/Pernas) reordenáveis (campo `ordem`).
- Dentro do dia: adicionar exercícios da biblioteca com séries-alvo, reps-alvo **ou**
  duração-alvo (conforme o tipo) e descanso (seg); itens reordenáveis.

### 3. Modo treino guiado
- Na ficha, escolher um **dia** → "Iniciar treino" cria uma `WorkoutSession`
  (status `em_andamento`).
- Tela de sessão percorre os exercícios do dia em ordem. Para cada série:
  - exercício `reps`/`ponderado`: campos **reps feitas** e **carga/RPE**;
  - exercício `tempo`: campo **duração (seg)**;
  - botão marca a série como **concluída** (grava um `SetLog`).
- Ao concluir uma série, dispara o **timer de descanso** (regressivo, usando
  `descansoSeg`). Nesta fase só o cronômetro visual; som/vibração ficam na Fase 3.
- "Finalizar treino" marca a sessão como `concluida`.

### 4. Histórico
- Listar sessões `concluida` (data, ficha/dia, resumo com nº de séries e volume).
- Toque abre o detalhe (séries registradas por exercício).

## Arquitetura

Segue o esqueleto da Fase 0.

```
lib/
  app.dart                       # StatefulShellRoute com as 3 abas
  core/                          # tema, widgets comuns, util de tempo
  data/
    database/
      database.dart / .g.dart    # (já existe)
      seed.dart                  # exercícios iniciais, chamado no onCreate
    repositories/
      exercise_repository.dart   # CRUD de exercícios
      routine_repository.dart    # fichas, dias, exercícios do dia
      session_repository.dart    # sessão + set logs + histórico
  features/
    exercises/                   # lista, form
    routines/                    # lista, editor de ficha/dia
    session/                     # modo treino guiado + timer
    history/                     # lista e detalhe de sessão
    shell/                       # ScaffoldWithNavBar (barra inferior)
```

- Cada repository expõe métodos de alto nível e **streams reativas** (Drift `watch`) para
  a UI; encapsula os DAOs/queries. Providers Riverpod expõem repositories e streams.
- Migração do banco continua `schemaVersion = 1`; o seed roda em `onCreate`
  (bancos já criados na Fase 0 no emulador serão recriados — sem dados reais ainda).

## Fluxo de dados

UI (widgets) → providers Riverpod → repository → Drift DAO → SQLite.
Leituras via streams (`watch*`) para atualização automática. Escritas via métodos
`insert/update/delete` do repository, dentro de transações quando envolvem várias tabelas
(ex.: iniciar sessão, concluir série).

## Erros e casos de borda
- Exclusões com confirmação; FKs em cascata já cuidam de dependências.
- Campos obrigatórios validados no formulário (nome não vazio).
- Sessão sem exercícios: bloquear "iniciar" se o dia não tem exercícios.
- Tipos de exercício controlam quais campos aparecem no registro.

## Testes (TDD)
- **Repositories** com Drift em memória (`NativeDatabase.memory()`):
  - exercícios: criar/editar/excluir; seed popula N exercícios.
  - fichas: criar ficha → dia → adicionar exercício; reordenar; cascata ao excluir.
  - sessão: iniciar sessão, gravar SetLogs, finalizar; histórico lista só concluídas;
    resumo (contagem/volume) correto.
- **Widgets** leves nas telas principais, com providers sobrescritos por valores/bancos
  em memória (evitar `pumpAndSettle` com spinner infinito — lição da Fase 0).

## Fora de escopo (Fase 1)
- Progressão de skills (Fase 2), gráficos e som/vibração no timer (Fase 3),
  backup JSON (Fase 4).

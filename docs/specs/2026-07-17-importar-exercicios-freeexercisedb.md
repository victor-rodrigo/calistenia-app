# Importar biblioteca de exercícios da Free Exercise DB (calistenia)

## Contexto

O app precisa de exercícios reais (nomes não inventados). O DAREBEE foi descartado
como fonte: sua licença (CC BY-NC-ND) proíbe explicitamente incluir o conteúdo em
apps, e os treinos são publicados como imagens (exigiriam OCR).

Fonte adotada: **Free Exercise DB** (github.com/yuhonas/free-exercise-db), licença
**The Unlicense** (domínio público) — livre para embutir no app e no repositório
público. Traz nome, músculos, instruções, categoria e imagens por exercício.

## Escopo

- Importar ~100 exercícios de **calistenia**: `equipment == "body only"` sem
  alongamentos (88) + 12 selecionados marcados como `other` mas que são calistenia
  (Muscle Up, Parallel Bar Dip, Ring Dips, One Arm Chin-Up, etc.).
- **Nomes traduzidos para o português** (tabela curada no script); o nome original em
  inglês é preservado no asset para rastreabilidade.
- **Grupos musculares traduzidos** (vocabulário fixo).
- **Imagens empacotadas** (a primeira de cada exercício) para uso offline.
- Substitui o seed provisório de ~24 exercícios feito à mão.

Fora do escopo: instruções passo a passo (a imagem mostra o movimento; podem ser
traduzidas depois).

## Pipeline de geração (dev, versionado em `tool/generate_exercises.py`)

1. Baixa `exercises.json` da fonte.
2. Filtra o subconjunto de calistenia.
3. Aplica tradução de nome (PT) e de grupo muscular (PT); infere `tipo`
   (`tempo` para isometrias listadas, senão `reps`).
4. Baixa a primeira imagem de cada exercício para `assets/exercicios/<id>.jpg`.
5. Emite `assets/exercicios_calistenia.json`:
   `[{ nome, nomeOriginal, grupoMuscular, tipo, imagem }]`.

Rodado uma vez; os assets gerados são commitados.

## Mudanças no app

- **Schema:** adicionar coluna `imagem` (TextColumn nullable) em `Exercises`;
  `schemaVersion` 1 → 2 com migração `addColumn`.
- **Seed** (`lib/data/database/seed.dart`), testável e desacoplado do bundle:
  - `parseExerciseSeed(String json) -> List<ExerciseSeed>` (puro).
  - `seedExercises(AppDatabase db, List<ExerciseSeed>)` (idempotente).
  - `seedFromAsset(AppDatabase db)` lê `rootBundle` e chama os dois — usado no `main`.
- **UI:** lista e formulário de exercícios mostram a imagem quando presente
  (`lib/features/exercises/`).
- **pubspec.yaml:** registrar `assets/exercicios/` e o JSON.

## Testes (TDD)
- `parseExerciseSeed`: converte JSON de exemplo em modelos corretos.
- `seedExercises`: popula quando vazio; não duplica; grava `imagem`.
- Widget: item da lista renderiza com imagem/estado sem imagem.

## Verificação
- Rodar o script gera 100 entradas + imagens.
- `flutter analyze` limpo, `flutter test` verde.
- No emulador (banco recriado): lista mostra os exercícios em PT com imagens.

import 'package:drift/drift.dart';

import '../repositories/routine_repository.dart';
import '../repositories/session_repository.dart';
import 'database.dart';

/// Dados de exemplo para popular treinos, histórico e progresso durante o
/// desenvolvimento. Idempotente: só roda quando ainda não há sessões.
Future<void> seedMockData(AppDatabase db) async {
  final jaTem = await db.workoutSessions.count().getSingle();
  if (jaTem > 0) return;

  final routines = RoutineRepository(db);
  final sessions = SessionRepository(db);

  Future<int> ex(String nome) async {
    final e = await (db.select(db.exercises)
          ..where((t) => t.nome.equals(nome)))
        .getSingleOrNull();
    return e!.id;
  }

  final ppl = await routines.createRoutine(
    nome: 'Push Pull Legs',
    descricao: 'Divisão clássica de calistenia',
  );
  final push = await routines.addDay(ppl, 'Push');
  final pull = await routines.addDay(ppl, 'Pull');
  final legs = await routines.addDay(ppl, 'Pernas');

  await routines.addExercise(push, await ex('Flexão'),
      seriesAlvo: 4, repsAlvo: 12, descansoSeg: 60);
  await routines.addExercise(push, await ex('Paralelas'),
      seriesAlvo: 3, repsAlvo: 10, descansoSeg: 90);
  await routines.addExercise(push, await ex('Prancha'),
      seriesAlvo: 3, duracaoAlvoSeg: 40, descansoSeg: 45);

  await routines.addExercise(pull, await ex('Barra fixa'),
      seriesAlvo: 4, repsAlvo: 8, descansoSeg: 90);
  await routines.addExercise(pull, await ex('Barra supinada'),
      seriesAlvo: 3, repsAlvo: 8, descansoSeg: 90);
  await routines.addExercise(pull, await ex('Elevação de pernas na barra'),
      seriesAlvo: 3, repsAlvo: 12, descansoSeg: 60);

  await routines.addExercise(legs, await ex('Agachamento livre'),
      seriesAlvo: 4, repsAlvo: 20, descansoSeg: 60);
  await routines.addExercise(legs, await ex('Agachamento com salto'),
      seriesAlvo: 3, repsAlvo: 12, descansoSeg: 60);

  final fullBody = await routines.createRoutine(nome: 'Full body');
  final fbDia = await routines.addDay(fullBody, 'Dia único');
  await routines.addExercise(fbDia, await ex('Flexão'),
      seriesAlvo: 3, repsAlvo: 10, descansoSeg: 60);
  await routines.addExercise(fbDia, await ex('Barra fixa'),
      seriesAlvo: 3, repsAlvo: 6, descansoSeg: 90);
  await routines.addExercise(fbDia, await ex('Agachamento livre'),
      seriesAlvo: 3, repsAlvo: 15, descansoSeg: 60);
  await routines.addExercise(fbDia, await ex('Abdominal'),
      seriesAlvo: 3, repsAlvo: 20, descansoSeg: 45);

  final agenda = <(int, int)>[
    (35, push), (33, pull), (31, legs),
    (28, push), (26, pull), (24, legs),
    (21, push), (19, pull),
    (14, push), (12, legs),
    (7, push), (5, pull), (2, fbDia),
  ];

  final agora = DateTime.now();
  for (final (diasAtras, dia) in agenda) {
    final sessionId = await sessions.startSession(dia);
    await (db.update(db.workoutSessions)..where((s) => s.id.equals(sessionId)))
        .write(WorkoutSessionsCompanion(
      data: Value(agora.subtract(Duration(days: diasAtras))),
    ));

    final ganho = (35 - diasAtras) ~/ 7; // leve progressão ao longo do tempo
    for (final item in await routines.getDayExercises(dia)) {
      for (var serie = 1; serie <= item.item.seriesAlvo; serie++) {
        if (item.item.duracaoAlvoSeg != null) {
          await sessions.logSet(sessionId, item.item.exerciseId,
              numeroSerie: serie,
              duracaoSeg: item.item.duracaoAlvoSeg! + ganho * 3);
        } else {
          await sessions.logSet(sessionId, item.item.exerciseId,
              numeroSerie: serie,
              repsFeitas: (item.item.repsAlvo ?? 10) + ganho);
        }
      }
    }
    await sessions.finishSession(sessionId);
  }
}

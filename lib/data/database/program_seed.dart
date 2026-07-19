import 'package:drift/drift.dart';

import '../repositories/exercise_repository.dart';
import '../repositories/routine_repository.dart';
import 'database.dart';

/// Cadastra o programa real do usuário (treino de teste + dias A a D).
/// Idempotente: só roda quando ainda não há treinos.
Future<void> seedUserProgram(AppDatabase db) async {
  final jaTem = await db.routines.count().getSingle();
  if (jaTem > 0) return;

  final routines = RoutineRepository(db);
  final exercises = ExerciseRepository(db);

  Future<int> ex(
    String nome, {
    String tipo = 'reps',
    String? grupo,
    String? notas,
  }) async {
    final existente = await (db.select(db.exercises)
          ..where((e) => e.nome.equals(nome)))
        .getSingleOrNull();
    if (existente != null) return existente.id;
    return exercises.create(
        nome: nome, tipo: tipo, grupoMuscular: grupo, notas: notas);
  }

  final flexao = await ex('Flexão');
  final prancha = await ex('Prancha', tipo: 'tempo');
  final paralelas = await ex('Paralelas');
  final agachamento = await ex('Agachamento livre');
  final legRaise = await ex('Elevação de pernas na barra');
  final pike = await ex('Pike push-up', grupo: 'Ombros');
  final deadHang = await ex('Dead hang', tipo: 'tempo', grupo: 'Antebraço');
  final negativa = await ex('Negativa de barra', grupo: 'Costas');
  final remada = await ex('Remada australiana', grupo: 'Costas');
  final hollow = await ex('Hollow body hold', tipo: 'tempo', grupo: 'Abdômen');
  final bulgaro =
      await ex('Afundo búlgaro', grupo: 'Pernas', notas: 'Cada perna');
  final panturrilha = await ex('Panturrilha em pé', grupo: 'Panturrilha');

  final teste = await routines.createRoutine(
    nome: 'Teste inicial',
    descricao: 'Benchmark de força e resistência',
    isTeste: true,
  );
  final testeDia = await routines.addDay(teste, 'Teste');
  await routines.addExercise(testeDia, flexao, seriesAlvo: 1, descansoSeg: 0);
  await routines.addExercise(testeDia, prancha, seriesAlvo: 1, descansoSeg: 0);
  await routines.addExercise(testeDia, deadHang, seriesAlvo: 1, descansoSeg: 0);

  final diaA = await routines.createRoutine(nome: 'Dia A — Push');
  final push = await routines.addDay(diaA, 'Push');
  await routines.addExercise(push, flexao, seriesAlvo: 4, descansoSeg: 90);
  await routines.addExercise(push, pike,
      seriesAlvo: 3, repsAlvo: 10, descansoSeg: 90);
  await routines.addExercise(push, paralelas, seriesAlvo: 3, descansoSeg: 90);
  await routines.addExercise(push, prancha,
      seriesAlvo: 3, duracaoAlvoSeg: 50, descansoSeg: 45);

  final diaB = await routines.createRoutine(nome: 'Dia B — Pull');
  final pull = await routines.addDay(diaB, 'Pull');
  await routines.addExercise(pull, deadHang,
      seriesAlvo: 3, duracaoAlvoSeg: 25, descansoSeg: 60);
  await routines.addExercise(pull, negativa,
      seriesAlvo: 4, repsAlvo: 5, descansoSeg: 90);
  await routines.addExercise(pull, remada,
      seriesAlvo: 3, repsAlvo: 10, descansoSeg: 90);
  await routines.addExercise(pull, hollow,
      seriesAlvo: 3, duracaoAlvoSeg: 25, descansoSeg: 45);

  final diaC = await routines.createRoutine(nome: 'Dia C — Pernas + Core');
  final pernas = await routines.addDay(diaC, 'Pernas + Core');
  await routines.addExercise(pernas, agachamento,
      seriesAlvo: 3, repsAlvo: 15, descansoSeg: 60);
  await routines.addExercise(pernas, bulgaro,
      seriesAlvo: 3, repsAlvo: 10, descansoSeg: 60);
  await routines.addExercise(pernas, legRaise, seriesAlvo: 3, descansoSeg: 60);
  await routines.addExercise(pernas, panturrilha,
      seriesAlvo: 3, repsAlvo: 18, descansoSeg: 45);

  final diaD = await routines.createRoutine(
    nome: 'Dia D — Full body',
    descricao: 'Circuito: 3-4 voltas, descanso curto entre voltas',
  );
  final full = await routines.addDay(diaD, 'Circuito');
  await routines.addExercise(full, flexao, seriesAlvo: 4, descansoSeg: 15);
  await routines.addExercise(full, remada, seriesAlvo: 4, descansoSeg: 15);
  await routines.addExercise(full, agachamento,
      seriesAlvo: 4, repsAlvo: 15, descansoSeg: 15);
  await routines.addExercise(full, prancha,
      seriesAlvo: 4, duracaoAlvoSeg: 30, descansoSeg: 15);
  await routines.addExercise(full, negativa, seriesAlvo: 3, descansoSeg: 60);
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/repositories/session_repository.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SessionRepository(db);
  });

  tearDown(() => db.close());

  Future<int> criarDia() async {
    final ficha = await db.into(db.routines).insert(
          RoutinesCompanion.insert(nome: 'PPL'),
        );
    return db.into(db.routineDays).insert(
          RoutineDaysCompanion.insert(routineId: ficha, nome: 'Push'),
        );
  }

  test('inicia sessão em andamento vinculada ao dia', () async {
    final dia = await criarDia();
    final id = await repo.startSession(dia);

    final sessao = await repo.getSession(id);
    expect(sessao!.routineDayId, dia);
    expect(sessao.status, 'em_andamento');
  });

  test('registra série e lista os logs', () async {
    final dia = await criarDia();
    final flexao = await db.into(db.exercises).insert(
          ExercisesCompanion.insert(nome: 'Flexão'),
        );
    final sessao = await repo.startSession(dia);

    await repo.logSet(sessao, flexao,
        numeroSerie: 1, repsFeitas: 12, cargaOuRpe: 8);

    final logs = await repo.getSetLogs(sessao);
    expect(logs, hasLength(1));
    expect(logs.single.numeroSerie, 1);
    expect(logs.single.repsFeitas, 12);
    expect(logs.single.cargaOuRpe, 8);
    expect(logs.single.concluida, isTrue);
  });

  test('finaliza a sessão', () async {
    final dia = await criarDia();
    final id = await repo.startSession(dia);

    await repo.finishSession(id);

    expect((await repo.getSession(id))!.status, 'concluida');
  });

  test('lista só sessões concluídas com resumo', () async {
    final dia = await criarDia();
    final flexao = await db.into(db.exercises).insert(
          ExercisesCompanion.insert(nome: 'Flexão'),
        );
    final s = await repo.startSession(dia);
    await repo.logSet(s, flexao, numeroSerie: 1, repsFeitas: 10);
    await repo.logSet(s, flexao, numeroSerie: 2, repsFeitas: 9);
    await repo.finishSession(s);
    await repo.startSession(dia); // em andamento, não deve aparecer

    final concluidas = await repo.getCompletedSessions();
    expect(concluidas, hasLength(1));
    expect(concluidas.single.totalSeries, 2);
    expect(concluidas.single.diaNome, 'Push');
    expect(concluidas.single.fichaNome, 'PPL');
  });

  test('detalhe da sessão traz logs com nome do exercício', () async {
    final dia = await criarDia();
    final flexao = await db.into(db.exercises).insert(
          ExercisesCompanion.insert(nome: 'Flexão'),
        );
    final s = await repo.startSession(dia);
    await repo.logSet(s, flexao, numeroSerie: 1, repsFeitas: 10);

    final logs = await repo.getSessionSetLogs(s);
    expect(logs, hasLength(1));
    expect(logs.single.exercise.nome, 'Flexão');
    expect(logs.single.log.repsFeitas, 10);
  });

  test('evolução do exercício: máximos por sessão concluída', () async {
    final dia = await criarDia();
    final flexao = await db.into(db.exercises).insert(
          ExercisesCompanion.insert(nome: 'Flexão'),
        );

    final s1 = await repo.startSession(dia);
    await repo.logSet(s1, flexao, numeroSerie: 1, repsFeitas: 10, cargaOuRpe: 0);
    await repo.logSet(s1, flexao, numeroSerie: 2, repsFeitas: 12, cargaOuRpe: 5);
    await repo.finishSession(s1);

    // sessão em andamento não deve entrar
    final s2 = await repo.startSession(dia);
    await repo.logSet(s2, flexao, numeroSerie: 1, repsFeitas: 99);

    final pontos = await repo.getExerciseEvolution(flexao);
    expect(pontos, hasLength(1));
    expect(pontos.single.maxReps, 12);
    expect(pontos.single.maxCarga, 5);
  });
}

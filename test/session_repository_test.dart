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
}

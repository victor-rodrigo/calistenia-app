import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/database/program_seed.dart';
import 'package:treino/data/repositories/routine_repository.dart';

void main() {
  test('seedUserProgram cria os 5 treinos, sendo 1 de teste', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedUserProgram(db);

    final fichas = await RoutineRepository(db).getRoutines();
    expect(fichas, hasLength(5));
    expect(fichas.where((f) => f.isTeste), hasLength(1));

    final deadHang = await (db.select(db.exercises)
          ..where((e) => e.nome.equals('Dead hang')))
        .getSingleOrNull();
    expect(deadHang, isNotNull);
  });

  test('seedUserProgram é idempotente', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedUserProgram(db);
    await seedUserProgram(db);

    expect(await RoutineRepository(db).getRoutines(), hasLength(5));
  });
}

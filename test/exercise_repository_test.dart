import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/database/seed.dart';
import 'package:treino/data/repositories/exercise_repository.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ExerciseRepository(db);
  });

  tearDown(() => db.close());

  test('cria e lista exercício', () async {
    final id = await repo.create(nome: 'Flexão', tipo: 'reps', grupoMuscular: 'Peito');
    final all = await repo.getAll();

    expect(all, hasLength(1));
    expect(all.single.id, id);
    expect(all.single.nome, 'Flexão');
    expect(all.single.grupoMuscular, 'Peito');
  });

  test('lista em ordem alfabética', () async {
    await repo.create(nome: 'Zancada');
    await repo.create(nome: 'Agachamento');
    await repo.create(nome: 'Muscle-up');

    final nomes = (await repo.getAll()).map((e) => e.nome).toList();
    expect(nomes, ['Agachamento', 'Muscle-up', 'Zancada']);
  });

  test('edita exercício', () async {
    final id = await repo.create(nome: 'Flexao');
    final exercicio = (await repo.getAll()).single;

    await repo.update(exercicio.copyWith(nome: 'Flexão diamante'));

    expect((await repo.getById(id))!.nome, 'Flexão diamante');
  });

  test('exclui exercício', () async {
    final id = await repo.create(nome: 'Flexão');
    await repo.delete(id);

    expect(await repo.getAll(), isEmpty);
  });

  test('seed popula a biblioteca quando vazia', () async {
    await seedDefaultExercises(db);

    final all = await repo.getAll();
    expect(all.length, greaterThanOrEqualTo(20));
    expect(all.map((e) => e.nome), contains('Flexão'));
  });

  test('seed não duplica se já houver exercícios', () async {
    await repo.create(nome: 'Meu exercício');
    await seedDefaultExercises(db);

    expect(await repo.getAll(), hasLength(1));
  });
}

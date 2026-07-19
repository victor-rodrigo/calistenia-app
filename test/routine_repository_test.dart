import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/repositories/exercise_repository.dart';
import 'package:treino/data/repositories/routine_repository.dart';

void main() {
  late AppDatabase db;
  late RoutineRepository repo;
  late ExerciseRepository exercises;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = RoutineRepository(db);
    exercises = ExerciseRepository(db);
  });

  tearDown(() => db.close());

  test('cria e lista fichas', () async {
    final id = await repo.createRoutine(nome: 'Full body', descricao: 'iniciante');
    final all = await repo.getRoutines();

    expect(all, hasLength(1));
    expect(all.single.id, id);
    expect(all.single.nome, 'Full body');
    expect(all.single.descricao, 'iniciante');
  });

  test('cria ficha marcada como teste', () async {
    await repo.createRoutine(nome: 'Teste inicial', isTeste: true);
    final ficha = (await repo.getRoutines()).single;
    expect(ficha.isTeste, isTrue);
  });

  test('adiciona dias com ordem incremental', () async {
    final ficha = await repo.createRoutine(nome: 'PPL');
    await repo.addDay(ficha, 'Push');
    await repo.addDay(ficha, 'Pull');

    final dias = await repo.getDays(ficha);
    expect(dias.map((d) => d.nome), ['Push', 'Pull']);
    expect(dias.map((d) => d.ordem), [0, 1]);
  });

  test('adiciona exercício ao dia e traz o nome do exercício', () async {
    final ficha = await repo.createRoutine(nome: 'PPL');
    final dia = await repo.addDay(ficha, 'Push');
    final flexao = await exercises.create(nome: 'Flexão');

    await repo.addExercise(dia, flexao, seriesAlvo: 4, repsAlvo: 12, descansoSeg: 60);

    final itens = await repo.getDayExercises(dia);
    expect(itens, hasLength(1));
    expect(itens.single.exercise.nome, 'Flexão');
    expect(itens.single.item.seriesAlvo, 4);
    expect(itens.single.item.repsAlvo, 12);
  });

  test('excluir ficha remove dias e exercícios em cascata', () async {
    final ficha = await repo.createRoutine(nome: 'PPL');
    final dia = await repo.addDay(ficha, 'Push');
    final flexao = await exercises.create(nome: 'Flexão');
    await repo.addExercise(dia, flexao, seriesAlvo: 3);

    await repo.deleteRoutine(ficha);

    expect(await repo.getRoutines(), isEmpty);
    expect(await repo.getDays(ficha), isEmpty);
    expect(await repo.getDayExercises(dia), isEmpty);
  });
}

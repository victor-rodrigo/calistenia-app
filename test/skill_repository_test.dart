import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/repositories/skill_repository.dart';

void main() {
  late AppDatabase db;
  late SkillRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SkillRepository(db);
  });

  tearDown(() => db.close());

  test('cria skill com passos e lista os passos em ordem', () async {
    final skill = await repo.createSkill('Muscle-up');
    await repo.addStep(skill, 'Pull-up x5');
    await repo.addStep(skill, 'Negativa');

    final passos = await repo.getSteps(skill);
    expect(passos.map((s) => s.nome), ['Pull-up x5', 'Negativa']);
    expect(passos.map((s) => s.ordem), [0, 1]);
  });

  test('marcar passo grava a data; desmarcar limpa', () async {
    final skill = await repo.createSkill('L-sit');
    final passo = await repo.addStep(skill, 'Tuck L-sit');

    await repo.setStepAchieved(passo, true);
    expect((await repo.getSteps(skill)).single.conquistadoEm, isNotNull);

    await repo.setStepAchieved(passo, false);
    expect((await repo.getSteps(skill)).single.conquistadoEm, isNull);
  });

  test('conta passos conquistados', () async {
    final skill = await repo.createSkill('Pull-up');
    final p1 = await repo.addStep(skill, 'Negativa');
    await repo.addStep(skill, '1 completa');
    await repo.setStepAchieved(p1, true);

    expect(await repo.countAchieved(skill), 1);
    expect((await repo.getSteps(skill)), hasLength(2));
  });

  test('excluir skill remove os passos em cascata', () async {
    final skill = await repo.createSkill('Handstand');
    await repo.addStep(skill, 'Prancha 60s');

    await repo.deleteSkill(skill);

    expect(await repo.getSkills(), isEmpty);
    expect(await repo.getSteps(skill), isEmpty);
  });
}

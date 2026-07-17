import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/database/skill_seed.dart';
import 'package:treino/data/repositories/skill_repository.dart';

void main() {
  test('defaultSkills traz as progressões de calistenia', () {
    expect(defaultSkills.length, greaterThanOrEqualTo(6));
    expect(defaultSkills.map((s) => s.nome), contains('Muscle-up'));
    expect(defaultSkills.every((s) => s.passos.isNotEmpty), isTrue);
  });

  test('seedSkills popula skills com seus passos ordenados', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SkillRepository(db);

    await seedSkills(db, const [
      SkillSeed('Muscle-up', ['Pull-up x5', 'Negativa', 'Estrito']),
    ]);

    final skills = await repo.getSkills();
    expect(skills, hasLength(1));
    final passos = await repo.getSteps(skills.single.id);
    expect(passos.map((s) => s.nome), ['Pull-up x5', 'Negativa', 'Estrito']);
  });

  test('seedSkills não duplica', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedSkills(db, const [SkillSeed('X', ['a'])]);
    await seedSkills(db, const [SkillSeed('X', ['a'])]);

    expect(await SkillRepository(db).getSkills(), hasLength(1));
  });
}

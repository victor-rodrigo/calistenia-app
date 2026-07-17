import 'package:drift/drift.dart';

import '../database/database.dart';

class SkillRepository {
  SkillRepository(this._db);

  final AppDatabase _db;

  Stream<List<SkillProgression>> watchSkills() => _skillsByName().watch();

  Future<List<SkillProgression>> getSkills() => _skillsByName().get();

  Future<int> createSkill(String nome) => _db
      .into(_db.skillProgressions)
      .insert(SkillProgressionsCompanion.insert(nome: nome));

  Future<void> deleteSkill(int id) =>
      (_db.delete(_db.skillProgressions)..where((s) => s.id.equals(id))).go();

  Stream<List<SkillStep>> watchSteps(int skillId) =>
      _stepsByOrder(skillId).watch();

  Future<List<SkillStep>> getSteps(int skillId) => _stepsByOrder(skillId).get();

  Future<int> addStep(int skillId, String nome) async {
    final ordem = await _nextStepOrder(skillId);
    return _db.into(_db.skillSteps).insert(
          SkillStepsCompanion.insert(
            skillId: skillId,
            nome: nome,
            ordem: Value(ordem),
          ),
        );
  }

  Future<void> deleteStep(int id) =>
      (_db.delete(_db.skillSteps)..where((s) => s.id.equals(id))).go();

  Future<void> setStepAchieved(int stepId, bool achieved) =>
      (_db.update(_db.skillSteps)..where((s) => s.id.equals(stepId))).write(
        SkillStepsCompanion(
          conquistadoEm: Value(achieved ? DateTime.now() : null),
        ),
      );

  Future<int> countAchieved(int skillId) async {
    final count = _db.skillSteps.id.count();
    final query = _db.selectOnly(_db.skillSteps)
      ..addColumns([count])
      ..where(_db.skillSteps.skillId.equals(skillId) &
          _db.skillSteps.conquistadoEm.isNotNull());
    return await query.map((row) => row.read(count)).getSingle() ?? 0;
  }

  SimpleSelectStatement<$SkillProgressionsTable, SkillProgression>
      _skillsByName() => _db.select(_db.skillProgressions)
        ..orderBy([(s) => OrderingTerm(expression: s.nome)]);

  SimpleSelectStatement<$SkillStepsTable, SkillStep> _stepsByOrder(
          int skillId) =>
      _db.select(_db.skillSteps)
        ..where((s) => s.skillId.equals(skillId))
        ..orderBy([(s) => OrderingTerm(expression: s.ordem)]);

  Future<int> _nextStepOrder(int skillId) async {
    final maxExp = _db.skillSteps.ordem.max();
    final query = _db.selectOnly(_db.skillSteps)
      ..addColumns([maxExp])
      ..where(_db.skillSteps.skillId.equals(skillId));
    final atual = await query.map((row) => row.read(maxExp)).getSingle();
    return (atual ?? -1) + 1;
  }
}

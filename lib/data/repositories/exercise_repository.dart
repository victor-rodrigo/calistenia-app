import 'package:drift/drift.dart';

import '../database/database.dart';

class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  Future<int> create({
    required String nome,
    String tipo = 'reps',
    String? grupoMuscular,
    String? notas,
  }) {
    return _db.into(_db.exercises).insert(
          ExercisesCompanion.insert(
            nome: nome,
            tipo: Value(tipo),
            grupoMuscular: Value(grupoMuscular),
            notas: Value(notas),
          ),
        );
  }

  Future<List<Exercise>> getAll() => _byName().get();

  Stream<List<Exercise>> watchAll() => _byName().watch();

  Future<Exercise?> getById(int id) =>
      (_db.select(_db.exercises)..where((e) => e.id.equals(id)))
          .getSingleOrNull();

  Future<void> update(Exercise exercise) =>
      _db.update(_db.exercises).replace(exercise);

  Future<void> delete(int id) =>
      (_db.delete(_db.exercises)..where((e) => e.id.equals(id))).go();

  SimpleSelectStatement<$ExercisesTable, Exercise> _byName() =>
      _db.select(_db.exercises)
        ..orderBy([(e) => OrderingTerm(expression: e.nome)]);
}

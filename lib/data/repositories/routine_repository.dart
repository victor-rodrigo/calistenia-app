import 'package:drift/drift.dart';

import '../database/database.dart';

class RoutineExerciseView {
  const RoutineExerciseView({required this.item, required this.exercise});

  final RoutineExercise item;
  final Exercise exercise;
}

class RoutineRepository {
  RoutineRepository(this._db);

  final AppDatabase _db;

  Stream<List<Routine>> watchRoutines() => _routinesByName().watch();

  Future<List<Routine>> getRoutines() => _routinesByName().get();

  Future<int> createRoutine({
    required String nome,
    String? descricao,
    bool isTeste = false,
  }) {
    return _db.into(_db.routines).insert(
          RoutinesCompanion.insert(
            nome: nome,
            descricao: Value(descricao),
            isTeste: Value(isTeste),
          ),
        );
  }

  Future<void> updateRoutine(Routine routine) =>
      _db.update(_db.routines).replace(routine);

  Future<void> deleteRoutine(int id) =>
      (_db.delete(_db.routines)..where((r) => r.id.equals(id))).go();

  Stream<List<RoutineDay>> watchDays(int routineId) =>
      _daysByOrder(routineId).watch();

  Future<List<RoutineDay>> getDays(int routineId) =>
      _daysByOrder(routineId).get();

  Future<int> addDay(int routineId, String nome) async {
    final ordem = await _nextDayOrder(routineId);
    return _db.into(_db.routineDays).insert(
          RoutineDaysCompanion.insert(
            routineId: routineId,
            nome: nome,
            ordem: Value(ordem),
          ),
        );
  }

  Future<void> deleteDay(int id) =>
      (_db.delete(_db.routineDays)..where((d) => d.id.equals(id))).go();

  Stream<List<RoutineExerciseView>> watchDayExercises(int dayId) =>
      _dayExercisesQuery(dayId).watch().map(_mapViews);

  Future<List<RoutineExerciseView>> getDayExercises(int dayId) =>
      _dayExercisesQuery(dayId).get().then(_mapViews);

  Future<int> addExercise(
    int dayId,
    int exerciseId, {
    int seriesAlvo = 3,
    int? repsAlvo,
    int? duracaoAlvoSeg,
    int descansoSeg = 90,
  }) async {
    final ordem = await _nextExerciseOrder(dayId);
    return _db.into(_db.routineExercises).insert(
          RoutineExercisesCompanion.insert(
            routineDayId: dayId,
            exerciseId: exerciseId,
            seriesAlvo: Value(seriesAlvo),
            repsAlvo: Value(repsAlvo),
            duracaoAlvoSeg: Value(duracaoAlvoSeg),
            descansoSeg: Value(descansoSeg),
            ordem: Value(ordem),
          ),
        );
  }

  Future<void> deleteExercise(int id) =>
      (_db.delete(_db.routineExercises)..where((e) => e.id.equals(id))).go();

  SimpleSelectStatement<$RoutinesTable, Routine> _routinesByName() =>
      _db.select(_db.routines)
        ..orderBy([(r) => OrderingTerm(expression: r.nome)]);

  SimpleSelectStatement<$RoutineDaysTable, RoutineDay> _daysByOrder(
          int routineId) =>
      _db.select(_db.routineDays)
        ..where((d) => d.routineId.equals(routineId))
        ..orderBy([(d) => OrderingTerm(expression: d.ordem)]);

  JoinedSelectStatement _dayExercisesQuery(int dayId) {
    return _db.select(_db.routineExercises).join([
      innerJoin(_db.exercises,
          _db.exercises.id.equalsExp(_db.routineExercises.exerciseId)),
    ])
      ..where(_db.routineExercises.routineDayId.equals(dayId))
      ..orderBy([OrderingTerm(expression: _db.routineExercises.ordem)]);
  }

  List<RoutineExerciseView> _mapViews(List<TypedResult> rows) => [
        for (final row in rows)
          RoutineExerciseView(
            item: row.readTable(_db.routineExercises),
            exercise: row.readTable(_db.exercises),
          ),
      ];

  Future<int> _nextDayOrder(int routineId) async {
    final maxExp = _db.routineDays.ordem.max();
    final query = _db.selectOnly(_db.routineDays)
      ..addColumns([maxExp])
      ..where(_db.routineDays.routineId.equals(routineId));
    final atual = await query.map((row) => row.read(maxExp)).getSingle();
    return (atual ?? -1) + 1;
  }

  Future<int> _nextExerciseOrder(int dayId) async {
    final maxExp = _db.routineExercises.ordem.max();
    final query = _db.selectOnly(_db.routineExercises)
      ..addColumns([maxExp])
      ..where(_db.routineExercises.routineDayId.equals(dayId));
    final atual = await query.map((row) => row.read(maxExp)).getSingle();
    return (atual ?? -1) + 1;
  }
}

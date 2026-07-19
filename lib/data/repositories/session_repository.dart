import 'package:drift/drift.dart';

import '../database/database.dart';

class SessionSummary {
  const SessionSummary({
    required this.session,
    this.diaNome,
    this.fichaNome,
    required this.totalSeries,
  });

  final WorkoutSession session;
  final String? diaNome;
  final String? fichaNome;
  final int totalSeries;
}

class SetLogView {
  const SetLogView({required this.log, required this.exercise});

  final SetLog log;
  final Exercise exercise;
}

class ExerciseEvolutionPoint {
  const ExerciseEvolutionPoint({
    required this.data,
    this.maxReps,
    this.maxCarga,
    this.maxDuracaoSeg,
  });

  final DateTime data;
  final int? maxReps;
  final double? maxCarga;
  final int? maxDuracaoSeg;
}

class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<int> startSession(int routineDayId) {
    return _db.into(_db.workoutSessions).insert(
          WorkoutSessionsCompanion.insert(routineDayId: Value(routineDayId)),
        );
  }

  Future<WorkoutSession?> getSession(int id) =>
      (_db.select(_db.workoutSessions)..where((s) => s.id.equals(id)))
          .getSingleOrNull();

  Future<int> logSet(
    int sessionId,
    int exerciseId, {
    required int numeroSerie,
    int? repsFeitas,
    int? duracaoSeg,
    double? cargaOuRpe,
  }) {
    return _db.into(_db.setLogs).insert(
          SetLogsCompanion.insert(
            sessionId: sessionId,
            exerciseId: exerciseId,
            numeroSerie: numeroSerie,
            repsFeitas: Value(repsFeitas),
            duracaoSeg: Value(duracaoSeg),
            cargaOuRpe: Value(cargaOuRpe),
            concluida: const Value(true),
          ),
        );
  }

  Future<List<SetLog>> getSetLogs(int sessionId) => _logs(sessionId).get();

  Stream<List<SetLog>> watchSetLogs(int sessionId) => _logs(sessionId).watch();

  Future<void> finishSession(int id) =>
      (_db.update(_db.workoutSessions)..where((s) => s.id.equals(id)))
          .write(const WorkoutSessionsCompanion(status: Value('concluida')));

  Stream<List<SessionSummary>> watchCompletedSessions() {
    final (query, count) = _completedQuery();
    return query.watch().map((rows) => _mapSummaries(rows, count));
  }

  Future<List<SessionSummary>> getCompletedSessions() {
    final (query, count) = _completedQuery();
    return query.get().then((rows) => _mapSummaries(rows, count));
  }

  Future<List<ExerciseEvolutionPoint>> getExerciseEvolution(int exerciseId) {
    final maxReps = _db.setLogs.repsFeitas.max();
    final maxCarga = _db.setLogs.cargaOuRpe.max();
    final maxDuracao = _db.setLogs.duracaoSeg.max();
    final query = _db.select(_db.setLogs).join([
      innerJoin(_db.workoutSessions,
          _db.workoutSessions.id.equalsExp(_db.setLogs.sessionId)),
    ])
      ..where(_db.setLogs.exerciseId.equals(exerciseId) &
          _db.workoutSessions.status.equals('concluida'))
      ..groupBy([_db.workoutSessions.id])
      ..orderBy([OrderingTerm(expression: _db.workoutSessions.data)]);
    query.addColumns([maxReps, maxCarga, maxDuracao]);
    return query
        .map((row) => ExerciseEvolutionPoint(
              data: row.readTable(_db.workoutSessions).data,
              maxReps: row.read(maxReps),
              maxCarga: row.read(maxCarga),
              maxDuracaoSeg: row.read(maxDuracao),
            ))
        .get();
  }

  Future<List<SetLogView>> getSessionSetLogs(int sessionId) {
    final query = _db.select(_db.setLogs).join([
      innerJoin(_db.exercises,
          _db.exercises.id.equalsExp(_db.setLogs.exerciseId)),
    ])
      ..where(_db.setLogs.sessionId.equals(sessionId))
      ..orderBy([
        OrderingTerm(expression: _db.setLogs.exerciseId),
        OrderingTerm(expression: _db.setLogs.numeroSerie),
      ]);
    return query
        .map((row) => SetLogView(
              log: row.readTable(_db.setLogs),
              exercise: row.readTable(_db.exercises),
            ))
        .get();
  }

  (JoinedSelectStatement, Expression<int>) _completedQuery() {
    final count = _db.setLogs.id.count();
    final query = _db.select(_db.workoutSessions).join([
      leftOuterJoin(_db.routineDays,
          _db.routineDays.id.equalsExp(_db.workoutSessions.routineDayId)),
      leftOuterJoin(_db.routines,
          _db.routines.id.equalsExp(_db.routineDays.routineId)),
      leftOuterJoin(
          _db.setLogs, _db.setLogs.sessionId.equalsExp(_db.workoutSessions.id)),
    ])
      ..where(_db.workoutSessions.status.equals('concluida'))
      ..groupBy([_db.workoutSessions.id])
      ..orderBy([OrderingTerm.desc(_db.workoutSessions.data)]);
    query.addColumns([count]);
    return (query, count);
  }

  List<SessionSummary> _mapSummaries(
    List<TypedResult> rows,
    Expression<int> count,
  ) =>
      [
        for (final row in rows)
          SessionSummary(
            session: row.readTable(_db.workoutSessions),
            diaNome: row.readTableOrNull(_db.routineDays)?.nome,
            fichaNome: row.readTableOrNull(_db.routines)?.nome,
            totalSeries: row.read(count) ?? 0,
          ),
      ];

  SimpleSelectStatement<$SetLogsTable, SetLog> _logs(int sessionId) =>
      _db.select(_db.setLogs)..where((l) => l.sessionId.equals(sessionId));
}

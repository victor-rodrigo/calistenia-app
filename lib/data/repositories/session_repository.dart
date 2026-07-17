import 'package:drift/drift.dart';

import '../database/database.dart';

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

  SimpleSelectStatement<$SetLogsTable, SetLog> _logs(int sessionId) =>
      _db.select(_db.setLogs)..where((l) => l.sessionId.equals(sessionId));
}

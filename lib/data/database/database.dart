import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 100)();
  TextColumn get tipo => text().withDefault(const Constant('reps'))();
  TextColumn get grupoMuscular => text().nullable()();
  TextColumn get categoriaSkill => text().nullable()();
  TextColumn get imagem => text().nullable()();
  TextColumn get notas => text().nullable()();
}

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 100)();
  TextColumn get descricao => text().nullable()();
  BoolColumn get isTeste => boolean().withDefault(const Constant(false))();
}

class RoutineDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId =>
      integer().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get nome => text().withLength(min: 1, max: 60)();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
}

class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineDayId =>
      integer().references(RoutineDays, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get seriesAlvo => integer().withDefault(const Constant(3))();
  IntColumn get repsAlvo => integer().nullable()();
  IntColumn get duracaoAlvoSeg => integer().nullable()();
  IntColumn get descansoSeg => integer().withDefault(const Constant(90))();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
}

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineDayId => integer()
      .references(RoutineDays, #id, onDelete: KeyAction.setNull)
      .nullable()();
  DateTimeColumn get data => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(const Constant('em_andamento'))();
}

class SetLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get numeroSerie => integer()();
  IntColumn get repsFeitas => integer().nullable()();
  IntColumn get duracaoSeg => integer().nullable()();
  RealColumn get cargaOuRpe => real().nullable()();
  BoolColumn get concluida => boolean().withDefault(const Constant(false))();
}

class SkillProgressions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 100)();
  IntColumn get passoAtual => integer().withDefault(const Constant(0))();
}

class SkillSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get skillId =>
      integer().references(SkillProgressions, #id, onDelete: KeyAction.cascade)();
  TextColumn get nome => text().withLength(min: 1, max: 120)();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
  DateTimeColumn get conquistadoEm => dateTime().nullable()();
}

@DriftDatabase(
  tables: [
    Exercises,
    Routines,
    RoutineDays,
    RoutineExercises,
    WorkoutSessions,
    SetLogs,
    SkillProgressions,
    SkillSteps,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'treino_db'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.addColumn(exercises, exercises.imagem);
          if (from < 3) await m.addColumn(routines, routines.isTeste);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

import 'package:drift/drift.dart';

import 'database.dart';

Future<void> seedDefaultExercises(AppDatabase db) async {
  final existentes = await db.exercises.count().getSingle();
  if (existentes > 0) return;

  await db.batch((b) => b.insertAll(db.exercises, _defaults));
}

ExercisesCompanion _ex(String nome, String tipo, String grupo) =>
    ExercisesCompanion.insert(
      nome: nome,
      tipo: Value(tipo),
      grupoMuscular: Value(grupo),
    );

final _defaults = <ExercisesCompanion>[
  _ex('Flexão', 'reps', 'Peito'),
  _ex('Flexão diamante', 'reps', 'Tríceps'),
  _ex('Flexão inclinada', 'reps', 'Peito'),
  _ex('Flexão declinada', 'reps', 'Peito'),
  _ex('Pike push-up', 'reps', 'Ombros'),
  _ex('Barra fixa (pull-up)', 'reps', 'Costas'),
  _ex('Barra supinada (chin-up)', 'reps', 'Costas'),
  _ex('Remada australiana', 'reps', 'Costas'),
  _ex('Paralela (dips)', 'reps', 'Peito'),
  _ex('Muscle-up', 'reps', 'Costas'),
  _ex('Agachamento', 'reps', 'Pernas'),
  _ex('Agachamento búlgaro', 'reps', 'Pernas'),
  _ex('Pistol squat', 'reps', 'Pernas'),
  _ex('Afundo', 'reps', 'Pernas'),
  _ex('Elevação de panturrilha', 'reps', 'Panturrilha'),
  _ex('Elevação de pernas na barra', 'reps', 'Abdômen'),
  _ex('Elevação de joelhos', 'reps', 'Abdômen'),
  _ex('Prancha', 'tempo', 'Core'),
  _ex('Prancha lateral', 'tempo', 'Core'),
  _ex('L-sit', 'tempo', 'Core'),
  _ex('Hollow hold', 'tempo', 'Core'),
  _ex('Handstand na parede', 'tempo', 'Ombros'),
  _ex('Superman', 'tempo', 'Lombar'),
  _ex('Ponte', 'tempo', 'Lombar'),
];

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/database/seed.dart';
import 'package:treino/data/repositories/exercise_repository.dart';

const _sampleJson = '''
[
  {"nome":"Flexão","nomeOriginal":"Pushups","grupoMuscular":"Peito","tipo":"reps","imagem":"assets/exercicios/Pushups.jpg"},
  {"nome":"Prancha","nomeOriginal":"Plank","grupoMuscular":"Abdômen","tipo":"tempo","imagem":null}
]
''';

void main() {
  test('parseExerciseSeed converte o JSON em modelos', () {
    final items = parseExerciseSeed(_sampleJson);

    expect(items, hasLength(2));
    expect(items.first.nome, 'Flexão');
    expect(items.first.tipo, 'reps');
    expect(items.first.imagem, 'assets/exercicios/Pushups.jpg');
    expect(items[1].tipo, 'tempo');
    expect(items[1].imagem, isNull);
  });

  test('seedExercises popula quando vazio e grava a imagem', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedExercises(db, parseExerciseSeed(_sampleJson));

    final all = await ExerciseRepository(db).getAll();
    expect(all, hasLength(2));
    final flexao = all.firstWhere((e) => e.nome == 'Flexão');
    expect(flexao.grupoMuscular, 'Peito');
    expect(flexao.imagem, 'assets/exercicios/Pushups.jpg');
  });

  test('seedExercises não duplica se já houver exercícios', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedExercises(db, parseExerciseSeed(_sampleJson));
    await seedExercises(db, parseExerciseSeed(_sampleJson));

    expect(await ExerciseRepository(db).getAll(), hasLength(2));
  });
}

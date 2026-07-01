import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/features/home/home_screen.dart';

void main() {
  test('conta exercícios do banco', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.exercises.count().getSingle(), 0);

    await db.into(db.exercises).insert(
          ExercisesCompanion.insert(nome: 'Flexão', tipo: const Value('reps')),
        );

    expect(await db.exercises.count().getSingle(), 1);
  });

  testWidgets('HomeScreen mostra a contagem', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exerciseCountProvider.overrideWith((ref) => Stream.value(0)),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercícios cadastrados: 0'), findsOneWidget);
  });
}

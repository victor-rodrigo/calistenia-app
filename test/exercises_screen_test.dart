import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/features/exercises/exercises_providers.dart';
import 'package:treino/features/exercises/exercises_screen.dart';

Exercise _ex(int id, String nome, String grupo) => Exercise(
      id: id,
      nome: nome,
      tipo: 'reps',
      grupoMuscular: grupo,
      categoriaSkill: null,
      notas: null,
    );

void main() {
  testWidgets('mostra os exercícios da lista', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exercisesProvider.overrideWith(
            (ref) => Stream.value([
              _ex(1, 'Flexão', 'Peito'),
              _ex(2, 'Barra fixa', 'Costas'),
            ]),
          ),
        ],
        child: const MaterialApp(home: ExercisesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flexão'), findsOneWidget);
    expect(find.text('Barra fixa'), findsOneWidget);
  });

  testWidgets('mostra estado vazio quando não há exercícios', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exercisesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: ExercisesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum exercício ainda'), findsOneWidget);
  });
}

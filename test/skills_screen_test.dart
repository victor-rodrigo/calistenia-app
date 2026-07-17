import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/features/skills/skills_providers.dart';
import 'package:treino/features/skills/skills_screen.dart';

void main() {
  testWidgets('lista as skills', (tester) async {
    final skill = SkillProgression(id: 1, nome: 'Muscle-up', passoAtual: 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          skillsProvider.overrideWith((ref) => Stream.value([skill])),
          skillStepsProvider(1).overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: SkillsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Muscle-up'), findsOneWidget);
  });

  testWidgets('estado vazio sem skills', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          skillsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: SkillsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma skill ainda'), findsOneWidget);
  });
}

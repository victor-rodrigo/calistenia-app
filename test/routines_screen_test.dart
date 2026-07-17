import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/features/routines/routines_providers.dart';
import 'package:treino/features/routines/routines_screen.dart';

Routine _ficha(int id, String nome, String? descricao) =>
    Routine(id: id, nome: nome, descricao: descricao);

void main() {
  testWidgets('lista as fichas', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routinesProvider.overrideWith(
            (ref) => Stream.value([
              _ficha(1, 'Full body', 'iniciante'),
              _ficha(2, 'PPL', null),
            ]),
          ),
        ],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Full body'), findsOneWidget);
    expect(find.text('PPL'), findsOneWidget);
  });

  testWidgets('estado vazio sem fichas', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routinesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma ficha ainda'), findsOneWidget);
  });
}

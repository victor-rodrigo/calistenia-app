import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/repositories/routine_repository.dart';
import 'package:treino/features/routines/routines_providers.dart';
import 'package:treino/features/session/session_providers.dart';
import 'package:treino/features/session/session_screen.dart';

void main() {
  testWidgets('sessão lista exercícios e as séries alvo', (tester) async {
    final exercicio = Exercise(
      id: 1,
      nome: 'Flexão',
      tipo: 'reps',
      grupoMuscular: 'Peito',
      categoriaSkill: null,
      imagem: null,
      notas: null,
    );
    final item = RoutineExercise(
      id: 1,
      routineDayId: 1,
      exerciseId: 1,
      seriesAlvo: 3,
      repsAlvo: 12,
      duracaoAlvoSeg: null,
      descansoSeg: 60,
      ordem: 0,
    );
    final day = RoutineDay(id: 1, routineId: 1, nome: 'Push', ordem: 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dayExercisesProvider(1).overrideWith(
            (ref) => Stream.value(
              [RoutineExerciseView(item: item, exercise: exercicio)],
            ),
          ),
          setLogsProvider(1).overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(home: SessionScreen(sessionId: 1, day: day)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flexão'), findsOneWidget);
    expect(find.text('Série 1'), findsOneWidget);
    expect(find.text('Série 3'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Registrar'), findsWidgets);
  });
}

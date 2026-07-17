import 'package:flutter_test/flutter_test.dart';

import 'package:treino/data/database/database.dart';
import 'package:treino/data/repositories/session_repository.dart';
import 'package:treino/features/progress/stats.dart';

SessionSummary _summary(DateTime data, {int series = 3}) => SessionSummary(
      session: WorkoutSession(
        id: 1,
        routineDayId: null,
        data: data,
        status: 'concluida',
      ),
      totalSeries: series,
    );

void main() {
  test('frequência semanal agrupa treinos por semana (segunda a domingo)', () {
    final freq = frequenciaSemanal([
      _summary(DateTime(2026, 7, 6)), // segunda
      _summary(DateTime(2026, 7, 8)), // mesma semana
      _summary(DateTime(2026, 7, 15)), // semana seguinte
    ]);

    expect(freq, hasLength(2));
    expect(freq.first.treinos, 2);
    expect(freq.last.treinos, 1);
  });

  test('volume por treino ordena por data', () {
    final vol = volumePorTreino([
      _summary(DateTime(2026, 7, 15), series: 5),
      _summary(DateTime(2026, 7, 6), series: 2),
    ]);

    expect(vol.map((v) => v.series), [2, 5]);
  });
}

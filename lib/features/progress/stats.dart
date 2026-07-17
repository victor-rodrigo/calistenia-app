import '../../data/repositories/session_repository.dart';

typedef PontoSemana = ({DateTime semana, int treinos});
typedef PontoVolume = ({DateTime data, int series});

List<PontoSemana> frequenciaSemanal(List<SessionSummary> sessions) {
  final porSemana = <DateTime, int>{};
  for (final s in sessions) {
    final d = s.session.data;
    final segunda = DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: d.weekday - 1));
    porSemana[segunda] = (porSemana[segunda] ?? 0) + 1;
  }
  final semanas = porSemana.keys.toList()..sort();
  return [for (final w in semanas) (semana: w, treinos: porSemana[w]!)];
}

List<PontoVolume> volumePorTreino(List<SessionSummary> sessions) {
  final ordenadas = [...sessions]
    ..sort((a, b) => a.session.data.compareTo(b.session.data));
  return [
    for (final s in ordenadas) (data: s.session.data, series: s.totalSeries),
  ];
}

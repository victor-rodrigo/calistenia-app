import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui.dart';
import '../exercises/exercises_providers.dart';
import '../history/history_providers.dart';
import 'progress_providers.dart';
import 'stats.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int? _exercicioId;

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(completedSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progresso')),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.show_chart,
              titulo: 'Sem dados ainda',
              subtitulo: 'Registre treinos para ver sua evolução',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Secao(
                titulo: 'Frequência (treinos por semana)',
                child: _BarChart(dados: frequenciaSemanal(list)),
              ),
              _Secao(
                titulo: 'Volume por treino (séries)',
                child: _LineChart(
                  spots: [
                    for (final (i, v) in volumePorTreino(list).indexed)
                      FlSpot(i.toDouble(), v.series.toDouble()),
                  ],
                ),
              ),
              _Secao(
                titulo: 'Evolução por exercício',
                child: _EvolucaoExercicio(
                  exercicioId: _exercicioId,
                  onSelect: (id) => setState(() => _exercicioId = id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _EvolucaoExercicio extends ConsumerWidget {
  const _EvolucaoExercicio({required this.exercicioId, required this.onSelect});

  final int? exercicioId;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercicios = ref.watch(exercisesProvider).asData?.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<int>(
          isExpanded: true,
          value: exercicioId,
          hint: const Text('Escolha um exercício'),
          items: [
            for (final e in exercicios)
              DropdownMenuItem(value: e.id, child: Text(e.nome)),
          ],
          onChanged: (v) {
            if (v != null) onSelect(v);
          },
        ),
        const SizedBox(height: 12),
        if (exercicioId != null) _Evolucao(exercicioId: exercicioId!),
      ],
    );
  }
}

class _Evolucao extends ConsumerWidget {
  const _Evolucao({required this.exercicioId});

  final int exercicioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pontos = ref.watch(exerciseEvolutionProvider(exercicioId));

    return pontos.when(
      loading: () => const SizedBox(
          height: 180, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Erro: $e'),
      data: (list) {
        if (list.isEmpty) {
          return const SizedBox(
            height: 60,
            child: Center(child: Text('Nenhum registro para este exercício')),
          );
        }
        final usaReps = list.any((p) => p.maxReps != null);
        final spots = <FlSpot>[
          for (final (i, p) in list.indexed)
            FlSpot(
              i.toDouble(),
              (usaReps ? p.maxReps?.toDouble() : p.maxCarga) ?? 0,
            ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usaReps ? 'Reps máximas por treino' : 'Carga máxima por treino',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _LineChart(spots: spots),
          ],
        );
      },
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.dados});

  final List<PontoSemana> dados;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= dados.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_dm(dados[i].semana),
                        style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (final (i, d) in dados.indexed)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: d.treinos.toDouble(), color: cor, width: 14),
              ]),
          ],
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.spots});

  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            bottomTitles: AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: cor,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

String _dm(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

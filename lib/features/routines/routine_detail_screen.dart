import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui.dart';
import '../../data/database/database.dart';
import '../../data/repositories/routine_repository.dart';
import '../session/session_providers.dart';
import '../session/session_screen.dart';
import 'exercise_picker_screen.dart';
import 'exercise_config_dialog.dart';
import 'routines_providers.dart';

class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(daysProvider(routine.id));

    return Scaffold(
      appBar: AppBar(title: Text(routine.nome)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDay(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Dia'),
      ),
      body: days.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.calendar_today,
              titulo: 'Nenhum dia ainda',
              subtitulo: 'Adicione dias como Push, Pull ou Pernas',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            children: [for (final d in list) _DaySection(day: d)],
          );
        },
      ),
    );
  }

  Future<void> _addDay(BuildContext context, WidgetRef ref) async {
    final nome = await promptText(context, titulo: 'Novo dia', label: 'Nome');
    if (nome != null && nome.isNotEmpty) {
      await ref.read(routineRepositoryProvider).addDay(routine.id, nome);
    }
  }
}

class _DaySection extends ConsumerWidget {
  const _DaySection({required this.day});

  final RoutineDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercicios = ref.watch(dayExercisesProvider(day.id));

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(day.nome,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Iniciar treino',
                  onPressed: () => _startWorkout(context, ref),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Adicionar exercício',
                  onPressed: () => _addExercise(context, ref),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir dia',
                  onPressed: () async {
                    final ok = await confirmDelete(context, 'Excluir "${day.nome}"?');
                    if (ok) {
                      await ref.read(routineRepositoryProvider).deleteDay(day.id);
                    }
                  },
                ),
              ],
            ),
          ),
          exercicios.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erro: $e'),
            ),
            data: (itens) {
              if (itens.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text('Sem exercícios'),
                );
              }
              return Column(
                children: [for (final it in itens) _ExerciseRow(view: it)],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startWorkout(BuildContext context, WidgetRef ref) async {
    final sessionId =
        await ref.read(sessionRepositoryProvider).startSession(day.id);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionScreen(sessionId: sessionId, day: day),
      ),
    );
  }

  Future<void> _addExercise(BuildContext context, WidgetRef ref) async {
    final exercicio = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
    );
    if (exercicio == null || !context.mounted) return;

    final config = await showExerciseConfigDialog(context, exercicio);
    if (config == null) return;

    await ref.read(routineRepositoryProvider).addExercise(
          day.id,
          exercicio.id,
          seriesAlvo: config.seriesAlvo,
          repsAlvo: config.repsAlvo,
          duracaoAlvoSeg: config.duracaoAlvoSeg,
          descansoSeg: config.descansoSeg,
        );
  }
}

class _ExerciseRow extends ConsumerWidget {
  const _ExerciseRow({required this.view});

  final RoutineExerciseView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = view.item;
    final alvo = item.repsAlvo != null
        ? '${item.seriesAlvo} x ${item.repsAlvo}'
        : item.duracaoAlvoSeg != null
            ? '${item.seriesAlvo} x ${item.duracaoAlvoSeg}s'
            : '${item.seriesAlvo} séries';

    return ListTile(
      dense: true,
      title: Text(view.exercise.nome),
      subtitle: Text('$alvo · descanso ${item.descansoSeg}s'),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () =>
            ref.read(routineRepositoryProvider).deleteExercise(item.id),
      ),
    );
  }
}

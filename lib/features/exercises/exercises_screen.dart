import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import 'exercise_form_screen.dart';
import 'exercise_type.dart';
import 'exercises_providers.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) return const _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: list.length,
            itemBuilder: (context, i) => _ExerciseTile(exercise: list[i]),
          );
        },
      ),
    );
  }
}

class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = [
      if (exercise.grupoMuscular != null) exercise.grupoMuscular!,
      tipoLabel(exercise.tipo),
    ].join(' · ');

    return ListTile(
      title: Text(exercise.nome),
      subtitle: Text(subtitle),
      onTap: () => _openForm(context, exercise),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref, exercise),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 56),
            SizedBox(height: 12),
            Text('Nenhum exercício ainda'),
            SizedBox(height: 4),
            Text('Toque em + para adicionar', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

Future<void> _openForm(BuildContext context, [Exercise? exercise]) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ExerciseFormScreen(exercise: exercise)),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Excluir "${exercise.nome}"?'),
      content: const Text('Essa ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );

  if (ok ?? false) {
    await ref.read(exerciseRepositoryProvider).delete(exercise.id);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cartoon.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../core/youtube.dart';
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
        child: const Icon(Icons.add_rounded),
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.fitness_center_rounded,
              titulo: 'Nenhum exercício ainda',
              subtitulo: 'Toque em + para adicionar',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
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

    return StickerCard(
      padding: const EdgeInsets.all(10),
      onTap: () => _openForm(context, exercise),
      child: Row(
        children: [
          _Thumb(imagem: exercise.imagem),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.nome,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.smart_display_rounded),
            color: AppColors.teal,
            tooltip: 'Ver no YouTube',
            onPressed: () => abrirTutorialYoutube(exercise.nome),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, exercise),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.imagem});

  final String? imagem;

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    final placeholder = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: AppColors.paperDeep,
      child: const Icon(Icons.fitness_center_rounded, color: AppColors.ink),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagem == null
          ? placeholder
          : Image.asset(
              imagem!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
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
  final ok = await confirmDelete(context, 'Excluir "${exercise.nome}"?');
  if (ok) {
    await ref.read(exerciseRepositoryProvider).delete(exercise.id);
  }
}

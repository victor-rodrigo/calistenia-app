import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cartoon.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/database/database.dart';
import 'routine_detail_screen.dart';
import 'routines_providers.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Treinos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: routines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.fitness_center_rounded,
              titulo: 'Nenhum treino ainda',
              subtitulo: 'Toque em + para criar seu primeiro treino',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, i) =>
                _RoutineTile(routine: list[i], index: i),
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final nome = await promptText(context, titulo: 'Novo treino', label: 'Nome');
    if (nome != null && nome.isNotEmpty) {
      await ref.read(routineRepositoryProvider).createRoutine(nome: nome);
    }
  }
}

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({required this.routine, required this.index});

  final Routine routine;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cor = routine.isTeste
        ? AppColors.mustard
        : (index.isEven ? AppColors.red : AppColors.teal);

    return StickerCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoutineDetailScreen(routine: routine),
        ),
      ),
      child: Row(
        children: [
          CartoonBadge(
            icon: routine.isTeste
                ? Icons.star_rounded
                : Icons.fitness_center_rounded,
            color: cor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routine.nome, style: Theme.of(context).textTheme.titleMedium),
                if (routine.descricao != null)
                  Text(routine.descricao!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (routine.isTeste)
            const _TesteChip()
          else
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final ok =
                    await confirmDelete(context, 'Excluir "${routine.nome}"?');
                if (ok) {
                  await ref
                      .read(routineRepositoryProvider)
                      .deleteRoutine(routine.id);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _TesteChip extends StatelessWidget {
  const _TesteChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.mustard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(2, 2))],
      ),
      child: Text('Teste',
          style: baloo(12, 700, color: AppColors.ink, spacing: 0.5)),
    );
  }
}

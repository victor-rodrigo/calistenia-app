import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        child: const Icon(Icons.add),
      ),
      body: routines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.list_alt,
              titulo: 'Nenhum treino ainda',
              subtitulo: 'Toque em + para criar seu primeiro treino',
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [for (final r in list) _RoutineTile(routine: r)],
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
  const _RoutineTile({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.list_alt),
      title: Text(routine.nome),
      subtitle: routine.descricao == null ? null : Text(routine.descricao!),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoutineDetailScreen(routine: routine),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final ok = await confirmDelete(context, 'Excluir "${routine.nome}"?');
          if (ok) {
            await ref.read(routineRepositoryProvider).deleteRoutine(routine.id);
          }
        },
      ),
    );
  }
}

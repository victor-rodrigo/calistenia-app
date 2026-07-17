import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui.dart';
import '../../data/database/database.dart';
import 'skills_providers.dart';

class SkillDetailScreen extends ConsumerWidget {
  const SkillDetailScreen({super.key, required this.skill});

  final SkillProgression skill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(skillStepsProvider(skill.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(skill.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await confirmDelete(context, 'Excluir "${skill.nome}"?');
              if (!ok) return;
              await ref.read(skillRepositoryProvider).deleteSkill(skill.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addStep(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Passo'),
      ),
      body: steps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.checklist,
              titulo: 'Sem passos ainda',
              subtitulo: 'Adicione os passos da progressão',
            );
          }
          final feitos = list.where((s) => s.conquistadoEm != null).length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: feitos / list.length),
                    const SizedBox(height: 6),
                    Text('$feitos de ${list.length} conquistados'),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final passo in list)
                      _StepTile(skillId: skill.id, step: passo),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addStep(BuildContext context, WidgetRef ref) async {
    final nome = await promptText(context, titulo: 'Novo passo', label: 'Nome');
    if (nome != null && nome.isNotEmpty) {
      await ref.read(skillRepositoryProvider).addStep(skill.id, nome);
    }
  }
}

class _StepTile extends ConsumerWidget {
  const _StepTile({required this.skillId, required this.step});

  final int skillId;
  final SkillStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conquistado = step.conquistadoEm != null;
    return CheckboxListTile(
      value: conquistado,
      onChanged: (v) => ref
          .read(skillRepositoryProvider)
          .setStepAchieved(step.id, v ?? false),
      title: Text(step.nome),
      secondary: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => ref.read(skillRepositoryProvider).deleteStep(step.id),
      ),
    );
  }
}

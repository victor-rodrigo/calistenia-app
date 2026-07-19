import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cartoon.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/database/database.dart';
import 'skill_detail_screen.dart';
import 'skills_providers.dart';

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Skills')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: skills.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.emoji_events_rounded,
              titulo: 'Nenhuma skill ainda',
              subtitulo: 'Toque em + para criar uma progressão',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, i) => _SkillTile(skill: list[i]),
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final nome = await promptText(context, titulo: 'Nova skill', label: 'Nome');
    if (nome != null && nome.isNotEmpty) {
      await ref.read(skillRepositoryProvider).createSkill(nome);
    }
  }
}

class _SkillTile extends ConsumerWidget {
  const _SkillTile({required this.skill});

  final SkillProgression skill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(skillStepsProvider(skill.id));
    final list = steps.asData?.value ?? const <SkillStep>[];
    final total = list.length;
    final feitos = list.where((s) => s.conquistadoEm != null).length;

    return StickerCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SkillDetailScreen(skill: skill)),
      ),
      child: Row(
        children: [
          const CartoonBadge(
              icon: Icons.emoji_events_rounded, color: AppColors.mustard),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill.nome,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                if (total == 0)
                  Text('Sem passos',
                      style: Theme.of(context).textTheme.bodySmall)
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: feitos / total,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$feitos de $total',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

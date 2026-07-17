import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        child: const Icon(Icons.add),
      ),
      body: skills.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.emoji_events,
              titulo: 'Nenhuma skill ainda',
              subtitulo: 'Toque em + para criar uma progressão',
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [for (final s in list) _SkillTile(skill: s)],
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

    return ListTile(
      leading: const Icon(Icons.emoji_events),
      title: Text(skill.nome),
      subtitle: total == 0
          ? const Text('Sem passos')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(value: feitos / total),
                const SizedBox(height: 2),
                Text('$feitos de $total'),
              ],
            ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SkillDetailScreen(skill: skill)),
      ),
    );
  }
}

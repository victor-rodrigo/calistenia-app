import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/ui.dart';
import '../../data/repositories/session_repository.dart';
import 'history_detail_screen.dart';
import 'history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(completedSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(
              icon: Icons.history,
              titulo: 'Nenhum treino registrado',
              subtitulo: 'Inicie um treino por uma ficha para ver aqui',
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) => _SessionTile(summary: list[i]),
          );
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final titulo = [summary.diaNome, summary.fichaNome]
        .whereType<String>()
        .join(' · ');

    return ListTile(
      leading: const Icon(Icons.check_circle_outline),
      title: Text(titulo.isEmpty ? 'Treino' : titulo),
      subtitle: Text(formatDataHora(summary.session.data)),
      trailing: Text('${summary.totalSeries} séries'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HistoryDetailScreen(summary: summary),
        ),
      ),
    );
  }
}

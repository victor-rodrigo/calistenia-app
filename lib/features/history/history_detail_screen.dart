import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/database/database.dart';
import '../../data/repositories/session_repository.dart';
import 'history_providers.dart';

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(sessionSetLogsProvider(summary.session.id));
    final titulo = [summary.diaNome, summary.fichaNome]
        .whereType<String>()
        .join(' · ');

    return Scaffold(
      appBar: AppBar(title: Text(titulo.isEmpty ? 'Treino' : titulo)),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Nenhuma série registrada'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(formatDataHora(summary.session.data),
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              for (final grupo in _agrupar(list)) _ExerciseBlock(grupo: grupo),
            ],
          );
        },
      ),
    );
  }

  List<_Grupo> _agrupar(List<SetLogView> logs) {
    final grupos = <_Grupo>[];
    for (final v in logs) {
      if (grupos.isEmpty || grupos.last.exerciseId != v.exercise.id) {
        grupos.add(_Grupo(v.exercise.id, v.exercise.nome, [v.log]));
      } else {
        grupos.last.logs.add(v.log);
      }
    }
    return grupos;
  }
}

class _Grupo {
  _Grupo(this.exerciseId, this.nome, this.logs);

  final int exerciseId;
  final String nome;
  final List<SetLog> logs;
}

class _ExerciseBlock extends StatelessWidget {
  const _ExerciseBlock({required this.grupo});

  final _Grupo grupo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(grupo.nome, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final log in grupo.logs) Text('  • ${_descreve(log)}'),
        ],
      ),
    );
  }

  String _descreve(SetLog log) {
    final feito = log.repsFeitas != null
        ? '${log.repsFeitas} reps'
        : log.duracaoSeg != null
            ? '${log.duracaoSeg}s'
            : '—';
    final carga = log.cargaOuRpe != null ? ' · ${_fmt(log.cargaOuRpe!)}' : '';
    return 'Série ${log.numeroSerie}: $feito$carga';
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';
}

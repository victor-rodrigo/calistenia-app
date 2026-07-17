import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/format.dart';
import '../../core/ui.dart';
import '../../data/repositories/session_repository.dart';
import 'history_detail_screen.dart';
import 'history_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _focado = DateTime.now();
  DateTime? _selecionado;

  String _chave(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Widget build(BuildContext context) {
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
              subtitulo: 'Inicie um treino para ver aqui',
            );
          }

          final porDia = <String, List<SessionSummary>>{};
          for (final s in list) {
            porDia.putIfAbsent(_chave(s.session.data), () => []).add(s);
          }

          final visiveis = _selecionado == null
              ? list
              : porDia[_chave(_selecionado!)] ?? const [];

          return Column(
            children: [
              TableCalendar<SessionSummary>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focado,
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
                selectedDayPredicate: (d) => isSameDay(_selecionado, d),
                eventLoader: (day) => porDia[_chave(day)] ?? const [],
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (sel, foc) => setState(() {
                  _selecionado = isSameDay(_selecionado, sel) ? null : sel;
                  _focado = foc;
                }),
              ),
              const Divider(height: 1),
              Expanded(
                child: visiveis.isEmpty
                    ? const Center(child: Text('Nenhum treino nesse dia'))
                    : ListView.builder(
                        itemCount: visiveis.length,
                        itemBuilder: (context, i) =>
                            _SessionTile(summary: visiveis[i]),
                      ),
              ),
            ],
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
    final titulo =
        [summary.diaNome, summary.fichaNome].whereType<String>().join(' · ');

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

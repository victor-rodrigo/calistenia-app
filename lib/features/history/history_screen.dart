import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/cartoon.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
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
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: baloo(18, 800),
                  leftChevronIcon:
                      const Icon(Icons.chevron_left_rounded, color: AppColors.ink),
                  rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink),
                ),
                calendarStyle: CalendarStyle(
                  markersMaxCount: 1,
                  markerDecoration: const BoxDecoration(
                      color: AppColors.teal, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(
                    color: AppColors.mustard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  todayTextStyle: baloo(14, 700),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  selectedTextStyle: baloo(14, 700, color: AppColors.card),
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
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: visiveis.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
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

    return StickerCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HistoryDetailScreen(summary: summary),
        ),
      ),
      child: Row(
        children: [
          const CartoonBadge(
              icon: Icons.check_rounded, color: AppColors.teal, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo.isEmpty ? 'Treino' : titulo,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(formatDataHora(summary.session.data),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text('${summary.totalSeries} séries', style: baloo(14, 700)),
        ],
      ),
    );
  }
}
